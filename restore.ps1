[CmdletBinding(SupportsShouldProcess)]
param([Parameter(Mandatory)][string]$BackupPath)
$ErrorActionPreference = 'Stop'
$backupRoot = [IO.Path]::GetFullPath($BackupPath).TrimEnd('\')
$state = Get-Content -LiteralPath (Join-Path $backupRoot 'restore-state.json') -Raw | ConvertFrom-Json
$sharedPath = [IO.Path]::GetFullPath($state.shared_path)
$profileRoot = [IO.Path]::GetFullPath($state.user_profile).TrimEnd('\')
if ($sharedPath -ne (Join-Path $profileRoot '.agents\skills')) { throw 'Unexpected shared skills path.' }
$compatibilityFolder = Join-Path $profileRoot '.codex\skills\playwright'
$compatibilityLink = Join-Path $compatibilityFolder 'scripts'
if ($state.compatibility_path -ne $compatibilityLink) { throw 'Unexpected compatibility path.' }
$compatibilityItem = $null
if (Test-Path -LiteralPath $compatibilityLink) {
    $compatibilityItem = Get-Item -LiteralPath $compatibilityLink -Force
    if ($compatibilityItem.LinkType -ne 'Junction' -or ([string]$compatibilityItem.Target) -ne (Join-Path $state.repository_skills 'playwright\scripts')) { throw 'Compatibility alias has changed.' }
    if (@(Get-ChildItem -LiteralPath $compatibilityFolder -Force).Count -ne 1) { throw 'Compatibility folder contains new files; restore manually.' }
}
$currentJunction = $null
if (Test-Path -LiteralPath $sharedPath) {
    $currentJunction = Get-Item -LiteralPath $sharedPath -Force
    if ($currentJunction.LinkType -ne 'Junction' -or ([string]$currentJunction.Target).TrimEnd('\') -ne ([string]$state.repository_skills).TrimEnd('\')) {
        throw 'Shared folder no longer matches the installed junction; restore manually.'
    }
}
foreach ($move in $state.moved) {
    $original = [IO.Path]::GetFullPath($move.original)
    $saved = [IO.Path]::GetFullPath($move.backup)
    $allowed = @('.agents\skills', '.codex\skills', '.cursor\skills') | ForEach-Object { Join-Path $profileRoot $_ }
    if (-not ($allowed | Where-Object { $original -eq $_ -or $original.StartsWith($_ + '\', [StringComparison]::OrdinalIgnoreCase) })) { throw "Unexpected restore destination: $original" }
    if (-not $saved.StartsWith($backupRoot + '\', [StringComparison]::OrdinalIgnoreCase)) { throw 'Backup path is outside the selected backup directory.' }
    if (-not (Test-Path -LiteralPath $saved)) { throw "Missing backup: $saved" }
    if ($original -ne $sharedPath -and $original -ne $compatibilityFolder -and (Test-Path -LiteralPath $original)) { throw "Restore would overwrite existing files: $original" }
}
if (-not $PSCmdlet.ShouldProcess($sharedPath, 'Remove the shared junction and restore original skill folders')) { return }
if ($compatibilityItem) {
    $compatibilityItem.Delete()
    (Get-Item -LiteralPath $compatibilityFolder -Force).Delete() # Empty folder only.
}
if ($currentJunction) { $currentJunction.Delete() } # Remove the junction only; never recursively delete its target.
foreach ($move in $state.moved) {
    New-Item -ItemType Directory -Path (Split-Path $move.original -Parent) -Force | Out-Null
    Move-Item -LiteralPath $move.backup -Destination $move.original
}
Write-Output 'Original skill folders restored. Refresh Codex and Cursor.'
