#requires -Version 5.1
[CmdletBinding()]
param(
    [string]$WorkspaceRoot = '',
    [switch]$IncludeHashes
)
if ([string]::IsNullOrWhiteSpace($WorkspaceRoot)) { $WorkspaceRoot = Split-Path -Parent $PSScriptRoot }
. (Join-Path $PSScriptRoot 'common.ps1')
try {
    $root = Get-WorkspaceRoot $WorkspaceRoot
    $extensions = @('.jpg','.jpeg','.png','.webp','.gif','.svg','.tif','.tiff','.heic','.avif','.bmp','.mp4','.mov','.mkv','.avi','.webm','.wav','.mp3','.aiff','.flac','.m4a','.psd','.psb','.ai','.eps','.pdf','.aep','.prproj','.blend')
    $registerPath = Get-SafePath $root '10-OPERATIONS/asset-register.csv'
    $register = Read-CsvTable $registerPath (Get-Schema $root '10-OPERATIONS/asset-register.csv')
    $rows = New-Object 'System.Collections.Generic.List[object]'
    $warnings = New-Object 'System.Collections.Generic.List[string]'
    $gitAvailable = $null -ne (Get-Command git -ErrorAction SilentlyContinue)
    $repoPresent = Test-Path -LiteralPath (Join-Path $root '.git')
    $tracked = @{}
    if ($gitAvailable -and $repoPresent) {
        $trackedPaths = @(& git -C $root -c core.quotepath=false ls-files --cached)
        if ($LASTEXITCODE -ne 0) { $warnings.Add('Git tracking lookup failed; statuses are UNKNOWN.'); $gitAvailable=$false }
        else { foreach ($path in $trackedPaths) { $tracked[$path]=$true } }
    }
    foreach ($file in Get-WorkspaceFiles $root) {
        if ($file.Extension.ToLowerInvariant() -notin $extensions) { continue }
        $relative = Get-RelativePath $root $file.FullName
        if ($relative.StartsWith('12-ASSET-LIBRARY/generated-thumbnails/')) { continue }
        $owner='UNASSIGNED'; $backup='UNKNOWN'; $backupReference=''; $rights='UNKNOWN'
        $matches = @($register.Rows | Where-Object { $_.local_path.Replace('\','/') -eq $relative })
        if ($matches.Count -eq 1) { $owner=$matches[0].owner; $backup=$matches[0].backup_status; $backupReference=$matches[0].backup_reference; $rights=$matches[0].rights_status }
        elseif ($matches.Count -gt 1) { $warnings.Add("Duplicate register paths: $relative") }
        $gitStatus='UNKNOWN'
        if (-not $repoPresent) { $gitStatus='NO LOCAL GIT REPOSITORY' }
        elseif ($gitAvailable) {
            if ($tracked.ContainsKey($relative)) { $gitStatus='TRACKED' }
            else {
                & git -C $root check-ignore -q -- $relative
                if ($LASTEXITCODE -eq 0) { $gitStatus='IGNORED' }
                elseif ($LASTEXITCODE -eq 1) { $gitStatus='UNTRACKED' }
                else { $gitStatus='UNKNOWN'; $warnings.Add("Git ignore check failed: $relative") }
            }
        }
        $hash=''; $hashStatus='NOT REQUESTED'
        if ($IncludeHashes) {
            try { $hash=(Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash; $hashStatus='COMPLETE' }
            catch { $hashStatus='FAILED'; $warnings.Add("Hash unavailable: $relative") }
        }
        $rows.Add([pscustomobject][ordered]@{
            relative_path=$relative; extension=$file.Extension.ToLowerInvariant(); size_bytes=$file.Length;
            modified_utc=$file.LastWriteTimeUtc.ToString('o'); owner=$owner; rights_status=$rights;
            backup_status=$backup; backup_reference=$backupReference; git_status=$gitStatus; location='LOCAL';
            sha256=$hash; hash_status=$hashStatus
        })
    }
    $reportRoot = Get-SafePath $root '.local/reports'
    [IO.Directory]::CreateDirectory($reportRoot) | Out-Null
    $stamp = (Get-Date -Format 'yyyyMMdd-HHmmss') + '-' + [Guid]::NewGuid().ToString('N').Substring(0,8)
    $csvPath=Join-Path $reportRoot ("assets-$stamp.csv")
    $mdPath=Join-Path $reportRoot ("assets-$stamp.md")
    $headers=@('relative_path','extension','size_bytes','modified_utc','owner','rights_status','backup_status','backup_reference','git_status','location','sha256','hash_status')
    New-SafeText $csvPath (ConvertTo-CsvText $headers @($rows.ToArray()))
    $bytes=0L
    foreach ($row in $rows) { $bytes += [long]$row.size_bytes }
    $externalCount=@($register.Rows | Where-Object { $_.git_status -like 'EXTERNAL*' }).Count
    $body="# Asset inventory`n`nGenerated: $((Get-Date).ToUniversalTime().ToString('o')) (UTC).`n`nEligible local media files: $($rows.Count). Total bytes: $bytes. External register records: $externalCount.`n`nData: [$([IO.Path]::GetFileName($csvPath))]($([IO.Path]::GetFileName($csvPath))).`n`nScope excludes private-records, supplier-quotes-private, releases, Git, caches, local reports, reparse points and offline/cloud-only files. External records are not inspected. Owners and backup status are taken from the register; missing records remain UNKNOWN. OneDrive sync is not backup proof. No assets modified.`n"
    if ($warnings.Count -gt 0) { $body += "`n## Warnings`n`n" + (($warnings | ForEach-Object { '- '+$_ }) -join "`n") + "`n" }
    New-SafeText $mdPath $body
    Write-Output "Inventoried $($rows.Count) local media files ($bytes bytes). No assets changed."
    Write-Output "CSV: $csvPath"
    Write-Output "Report: $mdPath"
} catch { Write-Error $_ -ErrorAction Continue; exit 1 }
