#requires -Version 5.1
[CmdletBinding()]
param(
    [string]$ProductionName,
    [string]$ProductionId,
    [string]$ProductSku,
    [string]$CampaignId,
    [string]$Platform,
    [string]$ContentType,
    [string]$Objective,
    [string]$WorkspaceRoot = ''
)
if ([string]::IsNullOrWhiteSpace($WorkspaceRoot)) { $WorkspaceRoot = Split-Path -Parent $PSScriptRoot }
. (Join-Path $PSScriptRoot 'common.ps1')
$transaction = $null
try {
    if ([string]::IsNullOrWhiteSpace($ProductionName)) { $ProductionName = Read-Host 'Production name (1-60 ASCII letters/numbers/spaces/apostrophes/hyphens)' }
    if ([string]::IsNullOrWhiteSpace($ProductionId)) { $ProductionId = Read-Host 'Production ID (HV-002; HV-001 is reserved)' }
    if ([string]::IsNullOrWhiteSpace($ProductSku)) { $ProductSku = Read-Host 'Related registered SKU or organizational product ID (e.g. RG-H001)' }
    if ([string]::IsNullOrWhiteSpace($CampaignId)) { $CampaignId = Read-Host 'Associated registered campaign ID (e.g. CAM-001-FIRST-DROP)' }
    if ([string]::IsNullOrWhiteSpace($Platform)) { $Platform = Read-Host 'Platform: Instagram, TikTok, Instagram+TikTok, Website, Multi-platform' }
    if ([string]::IsNullOrWhiteSpace($ContentType)) { $ContentType = Read-Host 'Content type: Organic, Paid, Hybrid' }
    if ([string]::IsNullOrWhiteSpace($Objective)) { $Objective = Read-Host 'Objective: Brand awareness, Product launch, Emotional storytelling, Organic engagement, Paid advertising, Product conversion' }
    if ($ProductionName -cnotmatch "^[A-Za-z0-9][A-Za-z0-9 '-]{0,59}$" -or $ProductionName -ne $ProductionName.Trim()) { throw 'Invalid production name. Use 1-60 ASCII letters/numbers/spaces/apostrophes/hyphens without leading/trailing space.' }
    if ($ProductionId -cnotmatch '^HV-[0-9]{3}$') { throw 'Production ID must match HV-002.' }
    if ($ProductSku -cnotmatch '^RG-[A-Z][0-9]{3}(-[A-Z0-9]+){0,2}$') { throw 'Invalid product SKU or organizational ID.' }
    if ($CampaignId -cnotmatch '^CAM-[0-9]{3}-[A-Z0-9]+(-[A-Z0-9]+)*$') { throw 'Invalid campaign ID.' }
    $root = Get-WorkspaceRoot $WorkspaceRoot
    $structurePath = Get-SafePath $root 'scripts/higgsfield-production-structure.json'
    $structure = Get-Content -LiteralPath $structurePath -Raw -Encoding UTF8 | ConvertFrom-Json
    if ($Platform -cnotin $structure.platforms) { throw 'Platform is not one of the documented choices.' }
    if ($ContentType -cnotin $structure.content_types) { throw 'Content type must be Organic, Paid or Hybrid.' }
    if ($Objective -cnotin $structure.objectives) { throw 'Objective is not one of the documented choices.' }
    $transaction = Start-WorkspaceTransaction $root "Create Higgsfield production $ProductionId"
    $catalog = Read-CsvTable (Get-SafePath $root '03-PRODUCTS/product-catalog.csv') (Get-Schema $root '03-PRODUCTS/product-catalog.csv')
    $products = @($catalog.Rows | Where-Object { $_.product_id -ceq $ProductSku -or ($_.variant_sku -and $_.variant_sku -ceq $ProductSku) })
    if ($products.Count -ne 1) { throw 'Product must match exactly one registered product ID or variant SKU. Register the product first.' }
    $product = $products[0]
    if (-not (Test-Path -LiteralPath (Get-SafePath $root ($product.product_path + '/README.md')) -PathType Leaf)) { throw 'Registered product record is missing.' }
    $campaigns = Read-CsvTable (Get-SafePath $root '05-MARKETING/campaign-index.csv') (Get-Schema $root '05-MARKETING/campaign-index.csv')
    $campaign = @($campaigns.Rows | Where-Object { $_.campaign_code -ceq $CampaignId })
    if ($campaign.Count -ne 1) { throw 'Campaign must match exactly one registered campaign. Register the campaign first.' }
    if (-not (Test-Path -LiteralPath (Get-SafePath $root ($campaign[0].campaign_path + '/README.md')) -PathType Leaf)) { throw 'Registered campaign record is missing.' }
    $base = [string]$structure.base_path
    $indexRelative = $base + '/production-index.csv'
    $deliverableRelative = $base + '/deliverables.csv'
    $calendarRelative = '05-MARKETING/content-calendar.csv'
    $indexPath = Get-SafePath $root $indexRelative
    $deliverablePath = Get-SafePath $root $deliverableRelative
    $calendarPath = Get-SafePath $root $calendarRelative
    $schemaPath = Get-SafePath $root 'scripts/csv-schemas.json'
    $indexBefore = [IO.File]::ReadAllText($indexPath,[Text.Encoding]::UTF8)
    $deliverableBefore = [IO.File]::ReadAllText($deliverablePath,[Text.Encoding]::UTF8)
    $calendarBefore = [IO.File]::ReadAllText($calendarPath,[Text.Encoding]::UTF8)
    $schemaBefore = [IO.File]::ReadAllText($schemaPath,[Text.Encoding]::UTF8)
    $indexHeaders = Get-Schema $root $indexRelative
    $deliverableHeaders = Get-Schema $root $deliverableRelative
    $calendarHeaders = Get-Schema $root $calendarRelative
    $index = Read-CsvTable $indexPath $indexHeaders
    $deliverables = Read-CsvTable $deliverablePath $deliverableHeaders
    $calendar = Read-CsvTable $calendarPath $calendarHeaders
    if (@($index.Rows | Where-Object { $_.production_id -ceq $ProductionId }).Count -gt 0) { throw "Production ID already registered: $ProductionId" }
    foreach ($folder in Get-ChildItem -LiteralPath (Get-SafePath $root $base) -Directory -Force) {
        if ($folder.Name -eq $ProductionId -or $folder.Name.StartsWith($ProductionId+'-',[StringComparison]::OrdinalIgnoreCase)) { throw "Existing production folder uses $ProductionId" }
    }
    if (@($deliverables.Rows | Where-Object { $_.production_id -ceq $ProductionId }).Count -gt 0) { throw 'Production already has deliverable records. Reconcile before onboarding.' }
    $deliverableId = $ProductionId + '-A'
    if (@($calendar.Rows | Where-Object { $_.content_id -ceq $deliverableId }).Count -gt 0) { throw 'Content ID already exists in the calendar.' }
    $slug = ($ProductionName.ToUpperInvariant() -replace '[^A-Z0-9]+','-').Trim('-')
    $relative = $base + '/' + $ProductionId + '-' + $slug
    $target = Get-SafePath $root $relative
    if (Test-Path -LiteralPath $target) { throw "Destination already exists: $target" }
    $templatePath = Get-SafePath $root ([string]$structure.template_path)
    # Validate every expected input/template path and CSV before creating any destination content.
    foreach ($name in $structure.files) {
        $source = Get-SafePath $root ($structure.template_path + '/' + $name)
        if (-not (Test-Path -LiteralPath $source -PathType Leaf)) { throw "Required production template missing: $name" }
        Get-SafePath $root ($relative + '/' + $name) | Out-Null
    }
    foreach ($name in $structure.directories) { Get-SafePath $root ($relative + '/' + $name) | Out-Null }
    $logSchema = Get-Schema $root ($structure.template_path + '/generation-log.csv')
    Read-CsvTable (Join-Path $templatePath 'generation-log.csv') $logSchema | Out-Null
    $schemas = $schemaBefore | ConvertFrom-Json
    $logRelative = $relative + '/generation-log.csv'
    if ($null -ne $schemas.PSObject.Properties[$logRelative]) { throw 'A generation-log schema already exists for this destination.' }
    $skuStatus = 'REGISTERED VARIANT - commercial reference approval still required'
    if ($ProductSku -ceq $product.product_id) { $skuStatus = 'ORGANIZATIONAL ID - commercial SKU unresolved' }
    $today = Get-Date -Format 'yyyy-MM-dd'
    $tokens = [ordered]@{
        '@PRODUCTION_ID@'=$ProductionId; '@PRODUCTION_NAME@'=$ProductionName; '@PRODUCT_SKU@'=$ProductSku;
        '@SKU_STATUS@'=$skuStatus; '@CAMPAIGN_ID@'=$CampaignId; '@PLATFORM@'=$Platform; '@CONTENT_TYPE@'=$ContentType;
        '@OBJECTIVE@'=$Objective; '@DATE@'=$today
    }
    foreach ($name in $structure.files) {
        $source = Get-SafePath $root ($structure.template_path + '/' + $name)
        $body = [IO.File]::ReadAllText($source,[Text.Encoding]::UTF8)
        foreach ($key in $tokens.Keys) { $body = $body.Replace($key,[string]$tokens[$key]) }
        New-SafeText (Get-SafePath $root ($relative + '/' + $name)) $body
    }
    foreach ($name in $structure.directories) {
        New-SafeText (Get-SafePath $root ($relative + '/' + $name + '/.gitkeep')) ''
    }
    Add-Journal $transaction "CREATED production $relative"
    $row = New-CsvRecord $indexHeaders @{
        production_id=$ProductionId;production_name=$ProductionName;product_id=$product.product_id;product_sku=$ProductSku;
        sku_status=$skuStatus;campaign_id=$CampaignId;platform=$Platform;content_type=$ContentType;primary_objective=$Objective;
        state='IDEA';blocker='References capabilities costs rights authorization and finishing owner require review';owner='UNASSIGNED';
        production_path=$relative;approval_status='NOT APPROVED';last_reviewed=$today
    }
    $delivery = New-CsvRecord $deliverableHeaders @{
        deliverable_id=$deliverableId;production_id=$ProductionId;campaign_id=$CampaignId;content_id=$deliverableId;
        platform=$Platform;content_type=$ContentType;brief_path="$relative/creative-brief.md";state='IDEA';notes='PROPOSAL; no media generation approval or publication'
    }
    $cal = New-CsvRecord $calendarHeaders @{
        content_id=$deliverableId;campaign_code=$CampaignId;concept_id=$deliverableId;stage='Planning';channel=$Platform;
        format='Complete video PROPOSAL';language='English draft';timezone='Africa/Lagos';asset_path="$relative/creative-brief.md";
        owner='UNASSIGNED';approval_status='PROPOSAL';publish_status='UNSCHEDULED';notes="Production $ProductionId; $ContentType; $Objective; no generation authorized"
    }
    $schemas | Add-Member -MemberType NoteProperty -Name $logRelative -Value @($logSchema)
    $schemaAfter = ($schemas | ConvertTo-Json -Depth 8) + "`n"
    Set-ManagedFiles $transaction @(
        [pscustomobject]@{Path=$indexPath;Before=$indexBefore;After=(ConvertTo-CsvText $indexHeaders (@($index.Rows)+@($row)))},
        [pscustomobject]@{Path=$deliverablePath;Before=$deliverableBefore;After=(ConvertTo-CsvText $deliverableHeaders (@($deliverables.Rows)+@($delivery)))},
        [pscustomobject]@{Path=$calendarPath;Before=$calendarBefore;After=(ConvertTo-CsvText $calendarHeaders (@($calendar.Rows)+@($cal)))},
        [pscustomobject]@{Path=$schemaPath;Before=$schemaBefore;After=$schemaAfter}
    )
    Add-Journal $transaction 'State: COMPLETE'
    Write-Output "Created: $relative"
    Write-Output 'Updated: production index, deliverables register, content calendar and generation-log CSV schema.'
    Write-Output "State: IDEA. No generations, credits, uploads, approvals or publishing. Recovery journal: $($transaction.Path)"
} catch {
    if ($null -ne $transaction) { Add-Journal $transaction ("State: FAILED. $($_.Exception.Message)"); Write-Warning "Inspect $($transaction.Path). New folders are retained for recovery; no assets are deleted." }
    Write-Error $_ -ErrorAction Continue
    exit 1
} finally { if ($null -ne $transaction) { $transaction.Lock.Dispose() } }
