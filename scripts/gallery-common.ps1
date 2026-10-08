# Local gallery helpers; dot-source after common.ps1. Windows PowerShell 5.1.
$script:GalleryRoots = @('02-BRAND-IDENTITY','03-PRODUCTS','04-CREATIVE-STUDIO','05-MARKETING','12-ASSET-LIBRARY/import-inbox')
$script:ImageExtensions = @('.jpg','.jpeg','.png','.webp','.gif','.bmp','.tif','.tiff','.heic','.avif','.svg')
$script:VideoExtensions = @('.mp4','.mov','.webm','.mkv','.avi','.m4v')
$script:OtherExtensions = @('.pdf','.psd','.psb','.ai','.eps','.aep','.prproj','.wav','.mp3','.flac','.m4a')
function Test-GalleryPath([string]$Relative) {
    if (-not $Relative -or $Relative.Contains('\') -or $Relative.Contains(':')) { return $false }
    if (@($Relative.Split('/') | Where-Object { $_ -in @('..','.','') }).Count) { return $false }
    if ($Relative -match '(?i)(private|confidential|customer|signed.agreement|identity.document|invoice|credential|password|secret|token|session|cookies|(^|/)(releases|\.git|\.local|node_modules|\.cache)(/|$))') { return $false }
    foreach ($base in $script:GalleryRoots) { if ($Relative.StartsWith($base+'/',[StringComparison]::OrdinalIgnoreCase)) { return $true } }
    return $false
}
function Test-LocalMedia([string]$Root,[string]$Relative) {
    if (-not (Test-GalleryPath $Relative)) { return $false }
    if ([IO.Path]::GetExtension($Relative).ToLowerInvariant() -notin ($script:ImageExtensions+$script:VideoExtensions+$script:OtherExtensions)) { return $false }
    $full=Get-SafePath $Root $Relative
    if (-not (Test-Path -LiteralPath $full -PathType Leaf)) { return $false }
    $item=Get-Item -LiteralPath $full -Force
    if (($item.Attributes -band [IO.FileAttributes]::Offline) -ne 0) { return $false }
    return $true
}
function Get-GalleryFiles([string]$Root) {
    foreach ($base in $script:GalleryRoots) {
        $dir=Get-SafePath $Root $base
        if (-not (Test-Path -LiteralPath $dir)) { continue }
        $queue=New-Object 'System.Collections.Generic.Queue[string]'; $queue.Enqueue($dir)
        while ($queue.Count) {
            foreach ($item in Get-ChildItem -LiteralPath $queue.Dequeue() -Force) {
                $relative=Get-RelativePath $Root $item.FullName
                if (-not (Test-GalleryPath $relative)) { continue }
                if (($item.Attributes -band ([IO.FileAttributes]::ReparsePoint -bor [IO.FileAttributes]::Offline)) -ne 0) { continue }
                if ($item.PSIsContainer) { $queue.Enqueue($item.FullName) }
                elseif ($item.Extension.ToLowerInvariant() -in ($script:ImageExtensions+$script:VideoExtensions+$script:OtherExtensions)) { $item }
            }
        }
    }
}
function Get-AssetId([string]$Path) {
    $sha=[Security.Cryptography.SHA256]::Create()
    try { return 'AST-'+([BitConverter]::ToString($sha.ComputeHash([Text.Encoding]::UTF8.GetBytes($Path.ToLowerInvariant()))).Replace('-','').Substring(0,20)) }
    finally { $sha.Dispose() }
}
function Get-AssetType([string]$Path) {
    $ext=[IO.Path]::GetExtension($Path).ToLowerInvariant()
    if ($ext -in $script:ImageExtensions) { return 'IMAGE' }
    if ($ext -in $script:VideoExtensions) { return 'VIDEO' }
    return 'OTHER'
}
function Get-GalleryTable([string]$Root,[string]$Path) { Read-CsvTable (Get-SafePath $Root $Path) (Get-Schema $Root $Path) }
function Get-AssetDefaults([string]$Path) {
    $values=@{asset_id=(Get-AssetId $Path);file_path=$Path;display_name=[IO.Path]::GetFileNameWithoutExtension($Path);asset_type=(Get-AssetType $Path);
        provenance='UNVERIFIED';rights_status='UNKNOWN';commercial_use_approval='UNKNOWN';product_accuracy_approval='UNKNOWN';
        publication_status='UNKNOWN';workflow_state='INBOX';last_updated=(Get-Date -Format 'yyyy-MM-dd');category='unclassified';
        owner='UNASSIGNED';backup_status='UNKNOWN';git_status='UNKNOWN';availability='LOCAL'}
    if ($Path -match '/collections/(DROP-\d{3})/products/(RG-[A-Z]\d{3})/') { $values.collection=$Matches[1]; $values.product_sku=$Matches[2] }
    if ($Path -match '/(CAM-\d{3}-[A-Z0-9-]+)/') { $values.campaign_id=$Matches[1] }
    if ($Path -match '/(HV-\d{3})-[^/]+/') { $values.higgsfield_production_id=$Matches[1] }
    # Folder classification describes location only, never rights or approval.
    foreach ($cat in @('front','back','details','fit','lifestyle','editorial','storyboards','raw','generated-scenes','selected','edited','final-exports','exports','mockups')) {
        if ($Path -match ('/'+[regex]::Escape($cat)+'/')) { $values.category=$cat }
    }
    return $values
}
function Get-AssetValidationIssues($Rows) {
    $ids=@{}; $paths=@{}
    foreach ($r in $Rows) {
        if ($r.asset_id -cnotmatch '^(AST|ASSET)-[A-Z0-9-]+$') { "Invalid asset ID: $($r.asset_id)" }
        if ($ids.ContainsKey($r.asset_id)) { "Duplicate asset ID: $($r.asset_id)" }; $ids[$r.asset_id]=$true
        if ($r.file_path) {
            if (-not (Test-GalleryPath $r.file_path)) { "Unsafe/excluded asset path: $($r.asset_id)" }
            if ($paths.ContainsKey($r.file_path)) { "Duplicate asset path: $($r.file_path)" }; $paths[$r.file_path]=$true
        }
        if ($r.workflow_state -notin @('INBOX','CLASSIFIED','REVIEW','APPROVED','PUBLISHED','ARCHIVED')) { "Invalid workflow state: $($r.asset_id)" }
        if ($r.provenance -notin @('ACTUAL_PHOTO','RETOUCHED_COMPOSITE','AI_GENERATED','UNVERIFIED','REAL_FOOTAGE','DESIGN_SOURCE')) { "Invalid provenance: $($r.asset_id)" }
        if ($r.workflow_state -in @('APPROVED','PUBLISHED')) {
            if ($r.commercial_use_approval -ne 'APPROVED' -or $r.product_accuracy_approval -ne 'APPROVED' -or -not $r.reviewer -or -not $r.approval_reference -or -not $r.file_path -or -not $r.sha256) { "Approval evidence incomplete: $($r.asset_id)" }
        }
        if ($r.workflow_state -eq 'PUBLISHED' -and ($r.publication_status -ne 'PUBLISHED' -or -not $r.publication_reference)) { "Publication evidence incomplete: $($r.asset_id)" }
    }
}
