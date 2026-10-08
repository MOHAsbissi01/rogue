#requires -Version 5.1
[CmdletBinding()]
param([string]$WorkspaceRoot='', [switch]$SkipThumbnails, [switch]$SkipVideoMetadata)
if (-not $WorkspaceRoot) { $WorkspaceRoot=Split-Path -Parent $PSScriptRoot }
. (Join-Path $PSScriptRoot 'common.ps1')
. (Join-Path $PSScriptRoot 'gallery-common.ps1')
$tx=$null
try {
    $root=Get-WorkspaceRoot $WorkspaceRoot
    $tx=Start-WorkspaceTransaction $root 'Build local asset gallery'
    $manifestRel='12-ASSET-LIBRARY/asset-manifest.csv'
    $manifestPath=Get-SafePath $root $manifestRel
    $before=[IO.File]::ReadAllText($manifestPath)
    $table=Get-GalleryTable $root $manifestRel
    $issues=@(Get-AssetValidationIssues $table.Rows)
    if ($issues.Count) { throw ($issues -join '; ') }
    $rows=New-Object 'System.Collections.Generic.List[object]'
    $byPath=@{}
    foreach ($r in $table.Rows) { $rows.Add($r); if ($r.file_path) { $byPath[$r.file_path]=$r } }
    $registerRel='10-OPERATIONS/asset-register.csv'; $registerPath=Get-SafePath $root $registerRel
    $registerBefore=[IO.File]::ReadAllText($registerPath); $register=Get-GalleryTable $root $registerRel
    $registerRows=New-Object 'System.Collections.Generic.List[object]'; $regById=@{}; $regByPath=@{}
    foreach ($r in $register.Rows) {
        if ($regById.ContainsKey($r.asset_id)) { throw "Duplicate register asset ID: $($r.asset_id)" }
        $regById[$r.asset_id]=$r; $registerRows.Add($r)
        if ($r.local_path) {
            if ($regByPath.ContainsKey($r.local_path)) { throw 'Duplicate existing asset register path.' }
            $regByPath[$r.local_path]=$r
        }
    }
    $notes=New-Object 'System.Collections.Generic.List[string]'
    $files=@(Get-GalleryFiles $root | Sort-Object FullName)
    foreach ($f in $files) {
        $rel=Get-RelativePath $root $f.FullName
        if (-not $byPath.ContainsKey($rel)) {
            $values=Get-AssetDefaults $rel
            if ($regByPath.ContainsKey($rel)) { $values.asset_id=$regByPath[$rel].asset_id }
            $r=New-CsvRecord $table.Headers $values; $rows.Add($r); $byPath[$rel]=$r
        }
    }
    $tracked=@{}; $gitKnown=$false
    if ((Get-Command git -ErrorAction SilentlyContinue) -and (Test-Path -LiteralPath (Join-Path $root '.git'))) {
        $paths=@(& git -C $root -c core.quotepath=false ls-files --cached)
        if ($LASTEXITCODE -eq 0) { $gitKnown=$true; foreach ($path in $paths) { $tracked[$path]=$true } }
    }
    $drawing=$false
    if (-not $SkipThumbnails) { try { Add-Type -AssemblyName System.Drawing; $drawing=$true } catch { $notes.Add('System.Drawing unavailable; thumbnails and image dimensions omitted.') } }
    $probe=Get-Command ffprobe -ErrorAction SilentlyContinue
    if (-not $probe -or $SkipVideoMetadata) { $notes.Add('Video duration/dimensions unavailable unless ffprobe is installed and metadata extraction enabled; playback uses browser codecs.') }
    foreach ($r in $rows) {
        if ($regById.ContainsKey($r.asset_id)) {
            $ownership=$regById[$r.asset_id]
            $r.owner=$ownership.owner; $r.backup_status=$ownership.backup_status; $r.backup_reference=$ownership.backup_reference
        }
        $oldHash=$r.sha256; $r.thumbnail_path=''; $r.width=''; $r.height=''; $r.duration_seconds=''; $r.size_bytes=''; $r.modified_utc=''
        if (-not $r.file_path) { $r.availability='UNRESOLVED'; continue }
        if (-not (Test-LocalMedia $root $r.file_path)) { $r.availability='MISSING_OR_OFFLINE'; $r.git_status='UNKNOWN'; continue }
        $f=Get-Item -LiteralPath (Get-SafePath $root $r.file_path)
        $r.availability='LOCAL'; $r.size_bytes=[string]$f.Length; $r.modified_utc=$f.LastWriteTimeUtc.ToString('o'); $r.asset_type=Get-AssetType $r.file_path
        # Hash binds review to exact bytes and detects changes even when file names stay unchanged.
        $r.sha256=(Get-FileHash -LiteralPath $f.FullName -Algorithm SHA256).Hash
        if ($oldHash -and $oldHash -ne $r.sha256) {
            $r.workflow_state='REVIEW'; $r.commercial_use_approval='UNKNOWN'; $r.product_accuracy_approval='UNKNOWN'
            $r.review_notes += ' | Source bytes changed; previous approval invalidated. Review history retained in transaction backup.'
            $r.approval_reference=''; $r.reviewer=''; $r.last_updated=Get-Date -Format 'yyyy-MM-dd'
        }
        $r.git_status='UNKNOWN'
        if ($gitKnown) {
            if ($tracked.ContainsKey($r.file_path)) { $r.git_status='TRACKED' }
            else { & git -C $root check-ignore -q -- $r.file_path; if ($LASTEXITCODE -eq 0) { $r.git_status='IGNORED' } elseif ($LASTEXITCODE -eq 1) { $r.git_status='UNTRACKED' } }
        }
        if ($drawing -and $f.Extension.ToLowerInvariant() -in @('.jpg','.jpeg','.png','.gif','.bmp') -and $f.Length -lt 100MB) {
            $im=$null; $thumb=$null; $gr=$null
            try {
                $im=[Drawing.Image]::FromFile($f.FullName); $r.width=[string]$im.Width; $r.height=[string]$im.Height
                if ([long]$im.Width*$im.Height -gt 60000000) { throw 'Image pixel count exceeds thumbnail limit.' }
                $r.thumbnail_path='12-ASSET-LIBRARY/generated-thumbnails/'+$r.asset_id+'-'+$r.sha256.Substring(0,16)+'.jpg'
                $target=Get-SafePath $root $r.thumbnail_path
                if (-not (Test-Path -LiteralPath $target)) {
                    $scale=[Math]::Min(1.0,640.0/[Math]::Max($im.Width,$im.Height))
                    $thumb=New-Object Drawing.Bitmap([Math]::Max(1,[int]($im.Width*$scale)),[Math]::Max(1,[int]($im.Height*$scale)))
                    $gr=[Drawing.Graphics]::FromImage($thumb); $gr.Clear([Drawing.Color]::FromArgb(24,24,24)); $gr.DrawImage($im,0,0,$thumb.Width,$thumb.Height)
                    $stream=[IO.File]::Open($target,[IO.FileMode]::CreateNew,[IO.FileAccess]::Write,[IO.FileShare]::None)
                    try { $thumb.Save($stream,[Drawing.Imaging.ImageFormat]::Jpeg) } finally { $stream.Dispose() }
                }
            } catch { $r.thumbnail_path=''; $notes.Add("Thumbnail unavailable for $($r.asset_id): $($_.Exception.Message)") }
            finally { if ($gr) { $gr.Dispose() }; if ($thumb) { $thumb.Dispose() }; if ($im) { $im.Dispose() } }
        }
        if ($r.asset_type -eq 'VIDEO' -and $probe -and -not $SkipVideoMetadata) {
            try {
                $info=(& $probe.Source -v quiet -show_entries 'format=duration:stream=width,height' -of json $f.FullName | Out-String | ConvertFrom-Json)
                if ($LASTEXITCODE -eq 0) {
                    if ($info.PSObject.Properties['format'] -and $info.format.PSObject.Properties['duration']) { $r.duration_seconds=[string]$info.format.duration }
                    if ($info.PSObject.Properties['streams']) { foreach ($s in $info.streams) { if ($s.PSObject.Properties['width']) { $r.width=[string]$s.width; $r.height=[string]$s.height; break } } }
                }
            } catch { $notes.Add("Video metadata unavailable: $($r.asset_id)") }
        }
        $rr=$null
        if ($regByPath.ContainsKey($r.file_path)) { $rr=$regByPath[$r.file_path] }
        elseif ($regById.ContainsKey($r.asset_id)) { $rr=$regById[$r.asset_id]; if ($rr.local_path -and $rr.local_path -ne $r.file_path) { throw 'Asset register ID/path conflict.' }; $rr.local_path=$r.file_path }
        else {
            $rr=New-CsvRecord $register.Headers @{asset_id=$r.asset_id;asset_type=$r.asset_type;product_or_campaign=$r.product_sku;local_path=$r.file_path;owner='UNASSIGNED';rights_status='UNKNOWN';backup_status='UNKNOWN';notes='Indexed by asset library; ownership/rights/backup require human evidence.'}
            $registerRows.Add($rr); $regById[$r.asset_id]=$rr; $regByPath[$r.file_path]=$rr
        }
        $r.owner=$rr.owner; $r.backup_status=$rr.backup_status; $r.backup_reference=$rr.backup_reference
        $rr.sha256=$r.sha256; $rr.git_status=$r.git_status
    }
    $issues=@(Get-AssetValidationIssues @($rows.ToArray())); if ($issues.Count) { throw ($issues -join '; ') }
    $products=Get-GalleryTable $root '03-PRODUCTS/product-catalog.csv'
    $campaigns=Get-GalleryTable $root '05-MARKETING/campaign-index.csv'
    $productions=Get-GalleryTable $root '04-CREATIVE-STUDIO/ai-creation/higgsfield/04-VIDEO-PRODUCTIONS/production-index.csv'
    $deliverables=Get-GalleryTable $root '04-CREATIVE-STUDIO/ai-creation/higgsfield/04-VIDEO-PRODUCTIONS/deliverables.csv'
    $documents=New-Object 'System.Collections.Generic.List[object]'
    foreach ($base in @('03-PRODUCTS','04-CREATIVE-STUDIO','05-MARKETING')) {
        foreach ($f in Get-WorkspaceFiles (Get-SafePath $root $base)) {
            $rel=Get-RelativePath $root $f.FullName
            if ($f.Extension -eq '.md' -and (Test-GalleryPath $rel)) { $documents.Add([pscustomobject]@{path=$rel;name=$f.BaseName;folder=(Get-RelativePath $root $f.DirectoryName)}) }
        }
    }
    $albums=New-Object 'System.Collections.Generic.List[object]'
    foreach ($product in $products.Rows) {
        $base=Get-SafePath $root $product.product_path
        $queue=New-Object 'System.Collections.Generic.Queue[string]'; $queue.Enqueue($base)
        while ($queue.Count) { foreach ($d in Get-ChildItem -LiteralPath $queue.Dequeue() -Directory) {
            $rel=Get-RelativePath $root $d.FullName
            if (($d.Attributes -band ([IO.FileAttributes]::ReparsePoint -bor [IO.FileAttributes]::Offline)) -ne 0 -or -not (Test-GalleryPath $rel)) { continue }
            $albums.Add([pscustomobject]@{product_id=$product.product_id;path=$rel;name=$d.Name}); $queue.Enqueue($d.FullName)
        } }
    }
    $payload=[ordered]@{schema_version=1;generated_utc=(Get-Date).ToUniversalTime().ToString('o');assets=@($rows.ToArray() | Sort-Object asset_id);
        products=@($products.Rows);campaigns=@($campaigns.Rows);productions=@($productions.Rows);deliverables=@($deliverables.Rows);
        documents=@($documents.ToArray());albums=@($albums.ToArray());limitations=@($notes.ToArray());scope='Local eligible files only. No external accounts or backups verified.'}
    $jsonRel='dashboard/data/gallery.json'; $jsonPath=Get-SafePath $root $jsonRel
    if (-not (Test-Path -LiteralPath $jsonPath)) { New-SafeText $jsonPath '{}' }
    Set-ManagedFiles $tx @(
        @{Path=$manifestPath;Before=$before;After=(ConvertTo-CsvText $table.Headers $payload.assets)},
        @{Path=$registerPath;Before=$registerBefore;After=(ConvertTo-CsvText $register.Headers @($registerRows.ToArray()))},
        @{Path=$jsonPath;Before=[IO.File]::ReadAllText($jsonPath);After=($payload | ConvertTo-Json -Depth 12)}
    )
    $report=Get-SafePath $root ('12-ASSET-LIBRARY/reports/scan-'+(Get-Date -Format 'yyyyMMdd-HHmmss')+'-'+[Guid]::NewGuid().ToString('N').Substring(0,8)+'.md')
    New-SafeText $report ("# Local asset scan`n`nIndexed records: $($rows.Count). Eligible files found: $($files.Count).`n`nNo originals modified. Reparse points, offline media and restricted paths excluded. Hashing reads local eligible files. OneDrive is not backup evidence.`n`n"+($notes -join "`n"))
    Add-Journal $tx 'COMPLETED'
    Write-Output "Gallery built: $($files.Count) local media files; $($rows.Count) records. Report: $report"
} catch { Write-Error $_ -ErrorAction Continue; exit 1 }
finally { if ($tx) { $tx.Lock.Dispose() } }
