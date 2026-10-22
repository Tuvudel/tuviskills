# One-time setup of the skills auto-update on Windows. Usage: install-autoupdate.ps1 [-Check | -Uninstall]
# Enables scripts\check-update.ps1 (marker .git\agent-skills\autoupdate) and runs install-integrations.ps1, which
# merges the session-start hook (hooks\run-hook.cmd session-start <tool>) and the always-on rule into Codex, Claude
# Code and Cursor without clobbering. The hook already runs the check, so its definition (and Codex trust) is unchanged.
# -Uninstall disables the check; the hook stays because it also injects the pstack rule (owned by install-integrations.ps1).
param([switch]$Check, [switch]$Uninstall, [string]$UserProfilePath = $env:USERPROFILE)
$ErrorActionPreference = 'Stop'
$repo = Split-Path $PSScriptRoot -Parent
$state = Join-Path $repo '.git\agent-skills'
$marker = Join-Path $state 'autoupdate'
$codexHome = if ($env:CODEX_HOME -and -not $PSBoundParameters.ContainsKey('UserProfilePath')) { $env:CODEX_HOME } else { Join-Path $UserProfilePath '.codex' }
$hookFiles = [ordered]@{
    codex  = @((Join-Path $codexHome 'hooks.json'), 'SessionStart', 'codex', 'codex')
    claude = @((Join-Path $UserProfilePath '.claude\settings.json'), 'SessionStart', 'claude', 'claude')
    cursor = @((Join-Path $UserProfilePath '.cursor\hooks.json'), 'sessionStart', 'cursor', 'cursor')
}
function Test-Present([string]$Tool) {
    (Test-Path -LiteralPath (Join-Path $UserProfilePath ".$Tool")) -or [bool](Get-Command $Tool -ErrorAction SilentlyContinue)
}
function Test-Hook([string]$Tool) {
    $path = $hookFiles[$Tool][0]
    if (-not (Test-Path -LiteralPath $path)) { return $false }
    $text = [IO.File]::ReadAllText($path)
    return $text.Contains('run-hook.cmd') -and $text.Contains("session-start $Tool")
}
function Read-Raw([string]$Path) { if (Test-Path -LiteralPath $Path) { [IO.File]::ReadAllText($Path) } else { '' } }

if ($Check) {
    $last = Join-Path $state 'last-check'
    $when = if (Test-Path -LiteralPath $last) { (Get-Item -LiteralPath $last).LastWriteTime.ToString('yyyy-MM-dd HH:mm') } else { 'never' }
    Write-Output "Auto-update: $(if (Test-Path -LiteralPath $marker) { 'enabled' } else { 'disabled' }); last remote check: $when"
    foreach ($t in $hookFiles.Keys) {
        $s = if (-not (Test-Present $t)) { 'not detected' } elseif (Test-Hook $t) { 'hook installed' } else { 'hook missing' }
        Write-Output "  ${t}: $s"
    }
    if (Test-Hook 'codex') { Write-Output '  codex: trust is not readable from here; if Codex warns at startup, run /hooks once and trust it.' }
    exit 0
}
if ($Uninstall) {
    Remove-Item -LiteralPath $marker -Force -ErrorAction SilentlyContinue
    Write-Output "Auto-update disabled for $repo. Session-start hooks stay (they also inject the pstack rule); the check now exits silently."
    exit 0
}
New-Item -ItemType Directory -Path $state -Force | Out-Null
[IO.File]::WriteAllText($marker, '')
$before = @{}; foreach ($t in $hookFiles.Keys) { $before[$t] = Read-Raw $hookFiles[$t][0] }
$null = & (Join-Path $repo 'install-integrations.ps1') -UserProfilePath $UserProfilePath -SkipClaude:(-not (Test-Present 'claude'))
Write-Output "Auto-update enabled for $repo."
foreach ($t in $hookFiles.Keys) {
    $s = if (-not (Test-Present $t)) { 'not detected (hook written anyway by install-integrations.ps1)' } elseif ((Read-Raw $hookFiles[$t][0]) -ne $before[$t]) { 'installed' } else { 'unchanged' }
    if (-not (Test-Hook $t)) { $s = 'MISSING, check install-integrations.ps1 output' }
    Write-Output "  ${t}: $s"
}
$codexChanged = (Read-Raw $hookFiles.codex[0]) -ne $before.codex
Write-Output ('  Codex /hooks trust: ' + $(if ($codexChanged) { 'NEEDED. Start codex, run /hooks, trust the tuviskills SessionStart hook once.' } else { 'hook definition unchanged; needed only if you never trusted it (Codex warns at startup).' }))
