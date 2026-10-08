#requires -Version 5.1
[CmdletBinding()]
param([string]$WorkspaceRoot = '')
if ([string]::IsNullOrWhiteSpace($WorkspaceRoot)) { $WorkspaceRoot = Split-Path -Parent $PSScriptRoot }
. (Join-Path $PSScriptRoot 'common.ps1')
$issues = New-Object 'System.Collections.Generic.List[string]'
$warnings = New-Object 'System.Collections.Generic.List[string]'
$linkCount=0; $csvCount=0; $fileCount=0
function Add-Issue([string]$Message) { $issues.Add($Message) }
function Get-HeadingIds([string]$Text) {
    $seen=@{}
    $ids=New-Object 'System.Collections.Generic.List[string]'
    $inCode=$false
    foreach ($line in ($Text -split '\r?\n')) {
        if ($line -match '^\s*```') { $inCode=-not $inCode; continue }
        if (-not $inCode -and $line -match '^#{1,6}\s+(.+?)\s*#*\s*$') {
            $slug=$Matches[1].ToLowerInvariant() -replace '[^\p{L}\p{N}_\-\s]',''
            $slug=$slug -replace '\s','-'
            if ($seen.ContainsKey($slug)) { $seen[$slug]++; $ids.Add($slug+'-'+$seen[$slug]) }
            else { $seen[$slug]=0; $ids.Add($slug) }
        }
    }
    return @($ids.ToArray())
}
try {
    $root=Get-WorkspaceRoot $WorkspaceRoot
    $manifest=Get-Content -LiteralPath (Get-SafePath $root 'scripts/workspace-manifest.json') -Raw | ConvertFrom-Json
    foreach ($relative in $manifest.files) {
        try { if (-not (Test-Path -LiteralPath (Get-SafePath $root $relative) -PathType Leaf)) { Add-Issue "Missing essential file: $relative" } }
        catch { Add-Issue $_.Exception.Message }
    }
    foreach ($relative in $manifest.directories) {
        try { if (-not (Test-Path -LiteralPath (Get-SafePath $root $relative) -PathType Container)) { Add-Issue "Missing essential folder: $relative" } }
        catch { Add-Issue $_.Exception.Message }
    }
    $schemas=Get-Content -LiteralPath (Get-SafePath $root 'scripts/csv-schemas.json') -Raw | ConvertFrom-Json
    $tables=@{}
    foreach ($schema in $schemas.PSObject.Properties) {
        try {
            $path=Get-SafePath $root $schema.Name
            $table=Read-CsvTable $path @($schema.Value)
            $tables[$schema.Name]=$table
            $csvCount++
            if ($table.Rows.Count -eq 0) { $warnings.Add("CSV has headers only: $($schema.Name)") }
            foreach ($row in $table.Rows) {
                foreach ($header in $table.Headers) {
                    $value=[string]$row.$header
                    if ($value -and $header -match '(^date$|_date$|^last_reviewed$|^period_start$|^period_end$|^cohort_start$|^cohort_end$|^observation_cutoff$|^valid_until$|^start_date$|^end_date$|^last_restore_check$)') {
                        $parsed=[datetime]::MinValue
                        if (-not [datetime]::TryParseExact($value,'yyyy-MM-dd',[Globalization.CultureInfo]::InvariantCulture,[Globalization.DateTimeStyles]::None,[ref]$parsed)) { Add-Issue "Invalid ISO date in $($schema.Name), $header`: $value" }
                    }
                    if ($value -and ($header -match '(_tnd$|_pct$|_units$|^gsm$)' -or $header -in @('quantity_basis','units_per_order','list_price_per_unit','net_sales_revenue','landed_unit_cost','production_per_unit','decoration_per_unit','packaging_per_unit','inbound_freight_per_unit','allocated_production_overhead_per_unit','reach','saves','shares','engaged_views','eligible_views','followers_start','followers_end','follower_net_growth','spend','attributed_net_sales','new_customers','cac','roas','list_price','promotion_price','available_stock'))) {
                        $number=0.0
                        if (-not [double]::TryParse($value,[Globalization.NumberStyles]::Float,[Globalization.CultureInfo]::InvariantCulture,[ref]$number)) { Add-Issue "Invalid numeric input in $($schema.Name), $header`: $value" }
                    }
                }
            }
        } catch { Add-Issue ("CSV error: " + $_.Exception.Message) }
    }
    foreach ($file in Get-WorkspaceFiles $root) {
        $fileCount++
        $relative=Get-RelativePath $root $file.FullName
        if ($relative -match '[^\x00-\x7F]') { $warnings.Add("Non-ASCII path: $relative") }
        if ($file.Length -gt 10MB) { $warnings.Add("Large file; review media/Git policy: $relative") }
        if ($file.Extension -eq '.csv' -and -not $tables.ContainsKey($relative)) { $warnings.Add("CSV has no registered schema: $relative") }
        if ($file.Extension -ne '.md' -or $relative.StartsWith('scripts/templates/')) { continue }
        $body=[IO.File]::ReadAllText($file.FullName,[Text.Encoding]::UTF8)
        $body=[regex]::Replace($body,'(?ms)^\s*```.*?^\s*```[^\r\n]*','')
        foreach ($link in [regex]::Matches($body,'\[[^\]\r\n]+\]\(([^)\r\n]+)\)')) {
            $target=$link.Groups[1].Value.Trim()
            if ($target -match '^(https?:|mailto:|app:)') { continue }
            $linkCount++
            try {
                $parts=@($target -split '#',2)
                $pathPart=[Uri]::UnescapeDataString($parts[0].Trim('<','>'))
                if ($pathPart -eq '') { $resolved=$file.FullName }
                else { $resolved=[IO.Path]::GetFullPath((Join-Path $file.DirectoryName $pathPart)) }
                if (-not $resolved.StartsWith($root+[IO.Path]::DirectorySeparatorChar,[StringComparison]::OrdinalIgnoreCase)) { Add-Issue "Link escapes workspace in $relative`: $target"; continue }
                if (-not (Test-Path -LiteralPath $resolved)) { Add-Issue "Broken link in $relative`: $target"; continue }
                if ($parts.Count -gt 1 -and $parts[1] -and [IO.Path]::GetExtension($resolved) -eq '.md') {
                    $ids=Get-HeadingIds ([IO.File]::ReadAllText($resolved,[Text.Encoding]::UTF8))
                    if ([Uri]::UnescapeDataString($parts[1]) -cnotin $ids) { Add-Issue "Missing heading in $relative`: $target" }
                }
            } catch { Add-Issue "Invalid link in $relative`: $target ($($_.Exception.Message))" }
        }
    }
    # Validate actual catalog and campaign records, including newly created entries.
    if ($tables.ContainsKey('03-PRODUCTS/product-catalog.csv')) {
        $ids=@{}
        foreach ($row in $tables['03-PRODUCTS/product-catalog.csv'].Rows) {
            if ($ids.ContainsKey($row.product_id)) { Add-Issue "Duplicate product ID: $($row.product_id)" }; $ids[$row.product_id]=$true
            if ($row.product_id -cnotmatch '^RG-[A-Z][0-9]{3}$' -or $row.collection_id -cnotmatch '^DROP-[0-9]{3}$') { Add-Issue 'Invalid product/collection code in catalog.'; continue }
            $expected='03-PRODUCTS/collections/'+$row.collection_id+'/products/'+$row.product_id
            if ($row.product_path -cne $expected) { Add-Issue "Unexpected product path for $($row.product_id)"; continue }
            foreach ($template in Get-ChildItem -LiteralPath (Get-SafePath $root 'scripts/templates/product') -File -Recurse) {
                $suffix=Get-RelativePath (Get-SafePath $root 'scripts/templates/product') $template.FullName
                if (-not (Test-Path -LiteralPath (Get-SafePath $root ($expected+'/'+$suffix)) -PathType Leaf)) { Add-Issue "Incomplete product template: $expected/$suffix" }
            }
            $productDirectories=Get-Content -LiteralPath (Get-SafePath $root 'scripts/templates/product-directories.json') -Raw | ConvertFrom-Json
            foreach ($directory in $productDirectories) {
                if (-not (Test-Path -LiteralPath (Get-SafePath $root ($expected+'/'+$directory)) -PathType Container)) { Add-Issue "Missing product album: $expected/$directory" }
            }
            $collectionIndex=Get-SafePath $root ('03-PRODUCTS/collections/'+$row.collection_id+'/README.md')
            if (-not (Test-Path -LiteralPath $collectionIndex) -or -not ([IO.File]::ReadAllText($collectionIndex).Contains('products/'+$row.product_id+'/README.md'))) { Add-Issue "Product missing from collection index: $($row.product_id)" }
        }
        $collectionsRoot=Get-SafePath $root '03-PRODUCTS/collections'
        foreach ($collection in Get-ChildItem -LiteralPath $collectionsRoot -Directory) {
            $products=Get-SafePath $root ('03-PRODUCTS/collections/'+$collection.Name+'/products')
            if (Test-Path -LiteralPath $products) {
                foreach ($product in Get-ChildItem -LiteralPath $products -Directory) { if (-not $ids.ContainsKey($product.Name)) { Add-Issue "Product folder not in catalog: $($product.Name)" } }
            }
        }
    }
    if ($tables.ContainsKey('05-MARKETING/campaign-index.csv')) {
        $codes=@{}; $numbers=@{}
        $indexText=[IO.File]::ReadAllText((Get-SafePath $root '05-MARKETING/campaigns/README.md'))
        foreach ($row in $tables['05-MARKETING/campaign-index.csv'].Rows) {
            if ($row.campaign_code -cnotmatch '^CAM-[0-9]{3}-[A-Z0-9]+(-[A-Z0-9]+)*$') { Add-Issue 'Invalid campaign code.'; continue }
            $number=$row.campaign_code.Substring(0,7)
            if ($codes.ContainsKey($row.campaign_code) -or $numbers.ContainsKey($number)) { Add-Issue "Duplicate campaign number: $number" }
            $codes[$row.campaign_code]=$true; $numbers[$number]=$true
            $expected='05-MARKETING/campaigns/'+$row.campaign_code
            if ($row.campaign_path -cne $expected) { Add-Issue "Unexpected campaign path: $($row.campaign_code)"; continue }
            foreach ($template in Get-ChildItem -LiteralPath (Get-SafePath $root 'scripts/templates/campaign') -File -Recurse) {
                if (-not (Test-Path -LiteralPath (Get-SafePath $root ($expected+'/'+$template.Name)) -PathType Leaf)) { Add-Issue "Incomplete campaign template: $expected/$($template.Name)" }
            }
            $campaignDirectories=Get-Content -LiteralPath (Get-SafePath $root 'scripts/templates/campaign-directories.json') -Raw | ConvertFrom-Json
            foreach ($directory in $campaignDirectories) {
                if (-not (Test-Path -LiteralPath (Get-SafePath $root ($expected+'/'+$directory)) -PathType Container)) { Add-Issue "Missing campaign folder: $expected/$directory" }
            }
            if (-not $indexText.Contains($row.campaign_code+'/README.md')) { Add-Issue "Campaign missing from README index: $($row.campaign_code)" }
            if ($tables.ContainsKey('05-MARKETING/content-calendar.csv') -and @($tables['05-MARKETING/content-calendar.csv'].Rows | Where-Object { $_.campaign_code -eq $row.campaign_code }).Count -eq 0) { Add-Issue "Campaign missing from calendar: $($row.campaign_code)" }
        }
        if ($tables.ContainsKey('05-MARKETING/content-calendar.csv')) {
            $contentIds=@{}
            foreach ($row in $tables['05-MARKETING/content-calendar.csv'].Rows) {
                if ($contentIds.ContainsKey($row.content_id)) { Add-Issue "Duplicate calendar content ID: $($row.content_id)" }; $contentIds[$row.content_id]=$true
                if ($row.campaign_code -and -not $codes.ContainsKey($row.campaign_code)) { Add-Issue "Calendar campaign not registered: $($row.campaign_code)" }
                if ($row.asset_path -and -not (Test-Path -LiteralPath (Get-SafePath $root $row.asset_path))) { Add-Issue "Calendar asset missing: $($row.asset_path)" }
            }
        }
        foreach ($directory in Get-ChildItem -LiteralPath (Get-SafePath $root '05-MARKETING/campaigns') -Directory) { if (-not $codes.ContainsKey($directory.Name)) { Add-Issue "Campaign folder not registered: $($directory.Name)" } }
    }
    # Additional production relationships; existing checks remain unchanged.
    . (Get-SafePath $root 'scripts/higgsfield-audit.ps1')
    foreach ($issue in @(Test-HiggsfieldRecords $root $tables)) { Add-Issue $issue }
    . (Get-SafePath $root 'scripts/gallery-audit.ps1')
    foreach ($issue in @(Test-GalleryRecords $root $tables)) { Add-Issue $issue }
    $reportRoot=Get-SafePath $root '.local/reports'
    [IO.Directory]::CreateDirectory($reportRoot) | Out-Null
    $stamp=(Get-Date -Format 'yyyyMMdd-HHmmss')+'-'+[Guid]::NewGuid().ToString('N').Substring(0,8)
    $report=Join-Path $reportRoot ("audit-$stamp.md")
    $summary="Files scanned: $fileCount; local links checked: $linkCount; CSV schemas validated: $csvCount; errors: $($issues.Count); warnings: $($warnings.Count)."
    $body="# Workspace audit`n`nGenerated: $((Get-Date).ToUniversalTime().ToString('o')) (UTC).`n`n$summary`n`nScope: required files/folders, local inline Markdown paths/headings, registered CSV formats and indexes. Template token links are checked only after onboarding. External URLs, reference-style links, legal/product claims, private storage, reparse/offline files and live services are not verified.`n"
    if ($issues.Count -gt 0) { $body += "`n## Errors`n`n"+(($issues | ForEach-Object {'- '+$_}) -join "`n")+"`n" }
    if ($warnings.Count -gt 0) { $body += "`n## Warnings`n`n"+(($warnings | ForEach-Object {'- '+$_}) -join "`n")+"`n" }
    New-SafeText $report $body
    Write-Output $summary
    Write-Output "Report: $report"
    foreach ($issue in $issues) { Write-Output "ERROR: $issue" }
    if ($issues.Count -gt 0) { exit 1 }
} catch { Write-Error $_ -ErrorAction Continue; exit 1 }
