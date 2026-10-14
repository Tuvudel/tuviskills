[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$UserProfilePath = $env:USERPROFILE,
    [string]$CodexHomePath,
    [string]$BackupRoot,
    [switch]$Remove
)
$ErrorActionPreference = 'Stop'
$encoding = New-Object Text.UTF8Encoding($false, $true)
$profileRoot = [IO.Path]::GetFullPath($UserProfilePath)
if (-not $CodexHomePath) {
    if (-not $PSBoundParameters.ContainsKey('UserProfilePath') -and $env:CODEX_HOME) {
        $CodexHomePath = $env:CODEX_HOME
    } else {
        $CodexHomePath = Join-Path $profileRoot '.codex'
    }
}
$codexDirectory = [IO.Path]::GetFullPath($CodexHomePath)
$targetPath = Join-Path $codexDirectory 'AGENTS.md'
$overridePath = Join-Path $codexDirectory 'AGENTS.override.md'
if ((Test-Path -LiteralPath $overridePath -PathType Leaf) -and
    $encoding.GetString([IO.File]::ReadAllBytes($overridePath)).Trim()) {
    $targetPath = $overridePath
}
if (-not $BackupRoot) { $BackupRoot = Join-Path $PSScriptRoot '.local\personal-engineering-backups' }
$backupDirectory = [IO.Path]::GetFullPath($BackupRoot)
$rulePath = Join-Path $PSScriptRoot 'rules\personal-engineering.md'
$managedStart = '<!-- agent-skills:personal-engineering:start -->'
$managedEnd = '<!-- agent-skills:personal-engineering:end -->'
$existed = Test-Path -LiteralPath $targetPath -PathType Leaf
if ($existed) {
    $originalBytes = [IO.File]::ReadAllBytes($targetPath)
} else {
    $originalBytes = [byte[]]@()
}
$original = $encoding.GetString([byte[]]$originalBytes)
$newline = if ($original.Contains("`r`n")) { "`r`n" } else { "`n" }
$startCount = [regex]::Matches($original, [regex]::Escape($managedStart)).Count
$endCount = [regex]::Matches($original, [regex]::Escape($managedEnd)).Count
if ($startCount -ne $endCount -or $startCount -gt 1) {
    throw 'The managed personal-rule markers are incomplete or duplicated. No file was changed.'
}
$startIndex = $original.IndexOf($managedStart, [StringComparison]::Ordinal)
$endIndex = $original.IndexOf($managedEnd, [StringComparison]::Ordinal)
if ($startCount -eq 1 -and $endIndex -lt $startIndex) {
    throw 'The managed personal-rule markers are reversed. No file was changed.'
}
if ($Remove -and $startCount -eq 0) {
    Write-Output 'No managed personal engineering rule to remove.'
    return
}
$block = ''
if (-not $Remove) {
    $rule = $encoding.GetString([IO.File]::ReadAllBytes($rulePath)).Trim().Replace("`r`n", "`n").Replace("`n", $newline)
    if (-not $rule) { throw 'The personal engineering rule is empty.' }
    $block = $managedStart + $newline + $rule + $newline + $managedEnd
}
if ($startCount -eq 1) {
    $afterBlock = $endIndex + $managedEnd.Length
    $updated = $original.Substring(0, $startIndex) + $block + $original.Substring($afterBlock)
} else {
    $separator = if ($original) { $newline } else { '' }
    $updated = $original + $separator + $block + $newline
}
if ($updated -ceq $original) {
    Write-Output "Personal engineering rule is already current: $targetPath"
    return
}
$operation = if ($Remove) { 'Remove the managed personal engineering block' } else { 'Install or update the managed personal engineering block' }
if ($PSCmdlet.ShouldProcess($targetPath, $operation)) {
    if ($existed) {
        [IO.Directory]::CreateDirectory($backupDirectory) | Out-Null
        $backupName = (Get-Date -Format 'yyyyMMdd-HHmmss') + '-' + [Guid]::NewGuid().ToString('N') + '.md'
        $backupPath = Join-Path $backupDirectory $backupName
        [IO.File]::WriteAllBytes($backupPath, [byte[]]$originalBytes)
        Write-Output "Original guidance backup: $backupPath"
    }
    [IO.Directory]::CreateDirectory($codexDirectory) | Out-Null
    [IO.File]::WriteAllBytes($targetPath, $encoding.GetBytes($updated))
    Write-Output "Personal engineering rule configured: $targetPath"
    Write-Output 'Start a new Codex chat to load the personal rule. Project files and managed plugins were not changed.'
}
