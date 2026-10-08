#requires -Version 5.1
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][string]$SourcePath,
    [string]$DestinationFolder='', [string]$AssetId='', [string]$DisplayName='',
    [string]$ProductSku='', [string]$Collection='', [string]$Category='unclassified',
    [ValidateSet('ACTUAL_PHOTO','RETOUCHED_COMPOSITE','AI_GENERATED','UNVERIFIED','REAL_FOOTAGE','DESIGN_SOURCE')][string]$Provenance='UNVERIFIED',
    [string]$WorkspaceRoot=''
)
if (-not $WorkspaceRoot) { $WorkspaceRoot=Split-Path -Parent $PSScriptRoot }
. (Join-Path $PSScriptRoot 'common.ps1')
. (Join-Path $PSScriptRoot 'gallery-common.ps1')
$tx=$null
try {
    $root=Get-WorkspaceRoot $WorkspaceRoot
    $tx=Start-WorkspaceTransaction $root 'Import/register one visual asset'
    $source=Get-Item -LiteralPath $SourcePath -Force
    if ($source.PSIsContainer) { throw 'Source must be one accessible local media file.' }
    if (($source.Attributes -band ([IO.FileAttributes]::ReparsePoint -bor [IO.FileAttributes]::Offline)) -ne 0) { throw 'Source is a reparse point/offline. Use an accessible original without symlinks.' }
    # FileInfo has Directory, not Parent. Check its directory ancestry too.
    $dir=$source.Directory
    while ($dir) { if (($dir.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) { throw 'Source directory is a reparse point.' }; $dir=$dir.Parent }
    if ($source.Extension.ToLowerInvariant() -notin ($script:ImageExtensions+$script:VideoExtensions+$script:OtherExtensions)) { throw 'Unsupported source media extension.' }
    if ($source.FullName -match '(?i)(private|confidential|customer|signed.agreement|identity.document|invoice|credential|password|secret|token|session|cookies|[\\/]releases[\\/])') { throw 'Source is in a restricted path or has a sensitive filename.' }
    $catalog=Get-GalleryTable $root '03-PRODUCTS/product-catalog.csv'
    if ($ProductSku) {
        $product=@($catalog.Rows | Where-Object { $_.product_id -eq $ProductSku -or $_.variant_sku -eq $ProductSku })
        if ($product.Count -ne 1) { throw 'Product SKU/organizational ID must resolve to one catalog record.' }
        if ($Collection -and $Collection -ne $product[0].collection_id) { throw 'Collection does not match catalog.' }
        $Collection=$product[0].collection_id
    }
    $copy=$false
    if ($DestinationFolder) {
        $DestinationFolder=$DestinationFolder.Replace('\','/').TrimEnd('/')
        $relative=$DestinationFolder+'/'+$source.Name
        if (-not (Test-GalleryPath $relative)) { throw 'Destination must be an eligible canonical asset folder or intake inbox.' }
        $destination=Get-SafePath $root $relative
        if (Test-Path -LiteralPath $destination) { throw 'Destination already exists; original filenames are preserved and never overwritten.' }
        $copy=$true
    } else {
        if (-not $source.FullName.StartsWith($root+[IO.Path]::DirectorySeparatorChar,[StringComparison]::OrdinalIgnoreCase)) { throw 'External files require DestinationFolder. No source is moved.' }
        $relative=Get-RelativePath $root $source.FullName
        if (-not (Test-LocalMedia $root $relative)) { throw 'Source is not eligible for registration in place.' }
        $destination=$source.FullName
    }
    $manifestRel='12-ASSET-LIBRARY/asset-manifest.csv'; $manifestPath=Get-SafePath $root $manifestRel
    $before=[IO.File]::ReadAllText($manifestPath); $table=Get-GalleryTable $root $manifestRel
    $issues=@(Get-AssetValidationIssues $table.Rows); if ($issues.Count) { throw ($issues -join '; ') }
    if (@($table.Rows | Where-Object { $_.file_path -eq $relative }).Count) { throw 'Path already registered. Edit its existing metadata instead.' }
    $hash=(Get-FileHash -LiteralPath $source.FullName -Algorithm SHA256).Hash
    if (@($table.Rows | Where-Object { $_.sha256 -eq $hash }).Count) { throw 'Identical content already registered; use its canonical file instead of duplicating it.' }
    # Detect an unindexed identical master too, before creating a copy.
    if ($copy) { foreach ($candidate in Get-GalleryFiles $root) {
        if ($candidate.Length -eq $source.Length -and (Get-FileHash -LiteralPath $candidate.FullName -Algorithm SHA256).Hash -eq $hash) { throw 'Identical local media already exists. Register the existing canonical path without DestinationFolder.' }
    } }
    $rows=New-Object 'System.Collections.Generic.List[object]'; foreach ($r in $table.Rows) { $rows.Add($r) }
    $r=$null
    if ($AssetId) {
        $match=@($table.Rows | Where-Object { $_.asset_id -eq $AssetId })
        if ($match.Count -ne 1 -or $match[0].file_path) { throw 'AssetId must identify one unresolved intake row without a source path.' }
        $r=$match[0]
        if (-not $ProductSku) { $ProductSku=$r.product_sku; $Collection=$r.collection }
    } else { $r=New-CsvRecord $table.Headers (Get-AssetDefaults $relative); $rows.Add($r) }
    $r.file_path=$relative; $r.asset_type=Get-AssetType $relative; $r.sha256=$hash; $r.availability='LOCAL'; $r.provenance=$Provenance
    if ($DisplayName) { $r.display_name=$DisplayName }
    if ($ProductSku) { $r.product_sku=$ProductSku; $r.collection=$Collection }
    if ($Category -ne 'unclassified' -or -not $r.category) { $r.category=$Category }
    $r.workflow_state='CLASSIFIED'; $r.last_updated=Get-Date -Format 'yyyy-MM-dd'
    $r.commercial_use_approval='UNKNOWN'; $r.product_accuracy_approval='UNKNOWN'; $r.rights_status='UNKNOWN'; $r.publication_status='UNKNOWN'
    if ($copy) {
        [IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($destination)) | Out-Null
        [IO.File]::Copy($source.FullName,$destination,$false)
        Add-Journal $tx ("COPIED unchanged filename to $relative; source retained")
        if ((Get-FileHash -LiteralPath $destination -Algorithm SHA256).Hash -ne $hash) { throw 'Copy hash mismatch. Copied file retained for inspection.' }
    }
    Set-ManagedFiles $tx @(@{Path=$manifestPath;Before=$before;After=(ConvertTo-CsvText $table.Headers @($rows.ToArray()))})
    Add-Journal $tx 'IMPORTED; gallery refresh follows after releasing lock'
    Write-Output "Registered $($r.asset_id): $relative. Rights and product accuracy remain UNKNOWN."
} catch { Write-Error $_ -ErrorAction Continue; exit 1 }
finally { if ($tx) { $tx.Lock.Dispose() } }
& (Join-Path $PSScriptRoot 'build-asset-gallery.ps1') -WorkspaceRoot $root
