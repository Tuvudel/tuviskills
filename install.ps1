[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$UserProfilePath = $env:USERPROFILE,
    [string]$BackupRoot
)
$ErrorActionPreference = 'Stop'
if (-not $BackupRoot) { $BackupRoot = Join-Path $UserProfilePath '.agents\skill-backups' }
$repoSkills = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot 'skills'))
$profileRoot = [IO.Path]::GetFullPath($UserProfilePath)
$sharedPath = Join-Path $profileRoot '.agents\skills'
$inventory = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'inventory.json') -Raw | ConvertFrom-Json
if (-not (Test-Path -LiteralPath $repoSkills -PathType Container)) { throw 'Repository skills folder is missing.' }
if ([IO.Path]::GetFullPath($BackupRoot).StartsWith($PSScriptRoot + '\', [StringComparison]::OrdinalIgnoreCase)) { throw 'Backups must be outside the Git repository.' }

if (Test-Path -LiteralPath $sharedPath) {
    $sharedItem = Get-Item -LiteralPath $sharedPath -Force
    if ($sharedItem.LinkType -and ([string]$sharedItem.Target).TrimEnd('\') -eq $repoSkills.TrimEnd('\')) {
        Write-Output 'Shared skills are already connected to this repository.'
        return
    }
}

function Assert-SkillMatches([string]$Folder, $Skill) {
    $repositoryFolder = Join-Path $PSScriptRoot $Skill.path
    foreach ($repositoryFile in Get-ChildItem -LiteralPath $repositoryFolder -File -Recurse) {
        $relativeFile = $repositoryFile.FullName.Substring($repositoryFolder.Length + 1)
        $filePath = Join-Path $Folder $relativeFile
        if (-not (Test-Path -LiteralPath $filePath -PathType Leaf)) { throw "Missing file: $filePath" }
        $hasher = [Security.Cryptography.SHA256]::Create()
        try {
            $localHash = [BitConverter]::ToString($hasher.ComputeHash([IO.File]::ReadAllBytes($filePath)))
            $repositoryHash = [BitConverter]::ToString($hasher.ComputeHash([IO.File]::ReadAllBytes($repositoryFile.FullName)))
        } finally { $hasher.Dispose() }
        if ($localHash -ne $repositoryHash) {
            throw "Local skill differs from the repository: $filePath. Preserve and merge it before installing."
        }
    }
}

# Validate the recorded skill folders before changing an installed directory.
foreach ($skill in $inventory.skills) {
    if (-not (Test-Path -LiteralPath (Join-Path (Join-Path $PSScriptRoot $skill.path) 'SKILL.md'))) { throw "Repository skill is missing: $($skill.name)" }
}

$moves = [Collections.Generic.List[object]]::new()
if (Test-Path -LiteralPath $sharedPath) {
    # A second PC can contain additional personal skills. Never hide them silently.
    $known = @{}
    foreach ($skill in $inventory.skills) {
        $relativePath = $skill.path.Substring('skills/'.Length).Replace('/', '\')
        $known[$relativePath.ToLowerInvariant()] = $skill
    }
    foreach ($existingSkill in Get-ChildItem -LiteralPath $sharedPath -Filter SKILL.md -Recurse -File) {
        $relativeFolder = $existingSkill.DirectoryName.Substring($sharedPath.Length + 1).ToLowerInvariant()
        if (-not $known.ContainsKey($relativeFolder)) { throw "Additional local skill needs importing first: $($existingSkill.DirectoryName)" }
        Assert-SkillMatches $existingSkill.DirectoryName $known[$relativeFolder]
    }
    foreach ($relativeFolder in $known.Keys) {
        $existingFolder = Join-Path $sharedPath $relativeFolder
        if (Test-Path -LiteralPath (Join-Path $existingFolder 'SKILL.md')) { Assert-SkillMatches $existingFolder $known[$relativeFolder] }
    }
    $moves.Add([pscustomobject]@{ original = $sharedPath; relative = 'agents-skills' })
}

foreach ($legacyRoot in @('.codex\skills', '.cursor\skills')) {
    foreach ($skill in $inventory.skills) {
        if ($skill.path.StartsWith('skills/superpowers/')) { continue }
        $folderName = Split-Path $skill.path -Leaf
        $legacyPath = Join-Path (Join-Path $profileRoot $legacyRoot) $folderName
        if (-not (Test-Path -LiteralPath $legacyPath -PathType Container)) { continue }
        Assert-SkillMatches $legacyPath $skill
        $label = if ($legacyRoot.StartsWith('.codex')) { 'codex-skills' } else { 'cursor-skills' }
        $moves.Add([pscustomobject]@{ original = $legacyPath; relative = "$label\$folderName" })
    }
}

Write-Output "Connect $sharedPath to $repoSkills; preserve $($moves.Count) existing locations in a dated backup."
if (-not $PSCmdlet.ShouldProcess($sharedPath, 'Back up matching skills and create the shared directory junction')) { return }
$backupPath = Join-Path $BackupRoot ([DateTime]::UtcNow.ToString('yyyyMMddTHHmmssZ') + '-' + [Guid]::NewGuid().ToString('N').Substring(0, 6))
New-Item -ItemType Directory -Path $backupPath | Out-Null
$state = [ordered]@{ shared_path = $sharedPath; repository_skills = $repoSkills; user_profile = $profileRoot; moved = @(); compatibility_path = (Join-Path $profileRoot '.codex\skills\playwright\scripts') }
$statePath = Join-Path $backupPath 'restore-state.json'
$state | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $statePath -Encoding utf8
foreach ($move in $moves) {
    $destination = Join-Path $backupPath $move.relative
    New-Item -ItemType Directory -Path (Split-Path $destination -Parent) -Force | Out-Null
    Move-Item -LiteralPath $move.original -Destination $destination
    $state.moved += [ordered]@{ original = $move.original; backup = $destination }
    $state | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $statePath -Encoding utf8
}
New-Item -ItemType Directory -Path (Split-Path $sharedPath -Parent) -Force | Out-Null
New-Item -ItemType Junction -Path $sharedPath -Target $repoSkills | Out-Null
# The unchanged Playwright instructions reference this legacy scripts location.
# This alias contains no SKILL.md, so it does not add another discoverable skill.
New-Item -ItemType Directory -Path (Split-Path $state.compatibility_path -Parent) -Force | Out-Null
New-Item -ItemType Junction -Path $state.compatibility_path -Target (Join-Path $repoSkills 'playwright\scripts') | Out-Null
Write-Output "Installed $($inventory.skills.Count) skills. Backup: $backupPath"
Write-Output 'Start a new Codex chat and reload Cursor to refresh skill discovery.'
