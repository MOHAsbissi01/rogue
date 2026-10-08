# Dot-sourced by audit-workspace.ps1. Validation does not modify media or metadata.
function Test-GalleryRecords([string]$Root,$Tables) {
    . (Get-SafePath $Root 'scripts/gallery-common.ps1')
    $key='12-ASSET-LIBRARY/asset-manifest.csv'
    if (-not $Tables.ContainsKey($key)) { 'Asset manifest schema/table missing.'; return }
    $rows=$Tables[$key].Rows
    Get-AssetValidationIssues $rows
    $register=$Tables['10-OPERATIONS/asset-register.csv'].Rows
    $products=$Tables['03-PRODUCTS/product-catalog.csv'].Rows
    $campaigns=$Tables['05-MARKETING/campaign-index.csv'].Rows
    $productions=$Tables['04-CREATIVE-STUDIO/ai-creation/higgsfield/04-VIDEO-PRODUCTIONS/production-index.csv'].Rows
    foreach ($r in $rows) {
        if ($r.product_sku) {
            $match=@($products | Where-Object { $_.product_id -eq $r.product_sku -or $_.variant_sku -eq $r.product_sku })
            if ($match.Count -ne 1) { "Unknown/ambiguous asset product: $($r.asset_id)" }
            elseif ($r.collection -ne $match[0].collection_id) { "Asset collection mismatch: $($r.asset_id)" }
        }
        if ($r.campaign_id -and @($campaigns | Where-Object { $_.campaign_code -eq $r.campaign_id }).Count -ne 1) { "Unknown asset campaign: $($r.asset_id)" }
        if ($r.higgsfield_production_id -and @($productions | Where-Object { $_.production_id -eq $r.higgsfield_production_id }).Count -ne 1) { "Unknown asset production: $($r.asset_id)" }
        if ($r.asset_type -notin @('IMAGE','VIDEO','OTHER')) { "Invalid asset type: $($r.asset_id)" }
        if ($r.publication_status -notin @('UNKNOWN','UNPUBLISHED','PUBLISHED')) { "Invalid publication state: $($r.asset_id)" }
        foreach ($field in @('commercial_use_approval','product_accuracy_approval')) { if ($r.$field -notin @('UNKNOWN','APPROVED','REJECTED','NEEDS_REVIEW')) { "Invalid approval enum: $($r.asset_id)/$field" } }
        if ($r.publication_status -eq 'PUBLISHED' -and -not $r.publication_reference) { "Published asset has no reference: $($r.asset_id)" }
        foreach ($field in @('size_bytes','width','height','duration_seconds')) {
            $n=0.0
            if ($r.$field -and (-not [double]::TryParse($r.$field,[Globalization.NumberStyles]::Float,[Globalization.CultureInfo]::InvariantCulture,[ref]$n) -or $n -lt 0)) { "Invalid asset number: $($r.asset_id)/$field" }
        }
        $date=[datetime]::MinValue
        if (-not [datetime]::TryParseExact($r.last_updated,'yyyy-MM-dd',[Globalization.CultureInfo]::InvariantCulture,[Globalization.DateTimeStyles]::None,[ref]$date)) { "Invalid asset update date: $($r.asset_id)" }
        if ($r.sha256 -and $r.sha256 -cnotmatch '^[A-F0-9]{64}$') { "Invalid asset hash: $($r.asset_id)" }
        if ($r.thumbnail_path -and $r.thumbnail_path -cnotmatch '^12-ASSET-LIBRARY/generated-thumbnails/(AST|ASSET)-[A-Z0-9-]+-[A-F0-9]{16}\.jpg$') { "Unsafe thumbnail path: $($r.asset_id)" }
        $matches=@($register | Where-Object { $_.asset_id -eq $r.asset_id })
        if ($matches.Count -ne 1) { "Asset missing/duplicated in operations register: $($r.asset_id)" }
        elseif ($matches[0].local_path -ne $r.file_path) { "Asset register path mismatch: $($r.asset_id)" }
        try {
            if ($r.availability -eq 'LOCAL' -and -not (Test-LocalMedia $Root $r.file_path)) { "Asset marked LOCAL but unavailable/excluded: $($r.asset_id); rebuild gallery" }
            if ($r.workflow_state -in @('APPROVED','PUBLISHED') -and (Test-LocalMedia $Root $r.file_path)) {
                if ((Get-FileHash -LiteralPath (Get-SafePath $Root $r.file_path) -Algorithm SHA256).Hash -ne $r.sha256) { "Approved bytes changed: $($r.asset_id); rebuild/review" }
            }
        } catch { "Unsafe/unavailable asset: $($r.asset_id): $($_.Exception.Message)" }
    }
    $jsonPath=Get-SafePath $Root 'dashboard/data/gallery.json'
    if (Test-Path -LiteralPath $jsonPath) {
        try {
            $json=Get-Content -LiteralPath $jsonPath -Raw | ConvertFrom-Json
            if ($json.schema_version -ne 1) { 'Unsupported gallery JSON schema.' }
            if (@($json.assets).Count -ne @($rows).Count) { 'Gallery JSON record count is stale; rebuild.' }
            foreach ($asset in $json.assets) {
                $record=@($rows | Where-Object { $_.asset_id -eq $asset.asset_id })
                if ($record.Count -ne 1) { "Unregistered JSON asset: $($asset.asset_id)"; continue }
                foreach ($field in $Tables[$key].Headers) { if ($asset.$field -cne $record[0].$field) { "Gallery JSON field stale: $($asset.asset_id)/$field; rebuild" } }
            }
        } catch { "Invalid gallery JSON: $($_.Exception.Message)" }
    }
    # A fresh Git clone may omit generated JSON. Launcher rebuilds it; CSV remains authoritative.
}
