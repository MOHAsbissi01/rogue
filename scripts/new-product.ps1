#requires -Version 5.1
[CmdletBinding()]
param(
    [string]$ProductId,
    [string]$Collection,
    [string]$WorkspaceRoot = ''
)
if ([string]::IsNullOrWhiteSpace($WorkspaceRoot)) { $WorkspaceRoot = Split-Path -Parent $PSScriptRoot }
. (Join-Path $PSScriptRoot 'common.ps1')
$transaction = $null
try {
    if ([string]::IsNullOrWhiteSpace($ProductId)) { $ProductId = Read-Host 'Product ID (e.g. RG-H002)' }
    if ([string]::IsNullOrWhiteSpace($Collection)) { $Collection = Read-Host 'Collection (e.g. DROP-001)' }
    if ($ProductId -cnotmatch '^RG-[A-Z][0-9]{3}$') { throw 'Product ID must match RG-H002: RG-, one uppercase letter, three digits.' }
    if ($Collection -cnotmatch '^DROP-[0-9]{3}$') { throw 'Collection must match DROP-001.' }
    $root = Get-WorkspaceRoot $WorkspaceRoot
    $transaction = Start-WorkspaceTransaction $root "Create product $ProductId in $Collection"
    $catalogPath = Get-SafePath $root '03-PRODUCTS/product-catalog.csv'
    $catalogBefore = [IO.File]::ReadAllText($catalogPath,[Text.Encoding]::UTF8)
    $headers = Get-Schema $root '03-PRODUCTS/product-catalog.csv'
    $catalog = Read-CsvTable $catalogPath $headers
    if (@($catalog.Rows | Where-Object { $_.product_id -eq $ProductId }).Count -gt 0) { throw "Product ID already registered: $ProductId" }
    $collectionsRoot = Get-SafePath $root '03-PRODUCTS/collections'
    foreach ($existingCollection in Get-ChildItem -LiteralPath $collectionsRoot -Directory -Force) {
        $existingProduct = Get-SafePath $root ('03-PRODUCTS/collections/' + $existingCollection.Name + '/products/' + $ProductId)
        if (Test-Path -LiteralPath $existingProduct) { throw "Existing product folder uses $ProductId" }
    }
    $collectionRelative = '03-PRODUCTS/collections/' + $Collection
    $collectionPath = Get-SafePath $root $collectionRelative
    $relative = $collectionRelative + '/products/' + $ProductId
    $target = Get-SafePath $root $relative
    if (Test-Path -LiteralPath $target) { throw "Product folder already exists: $target" }
    $collectionReadme = Get-SafePath $root ($collectionRelative + '/README.md')
    $collectionExists = Test-Path -LiteralPath $collectionPath
    if ($collectionExists -and -not (Test-Path -LiteralPath $collectionReadme -PathType Leaf)) { throw 'Existing collection has no README. Review it manually before adding products.' }
    if (-not $collectionExists) {
        [IO.Directory]::CreateDirectory($collectionPath) | Out-Null
        $intro = "# $Collection`n`nOwner: UNASSIGNED. Status: PROPOSAL. Last reviewed: $(Get-Date -Format 'yyyy-MM-dd').`n`nOrganizational collection only. Commercial name, story, quantity and launch are UNKNOWN.`n`n## Product index`n"
        New-SafeText $collectionReadme $intro
        foreach ($name in @('collection-concept.md','collection-story.md')) {
            New-SafeText (Join-Path $collectionPath $name) "# $Collection working $($name.Replace('.md',''))`n`nPROPOSAL - owner UNASSIGNED; no approval recorded. Last reviewed: $(Get-Date -Format 'yyyy-MM-dd').`n`nPurpose: connect an actual product and audience need to a truthful collection idea. Facts, evidence and final wording are UNKNOWN. Review original design files and interviews before choosing a direction.`n`nNext action: draft the intended wearing context, observable design idea, evidence gaps and founder decision. Do not copy another collection's history or approvals.`n`nRelated: [Collection index](README.md).`n"
        }
        Add-Journal $transaction "CREATED collection $collectionRelative"
    }
    $indexBefore = [IO.File]::ReadAllText($collectionReadme,[Text.Encoding]::UTF8)
    $directories = Get-Content -LiteralPath (Get-SafePath $root 'scripts/templates/product-directories.json') -Raw | ConvertFrom-Json
    $today = Get-Date -Format 'yyyy-MM-dd'
    New-TemplateTree $root 'product' $target @{'@PRODUCT_ID@'=$ProductId;'@COLLECTION@'=$Collection;'@DATE@'=$today} $directories
    Add-Journal $transaction "CREATED product $relative"
    $row = New-CsvRecord $headers @{
        product_id=$ProductId; collection_id=$Collection; base_sku=$ProductId; story_path="$relative/design-story.md";
        measurement_path="$relative/sizing.md"; sample_status='UNKNOWN: no sample verified'; quality_status='NOT VERIFIED';
        launch_status='NOT APPROVED'; owner='UNASSIGNED'; approval_status='NEEDS REVIEW'; last_reviewed=$today; product_path=$relative
    }
    $catalogAfter = ConvertTo-CsvText $headers (@($catalog.Rows) + @($row))
    $indexAfter = $indexBefore.TrimEnd() + "`n`n- [$ProductId](products/$ProductId/README.md) - organizational record; specifications and sample status unknown.`n"
    Set-ManagedFiles $transaction @(
        [pscustomobject]@{Path=$catalogPath;Before=$catalogBefore;After=$catalogAfter},
        [pscustomobject]@{Path=$collectionReadme;Before=$indexBefore;After=$indexAfter}
    )
    Add-Journal $transaction 'State: COMPLETE'
    Write-Output "Created: $relative"
    Write-Output "Updated: 03-PRODUCTS/product-catalog.csv and $collectionRelative/README.md"
    Write-Output "No physical sample, stock, price or approval is implied. Recovery journal: $($transaction.Path)"
} catch {
    if ($null -ne $transaction) { Add-Journal $transaction ("State: FAILED. $($_.Exception.Message)"); Write-Warning "Stop and inspect $($transaction.Path). New folders are retained; no assets were deleted." }
    Write-Error $_ -ErrorAction Continue
    exit 1
} finally { if ($null -ne $transaction) { $transaction.Lock.Dispose() } }
