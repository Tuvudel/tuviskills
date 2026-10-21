$ErrorActionPreference = 'Stop'
$changes = git -C $PSScriptRoot status --porcelain
if ($LASTEXITCODE -ne 0) { throw 'Cannot inspect repository status.' }
if ($changes) { throw 'Commit and push your local edits before syncing.' }
git -C $PSScriptRoot pull --ff-only
if ($LASTEXITCODE -ne 0) { throw 'Sync failed. Resolve the Git error before continuing.' }
& (Join-Path $PSScriptRoot 'install-integrations.ps1')
Write-Output 'Skills updated. Start a new Codex chat and reload Cursor to refresh discovery.'
