# Session-start update check for this skills repo (Windows twin of check-update.sh; same behaviour).
# Output is for the agent: nothing when up to date, at most one line otherwise. Never blocks (5 s network cap),
# never resets, stashes, deletes or forces. Runs only when enabled by install-autoupdate.ps1
# (marker .git\agent-skills\autoupdate). Env (tests): AGENT_SKILLS_CHECK_INTERVAL_MIN, AGENT_SKILLS_POST_SYNC.
$ErrorActionPreference = 'SilentlyContinue'
$repo = Split-Path $PSScriptRoot -Parent
$state = Join-Path $repo '.git\agent-skills'
if (-not (Test-Path -LiteralPath (Join-Path $state 'autoupdate'))) { exit 0 }
$interval = if ($env:AGENT_SKILLS_CHECK_INTERVAL_MIN) { [int]$env:AGENT_SKILLS_CHECK_INTERVAL_MIN } else { 240 }
$stamp = Join-Path $state 'last-check'
if ((Test-Path -LiteralPath $stamp) -and ((Get-Item -LiteralPath $stamp).LastWriteTime -gt (Get-Date).AddMinutes(-$interval))) { exit 0 }
[IO.File]::WriteAllText($stamp, '')
$env:GIT_TERMINAL_PROMPT = '0'; $env:GCM_INTERACTIVE = 'never'

function G { $o = & git -C $repo @args 2>$null; $script:ok = ($LASTEXITCODE -eq 0); $o }
# Run git with a 5 s cap; returns stdout or $null on failure/timeout.
function Bounded([string]$GitArgs) {
    $p = New-Object Diagnostics.Process
    $p.StartInfo.FileName = 'git'
    $p.StartInfo.Arguments = "-C `"$repo`" $GitArgs"
    $p.StartInfo.UseShellExecute = $false; $p.StartInfo.CreateNoWindow = $true
    $p.StartInfo.RedirectStandardOutput = $true; $p.StartInfo.RedirectStandardError = $true
    if (-not $p.Start()) { return $null }
    $out = $p.StandardOutput.ReadToEndAsync(); $null = $p.StandardError.ReadToEndAsync()
    if (-not $p.WaitForExit(5000)) { try { $p.Kill() } catch {}; return $null }
    if ($p.ExitCode -ne 0) { return $null }
    return $out.Result
}

$syncScript = Join-Path $repo 'sync.ps1'
$sync = "powershell -NoProfile -ExecutionPolicy Bypass -File `"$syncScript`""
$post = if ($null -ne $env:AGENT_SKILLS_POST_SYNC) { $env:AGENT_SKILLS_POST_SYNC } else { "powershell -NoProfile -ExecutionPolicy Bypass -File `"$(Join-Path $repo 'install-integrations.ps1')`"" }

$ls = Bounded 'ls-remote origin refs/heads/main'
if (-not $ls) { exit 0 }
$remote = ($ls -split "`t")[0].Trim()
$local = G rev-parse HEAD
if (-not $ok -or -not $remote -or $remote -eq $local) { exit 0 }
$null = G merge-base --is-ancestor $remote HEAD
if ($ok) { exit 0 }
$stale = "Skills are out of date (local $($local.Substring(0,7)), latest $($remote.Substring(0,7))): run ``$sync`` before relying on skills"

if ((G symbolic-ref -q --short HEAD) -ne 'main') { Write-Output "$stale (checkout is not on main)."; exit 0 }
if (G status --porcelain --untracked-files=no) { Write-Output "$stale (commit local edits first; not auto-updated)."; exit 0 }
if ($null -eq (Bounded 'fetch -q origin main')) { exit 0 }
$null = G merge-base --is-ancestor HEAD FETCH_HEAD
if (-not $ok) { Write-Output "$stale (local and remote diverged; not auto-updated)."; exit 0 }
$null = G merge -q --ff-only FETCH_HEAD
if (-not $ok) { Write-Output "$stale (fast-forward failed; not auto-updated)."; exit 0 }
if ($post) {
    $global:LASTEXITCODE = 0
    try { $null = Invoke-Expression $post 2>&1 } catch { $global:LASTEXITCODE = 1 }
    if ($LASTEXITCODE -ne 0) { Write-Output "Skills pulled to $($remote.Substring(0,7)) but ``$post`` failed: run it before relying on skills."; exit 0 }
}
Write-Output "Skills auto-updated to $($remote.Substring(0,7))."
exit 0
