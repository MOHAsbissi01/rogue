#requires -Version 5.1
[CmdletBinding()]
param([string]$WorkspaceRoot='', [ValidateRange(1024,65535)][int]$Port=8765, [switch]$NoBrowser, [switch]$SkipBuild)
if (-not $WorkspaceRoot) { $WorkspaceRoot=Split-Path -Parent $PSScriptRoot }
. (Join-Path $PSScriptRoot 'common.ps1')
$root=Get-WorkspaceRoot $WorkspaceRoot
$python=Get-Command python -ErrorAction SilentlyContinue
if (-not $python) { throw 'Python 3 is required for the loopback-only server. No package installation required. See dashboard/README.md.' }
if (-not $SkipBuild) {
    & powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot 'build-asset-gallery.ps1') -WorkspaceRoot $root
    if ($LASTEXITCODE -ne 0) { throw 'Gallery build failed; server not started.' }
}
$argsList=@((Join-Path $PSScriptRoot 'serve-dashboard.py'),'--root',$root,'--port',[string]$Port)
if (-not $NoBrowser) { $argsList += '--open' }
Write-Output "ROGUE dashboard: http://127.0.0.1:$Port/ (Ctrl+C stops the local server)"
& $python.Source @argsList
if ($LASTEXITCODE -ne 0) { throw 'Dashboard server stopped with an error. Check port availability and Python 3.' }
