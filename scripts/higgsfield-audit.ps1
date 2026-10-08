# Dot-sourced by audit-workspace.ps1; performs local cross-record validation only.
function Test-HiggsfieldRecords([string]$Root, [hashtable]$Tables) {
    $errors = New-Object 'System.Collections.Generic.List[string]'
    try {
        $structure = Get-Content -LiteralPath (Get-SafePath $Root 'scripts/higgsfield-production-structure.json') -Raw -Encoding UTF8 | ConvertFrom-Json
        $base = [string]$structure.base_path
        $indexName = $base + '/production-index.csv'
        $deliverableName = $base + '/deliverables.csv'
        foreach ($required in @($indexName,$deliverableName,'03-PRODUCTS/product-catalog.csv','05-MARKETING/campaign-index.csv','05-MARKETING/content-calendar.csv')) {
            if (-not $Tables.ContainsKey($required)) { $errors.Add("Higgsfield required register unavailable: $required") }
        }
        if ($errors.Count -gt 0) { return $errors.ToArray() }
        $states = @('IDEA','BRIEFED','GENERATING','EDITING','REVIEW','APPROVED','PUBLISHED')
        $productions = @{}
        foreach ($row in $Tables[$indexName].Rows) {
            $id = [string]$row.production_id
            if ($id -cnotmatch '^HV-[0-9]{3}$') { $errors.Add("Invalid Higgsfield production ID: $id"); continue }
            if ($productions.ContainsKey($id)) { $errors.Add("Duplicate Higgsfield production ID: $id"); continue }
            $productions[$id] = $row
            if ($row.state -cnotin $states) { $errors.Add("Invalid production state: $id") }
            if ($row.platform -cnotin $structure.platforms -or $row.content_type -cnotin $structure.content_types) { $errors.Add("Invalid production platform/content type: $id") }
            $products = @($Tables['03-PRODUCTS/product-catalog.csv'].Rows | Where-Object { $_.product_id -ceq $row.product_id })
            if ($products.Count -ne 1) { $errors.Add("Production product not registered: $id") }
            elseif ($row.product_sku -cne $products[0].product_id -and $row.product_sku -cne $products[0].variant_sku) { $errors.Add("Production SKU not registered to product: $id") }
            if (@($Tables['05-MARKETING/campaign-index.csv'].Rows | Where-Object { $_.campaign_code -ceq $row.campaign_id }).Count -ne 1) { $errors.Add("Production campaign not registered: $id") }
            $expectedPattern = '^' + [regex]::Escape($base + '/' + $id + '-') + '[A-Z0-9]+(-[A-Z0-9]+)*$'
            if ($row.production_path -cnotmatch $expectedPattern) { $errors.Add("Invalid production path: $id"); continue }
            foreach ($name in $structure.files) {
                $path = Get-SafePath $Root ($row.production_path + '/' + $name)
                if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { $errors.Add("Incomplete Higgsfield production: $id/$name") }
                elseif ([IO.Path]::GetExtension($path) -eq '.md' -and [IO.File]::ReadAllText($path) -match '@(PRODUCTION_ID|PRODUCTION_NAME|PRODUCT_SKU|SKU_STATUS|CAMPAIGN_ID|PLATFORM|CONTENT_TYPE|OBJECTIVE|DATE)@') { $errors.Add("Unrendered production template token: $id/$name") }
            }
            foreach ($directory in $structure.directories) {
                if (-not (Test-Path -LiteralPath (Get-SafePath $Root ($row.production_path + '/' + $directory)) -PathType Container)) { $errors.Add("Missing Higgsfield album: $id/$directory") }
            }
            $logName = $row.production_path + '/generation-log.csv'
            if (-not $Tables.ContainsKey($logName)) { $errors.Add("Production generation log unvalidated: $id") }
            else {
                $attempts = @{}
                foreach ($attempt in $Tables[$logName].Rows) {
                    if ($attempt.production_id -cne $id) { $errors.Add("Attempt production mismatch: $logName") }
                    if ($attempt.attempt_id -eq 'TEMPLATE') { continue }
                    if ($attempts.ContainsKey($attempt.attempt_id)) { $errors.Add("Duplicate attempt: $($attempt.attempt_id)") }
                    $attempts[$attempt.attempt_id] = $true
                    if (-not $attempt.attempt_id.StartsWith($id+'-',[StringComparison]::Ordinal)) { $errors.Add("Attempt ID outside production: $($attempt.attempt_id)") }
                }
            }
            if ($row.state -in @('APPROVED','PUBLISHED') -and (-not $row.approval_reference -or -not $row.approval_date -or $row.approval_status -cne 'APPROVED')) { $errors.Add("Production lacks approval evidence: $id") }
        }
        foreach ($folder in Get-ChildItem -LiteralPath (Get-SafePath $Root $base) -Directory -Force) {
            if ($folder.Name -in @('production-template','future-productions')) { continue }
            if ($folder.Name -notmatch '^(HV-[0-9]{3})(-|$)' -or -not $productions.ContainsKey($Matches[1])) { $errors.Add("Unregistered Higgsfield production folder: $($folder.Name)") }
            elseif ($productions[$Matches[1]].production_path -cne ($base+'/'+$folder.Name)) { $errors.Add("Duplicate or mismatched Higgsfield folder: $($folder.Name)") }
        }
        $deliveryKeys = @{}
        foreach ($row in $Tables[$deliverableName].Rows) {
            $key = $row.deliverable_id + ':' + $row.content_id
            if ($deliveryKeys.ContainsKey($key)) { $errors.Add("Duplicate deliverable/content pair: $key") }; $deliveryKeys[$key]=$true
            if (-not $productions.ContainsKey($row.production_id)) { $errors.Add("Deliverable has unknown production: $key"); continue }
            $production = $productions[$row.production_id]
            if ($row.campaign_id -cne $production.campaign_id) { $errors.Add("Deliverable campaign mismatch: $key") }
            if ($row.state -cnotin $states) { $errors.Add("Invalid deliverable state: $key") }
            if (-not $row.brief_path -or -not (Test-Path -LiteralPath (Get-SafePath $Root $row.brief_path) -PathType Leaf)) { $errors.Add("Deliverable brief missing: $key") }
            $calendarRows = @($Tables['05-MARKETING/content-calendar.csv'].Rows | Where-Object { $_.content_id -ceq $row.content_id })
            if ($calendarRows.Count -ne 1) { $errors.Add("Deliverable calendar link missing or duplicated: $key") }
            elseif ($calendarRows[0].campaign_code -cne $row.campaign_id -or $calendarRows[0].asset_path -cne $row.brief_path) { $errors.Add("Deliverable calendar metadata mismatch: $key") }
            if ($row.state -in @('APPROVED','PUBLISHED')) {
                if (-not $row.approval_reference -or -not $row.approval_date -or -not $row.master_path -or -not $row.version) { $errors.Add("Deliverable lacks approval/master evidence: $key") }
                elseif (-not (Test-Path -LiteralPath (Get-SafePath $Root $row.master_path) -PathType Leaf)) { $errors.Add("Approved master missing: $key") }
            }
            if ($row.state -eq 'PUBLISHED' -and (-not $row.published_url -or -not $row.published_date)) { $errors.Add("Published deliverable lacks publication evidence: $key") }
        }
        foreach ($id in $productions.Keys) {
            if (@($Tables[$deliverableName].Rows | Where-Object { $_.production_id -ceq $id }).Count -eq 0) { $errors.Add("Production has no deliverable record: $id") }
        }
    } catch { $errors.Add('Higgsfield audit error: ' + $_.Exception.Message) }
    return $errors.ToArray()
}
