#requires -Version 5.1
[CmdletBinding()]
param(
    [string]$CampaignCode,
    [string]$WorkspaceRoot = ''
)
if ([string]::IsNullOrWhiteSpace($WorkspaceRoot)) { $WorkspaceRoot = Split-Path -Parent $PSScriptRoot }
. (Join-Path $PSScriptRoot 'common.ps1')
$transaction = $null
try {
    if ([string]::IsNullOrWhiteSpace($CampaignCode)) { $CampaignCode = Read-Host 'Campaign code (e.g. CAM-002-PROTOTYPE-STORY)' }
    if ($CampaignCode.Length -gt 64 -or $CampaignCode -cnotmatch '^CAM-[0-9]{3}-[A-Z0-9]+(-[A-Z0-9]+)*$') { throw 'Use CAM-002-PROTOTYPE-STORY: three digits and uppercase hyphenated words, at most 64 characters.' }
    $root = Get-WorkspaceRoot $WorkspaceRoot
    $transaction = Start-WorkspaceTransaction $root "Create campaign $CampaignCode"
    $registerPath = Get-SafePath $root '05-MARKETING/campaign-index.csv'
    $calendarPath = Get-SafePath $root '05-MARKETING/content-calendar.csv'
    $indexPath = Get-SafePath $root '05-MARKETING/campaigns/README.md'
    $registerBefore = [IO.File]::ReadAllText($registerPath,[Text.Encoding]::UTF8)
    $calendarBefore = [IO.File]::ReadAllText($calendarPath,[Text.Encoding]::UTF8)
    $indexBefore = [IO.File]::ReadAllText($indexPath,[Text.Encoding]::UTF8)
    $headers = Get-Schema $root '05-MARKETING/campaign-index.csv'
    $calendarHeaders = Get-Schema $root '05-MARKETING/content-calendar.csv'
    $register = Read-CsvTable $registerPath $headers
    $calendar = Read-CsvTable $calendarPath $calendarHeaders
    $prefix = $CampaignCode.Substring(0,7)
    if (@($register.Rows | Where-Object { $_.campaign_code.StartsWith($prefix + '-') }).Count -gt 0) { throw "Campaign number already registered: $prefix" }
    $campaignRoot = Get-SafePath $root '05-MARKETING/campaigns'
    if (@(Get-ChildItem -LiteralPath $campaignRoot -Directory -Force | Where-Object { $_.Name.StartsWith($prefix + '-') }).Count -gt 0) { throw "Campaign number already has a folder: $prefix" }
    if (@($calendar.Rows | Where-Object { $_.campaign_code -eq $CampaignCode }).Count -gt 0) { throw 'Campaign already appears in the calendar. Reconcile indexes first.' }
    $relative = '05-MARKETING/campaigns/' + $CampaignCode
    $target = Get-SafePath $root $relative
    if (Test-Path -LiteralPath $target) { throw "Campaign folder already exists: $target" }
    $directories = Get-Content -LiteralPath (Get-SafePath $root 'scripts/templates/campaign-directories.json') -Raw | ConvertFrom-Json
    $today = Get-Date -Format 'yyyy-MM-dd'
    New-TemplateTree $root 'campaign' $target @{'@CAMPAIGN_CODE@'=$CampaignCode;'@DATE@'=$today} $directories
    Add-Journal $transaction "CREATED campaign $relative"
    $row = New-CsvRecord $headers @{campaign_code=$CampaignCode;campaign_name='Working campaign - name pending';status='PROPOSAL';owner='UNASSIGNED';campaign_path=$relative;approval_status='NOT APPROVED';last_reviewed=$today}
    $calendarRow = New-CsvRecord $calendarHeaders @{
        content_id="$CampaignCode-BRIEF";campaign_code=$CampaignCode;stage='Planning';language='English draft';timezone='Africa/Lagos';
        asset_path="$relative/campaign-brief.md";owner='UNASSIGNED';approval_status='PROPOSAL';publish_status='UNSCHEDULED';notes='Brief record only; select concepts and deliverables before scheduling'
    }
    Set-ManagedFiles $transaction @(
        [pscustomobject]@{Path=$registerPath;Before=$registerBefore;After=(ConvertTo-CsvText $headers (@($register.Rows)+@($row)))},
        [pscustomobject]@{Path=$calendarPath;Before=$calendarBefore;After=(ConvertTo-CsvText $calendarHeaders (@($calendar.Rows)+@($calendarRow)))},
        [pscustomobject]@{Path=$indexPath;Before=$indexBefore;After=($indexBefore.TrimEnd()+"`n`n- [$CampaignCode]($CampaignCode/README.md) - PROPOSAL; no publishing or spend approved.`n")}
    )
    Add-Journal $transaction 'State: COMPLETE'
    Write-Output "Created: $relative"
    Write-Output 'Updated: campaign-index.csv, campaigns/README.md and content-calendar.csv'
    Write-Output "No publishing or spend performed. Recovery journal: $($transaction.Path)"
} catch {
    if ($null -ne $transaction) { Add-Journal $transaction ("State: FAILED. $($_.Exception.Message)"); Write-Warning "Stop and inspect $($transaction.Path). New folders are retained; no assets were deleted." }
    Write-Error $_ -ErrorAction Continue
    exit 1
} finally { if ($null -ne $transaction) { $transaction.Lock.Dispose() } }
