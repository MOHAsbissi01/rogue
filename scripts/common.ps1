# Shared local-only helpers. Windows PowerShell 5.1 compatible.
Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'
$script:Utf8 = New-Object System.Text.UTF8Encoding($false)

function Get-WorkspaceRoot([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path -PathType Container)) { throw "Workspace does not exist: $Path" }
    $root = [IO.Path]::GetFullPath((Resolve-Path -LiteralPath $Path).ProviderPath).TrimEnd('\','/')
    if (-not (Test-Path -LiteralPath (Join-Path $root 'START-HERE.md') -PathType Leaf)) { throw 'Not a prepared ROGUE workspace: START-HERE.md missing.' }
    return $root
}

function Get-SafePath([string]$Root, [string]$Relative) {
    if ([IO.Path]::IsPathRooted($Relative)) { throw "Expected a relative path: $Relative" }
    $full = [IO.Path]::GetFullPath((Join-Path $Root $Relative))
    if (-not $full.StartsWith($Root + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)) { throw "Path escapes workspace: $Relative" }
    $cursor = $full
    while ($cursor -and $cursor.Length -gt $Root.Length) {
        if (Test-Path -LiteralPath $cursor) {
            $item = Get-Item -LiteralPath $cursor -Force
            if (($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) { throw "Refusing reparse point: $cursor" }
        }
        $cursor = [IO.Path]::GetDirectoryName($cursor)
    }
    return $full
}

function New-SafeText([string]$Path, [string]$Text) {
    $parent = [IO.Path]::GetDirectoryName($Path)
    [IO.Directory]::CreateDirectory($parent) | Out-Null
    $stream = [IO.File]::Open($Path, [IO.FileMode]::CreateNew, [IO.FileAccess]::Write, [IO.FileShare]::None)
    try {
        $bytes = $script:Utf8.GetBytes($Text)
        $stream.Write($bytes, 0, $bytes.Length)
    } finally { $stream.Dispose() }
}

function Get-RelativePath([string]$Root, [string]$Path) {
    return $Path.Substring($Root.Length).TrimStart('\','/').Replace('\','/')
}

function Get-WorkspaceFiles([string]$Root, [switch]$IncludePrivate) {
    $queue = New-Object 'System.Collections.Generic.Queue[string]'
    $queue.Enqueue($Root)
    while ($queue.Count -gt 0) {
        $dir = $queue.Dequeue()
        foreach ($item in Get-ChildItem -LiteralPath $dir -Force -ErrorAction Stop) {
            if (($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) { continue }
            if (($item.Attributes -band [IO.FileAttributes]::Offline) -ne 0) { continue }
            if ($item.PSIsContainer) {
                if ($item.Name -in @('.git','.local','node_modules','.cache','__pycache__')) { continue }
                if (-not $IncludePrivate -and $item.Name -in @('private-records','supplier-quotes-private','releases')) { continue }
                $queue.Enqueue($item.FullName)
            } else { Write-Output $item }
        }
    }
}

function Get-Schema([string]$Root, [string]$Relative) {
    $schemas = Get-Content -LiteralPath (Get-SafePath $Root 'scripts/csv-schemas.json') -Raw | ConvertFrom-Json
    $property = $schemas.PSObject.Properties[$Relative]
    if ($null -eq $property) { throw "No CSV schema registered for $Relative" }
    return @($property.Value)
}

function Read-CsvTable([string]$Path, [string[]]$ExpectedHeaders) {
    Add-Type -AssemblyName Microsoft.VisualBasic
    $parser = New-Object Microsoft.VisualBasic.FileIO.TextFieldParser($Path, [Text.Encoding]::UTF8, $true)
    $parser.TextFieldType = [Microsoft.VisualBasic.FileIO.FieldType]::Delimited
    $parser.SetDelimiters(',')
    $parser.HasFieldsEnclosedInQuotes = $true
    $parser.TrimWhiteSpace = $false
    $rows = New-Object 'System.Collections.Generic.List[object]'
    try {
        if ($parser.EndOfData) { throw "Empty CSV: $Path" }
        $headers = $parser.ReadFields()
        if (($headers -join "`0") -cne ($ExpectedHeaders -join "`0")) { throw "CSV headers do not match schema: $Path" }
        while (-not $parser.EndOfData) {
            $fields = $parser.ReadFields()
            if ($fields.Count -ne $headers.Count) { throw "CSV field count mismatch near line $($parser.LineNumber): $Path" }
            $record = [ordered]@{}
            for ($i=0; $i -lt $headers.Count; $i++) { $record[$headers[$i]] = $fields[$i] }
            $rows.Add([pscustomobject]$record)
        }
    } finally { $parser.Close() }
    return [pscustomobject]@{ Headers = @($headers); Rows = @($rows.ToArray()) }
}

function New-CsvRecord([string[]]$Headers, [hashtable]$Values) {
    $record = [ordered]@{}
    foreach ($header in $Headers) {
        if ($Values.ContainsKey($header)) { $record[$header] = $Values[$header] } else { $record[$header] = '' }
    }
    return [pscustomobject]$record
}

function ConvertTo-CsvText([string[]]$Headers, [object[]]$Rows) {
    $lines = New-Object 'System.Collections.Generic.List[string]'
    $lines.Add((($Headers | ForEach-Object { '"' + $_.Replace('"','""') + '"' }) -join ','))
    foreach ($row in $Rows) {
        $cells = foreach ($header in $Headers) { '"' + ([string]$row.$header).Replace('"','""') + '"' }
        $lines.Add(($cells -join ','))
    }
    return ($lines -join "`r`n") + "`r`n"
}

function Start-WorkspaceTransaction([string]$Root, [string]$Operation) {
    $local = Get-SafePath $Root '.local'
    [IO.Directory]::CreateDirectory($local) | Out-Null
    $lockPath = Get-SafePath $Root '.local/workspace.lock'
    try { $lock = [IO.File]::Open($lockPath,[IO.FileMode]::OpenOrCreate,[IO.FileAccess]::ReadWrite,[IO.FileShare]::None) }
    catch { throw 'Another workspace script holds the lock. Wait for it to finish; do not remove an active lock.' }
    try {
        $id = (Get-Date -Format 'yyyyMMdd-HHmmss') + '-' + [Guid]::NewGuid().ToString('N').Substring(0,8)
        $path = Get-SafePath $Root ('.local/transactions/' + $id)
        [IO.Directory]::CreateDirectory($path) | Out-Null
        New-SafeText (Join-Path $path 'journal.txt') ("Operation: $Operation`r`nState: STARTED`r`n")
        return [pscustomobject]@{ Lock=$lock; Path=$path }
    } catch { $lock.Dispose(); throw }
}

function Add-Journal($Transaction, [string]$Message) {
    [IO.File]::AppendAllText((Join-Path $Transaction.Path 'journal.txt'), $Message + "`r`n", $script:Utf8)
}

function Set-ManagedFiles($Transaction, [object[]]$Changes) {
    # Back up and stage all managed indexes before replacing any. Never touches media.
    $prepared = New-Object 'System.Collections.Generic.List[object]'
    $applied = New-Object 'System.Collections.Generic.List[object]'
    try {
        $number = 0
        foreach ($change in $Changes) {
            $number++
            $path = $change.Path
            if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Managed index missing: $path" }
            $old = [IO.File]::ReadAllText($path, [Text.Encoding]::UTF8)
            if ($old -cne $change.Before) { throw "Index changed during operation; refusing to overwrite: $path" }
            $backup = Join-Path $Transaction.Path ("index-$number.before")
            [IO.File]::Copy($path,$backup,$false)
            $stage = Join-Path $Transaction.Path ("index-$number.after")
            New-SafeText $stage $change.After
            $prepared.Add([pscustomobject]@{ Path=$path; Before=$old; After=$change.After; Backup=$backup; Stage=$stage })
            Add-Journal $Transaction ("BACKUP $path => $backup")
        }
        foreach ($change in $prepared) {
            if ([IO.File]::ReadAllText($change.Path,[Text.Encoding]::UTF8) -cne $change.Before) { throw "Concurrent edit detected: $($change.Path)" }
            $replacedBackup = Join-Path $Transaction.Path ([Guid]::NewGuid().ToString('N') + '.replaced')
            [IO.File]::Replace($change.Stage, $change.Path, $replacedBackup)
            $applied.Add($change)
            Add-Journal $Transaction ("UPDATED $($change.Path)")
        }
    } catch {
        $failure = $_
        foreach ($change in $applied) {
            try {
                if ([IO.File]::ReadAllText($change.Path,[Text.Encoding]::UTF8) -ceq $change.After) {
                    $restore = Join-Path $Transaction.Path ([Guid]::NewGuid().ToString('N') + '.restore')
                    [IO.File]::Copy($change.Backup,$restore,$false)
                    $rollbackBackup = Join-Path $Transaction.Path ([Guid]::NewGuid().ToString('N') + '.rollback')
                    [IO.File]::Replace($restore,$change.Path,$rollbackBackup)
                    Add-Journal $Transaction ("RESTORED $($change.Path)")
                } else { Add-Journal $Transaction ("MANUAL RECOVERY: concurrent edit retained at $($change.Path)") }
            } catch { Add-Journal $Transaction ("MANUAL RECOVERY: $($change.Path): $($_.Exception.Message)") }
        }
        throw $failure
    }
}

function New-TemplateTree([string]$Root,[string]$Template,[string]$Target,[hashtable]$Tokens,[string[]]$Directories) {
    $source = Get-SafePath $Root ('scripts/templates/' + $Template)
    foreach ($file in Get-ChildItem -LiteralPath $source -File -Recurse -Force) {
        if (($file.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) { throw 'Template reparse points are not supported.' }
        $relative = Get-RelativePath $source $file.FullName
        $destination = Get-SafePath $Root ((Get-RelativePath $Root $Target) + '/' + $relative)
        $body = [IO.File]::ReadAllText($file.FullName,[Text.Encoding]::UTF8)
        foreach ($key in $Tokens.Keys) { $body = $body.Replace($key,[string]$Tokens[$key]) }
        New-SafeText $destination $body
    }
    foreach ($directory in $Directories) {
        $path = Get-SafePath $Root ((Get-RelativePath $Root $Target) + '/' + $directory)
        [IO.Directory]::CreateDirectory($path) | Out-Null
        New-SafeText (Join-Path $path '.gitkeep') ''
    }
}
