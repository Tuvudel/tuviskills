# Installs the plugin-free integrations for Codex, Cursor, and Claude Code:
#   - SessionStart hook that injects rules/pstack-default.md (hooks/run-hook.cmd -> hooks/session-start)
#   - subagent definitions from agents/ and vendor/pstack/agents/
#   - vendored pstack skills (vendor/pstack/skills) as per-skill junctions in ~/.codex/skills (Codex; Cursor also reads it)
#     and ~/.claude/skills (Claude Code), next to the personal skills
#   - the always-on pstack rule: ~/.cursor/rules/pstack-default.mdc, a managed block in ~/.codex/AGENTS.md
#     (with the Codex adapter harness/codex.md) and in ~/.claude/CLAUDE.md
#   - the personal rule block in ~/.claude/CLAUDE.md
# Idempotent: re-running replaces only entries this script owns. Existing hooks, agents and files are never
# overwritten; every modified JSON/MD file is backed up next to itself as <name>.agent-skills-<timestamp>.bak.
[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$UserProfilePath = $env:USERPROFILE,
    [string]$CodexHomePath,
    [switch]$SkipHooks,
    [switch]$SkipAgents,
    [switch]$SkipClaude
)
$ErrorActionPreference = 'Stop'
# Windows PowerShell 5.1 serializes arrays as {value,Count} while this type data is loaded.
if ($PSVersionTable.PSVersion.Major -lt 6) { Remove-TypeData System.Array -ErrorAction SilentlyContinue }
$repo = [IO.Path]::GetFullPath($PSScriptRoot).TrimEnd('\')
$profileRoot = [IO.Path]::GetFullPath($UserProfilePath)
if (-not $CodexHomePath) {
    if (-not $PSBoundParameters.ContainsKey('UserProfilePath') -and $env:CODEX_HOME) { $CodexHomePath = $env:CODEX_HOME }
    else { $CodexHomePath = Join-Path $profileRoot '.codex' }
}
$utf8 = New-Object Text.UTF8Encoding($false)
$stamp = [DateTime]::UtcNow.ToString('yyyyMMddTHHmmssZ')
# Forward slashes work for both cmd.exe and Git Bash, whichever shell the tool uses to run hooks.
$hookCmd = ($repo -replace '\\', '/') + '/hooks/run-hook.cmd'

function Save-Text([string]$Path, [string]$Text) {
    if (Test-Path -LiteralPath $Path -PathType Leaf) {
        if ([IO.File]::ReadAllText($Path) -eq $Text) { Write-Output "Unchanged: $Path"; return }
        if (-not $PSCmdlet.ShouldProcess($Path, 'Back up and update')) { return }
        Copy-Item -LiteralPath $Path -Destination "$Path.agent-skills-$stamp.bak"
    } else {
        if (-not $PSCmdlet.ShouldProcess($Path, 'Create')) { return }
        New-Item -ItemType Directory -Path (Split-Path $Path -Parent) -Force | Out-Null
    }
    [IO.File]::WriteAllText($Path, $Text, $utf8)
    Write-Output "Wrote: $Path"
}

function Read-JsonObject([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { return [pscustomobject]@{} }
    $raw = [IO.File]::ReadAllText($Path)
    if (-not $raw.Trim()) { return [pscustomobject]@{} }
    try { return $raw | ConvertFrom-Json } catch { throw "Not valid JSON, fix it by hand first: $Path" }
}

function Set-Member($Object, [string]$Name, $Value) {
    if ($Object.PSObject.Properties[$Name]) { $Object.$Name = $Value }
    else { $Object | Add-Member -NotePropertyName $Name -NotePropertyValue $Value }
}

function Test-OwnEntry($Entry) {
    # Matches both flat (Cursor) and nested (Claude/Codex) shapes.
    $text = $Entry | ConvertTo-Json -Depth 20 -Compress
    return $text.Contains('run-hook.cmd') -and $text.Contains('session-start')
}

function Merge-HookFile([string]$Path, [string]$EventName, $Entry, [switch]$CursorShape) {
    $config = Read-JsonObject $Path
    if ($CursorShape -and -not $config.PSObject.Properties['version']) { Set-Member $config 'version' 1 }
    if (-not $config.PSObject.Properties['hooks'] -or $null -eq $config.hooks) { Set-Member $config 'hooks' ([pscustomobject]@{}) }
    $existing = @()
    if ($config.hooks.PSObject.Properties[$EventName]) { $existing = @($config.hooks.$EventName) }
    $kept = @($existing | Where-Object { -not (Test-OwnEntry $_) })
    Set-Member $config.hooks $EventName (@($kept) + @($Entry))
    Save-Text $Path (($config | ConvertTo-Json -Depth 20) + "`n")
}

if (-not $SkipHooks) {
    # Cursor: user-level hooks file.
    Merge-HookFile (Join-Path $profileRoot '.cursor/hooks.json') 'sessionStart' ([pscustomobject]@{ command = "`"$hookCmd`" session-start cursor" }) -CursorShape
    # Claude Code: user settings.
    Merge-HookFile (Join-Path $profileRoot '.claude/settings.json') 'SessionStart' ([pscustomobject]@{
        matcher = 'startup|clear|compact'
        hooks = @([pscustomobject]@{ type = 'command'; command = "`"$hookCmd`" session-start claude"; async = $false })
    })
    # Codex: ~/.codex/hooks.json (user layer). Codex asks you to trust new hooks once via /hooks.
    Merge-HookFile (Join-Path $CodexHomePath 'hooks.json') 'SessionStart' ([pscustomobject]@{
        matcher = 'startup|resume|clear|compact'
        hooks = @([pscustomobject]@{ type = 'command'; command = "`"$hookCmd`" session-start codex"; timeout = 10 })
    })
    $configToml = Join-Path $CodexHomePath 'config.toml'
    if ((Test-Path -LiteralPath $configToml) -and (Select-String -LiteralPath $configToml -Pattern '^\s*\[\[?hooks' -Quiet)) {
        Write-Warning "$configToml also defines inline [hooks]; Codex merges both and warns. Prefer one representation."
    }
}

function Install-AgentFile([string]$Target, [string]$Text) {
    if (Test-Path -LiteralPath $Target -PathType Leaf) {
        $current = [IO.File]::ReadAllText($Target)
        if ($current -eq $Text) { Write-Output "Unchanged: $Target"; return }
        if (-not $current.Contains('agent-skills:managed')) { Write-Warning "Skipped, a different file exists: $Target"; return }
    }
    Save-Text $Target $Text
}

if (-not $SkipAgents) {
    $agentFiles = @(Get-ChildItem -LiteralPath (Join-Path $repo 'agents') -Filter *.md -File) +
        @(Get-ChildItem -LiteralPath (Join-Path $repo 'vendor/pstack/agents') -Filter *.md -File)
    foreach ($agent in $agentFiles) {
        $raw = [IO.File]::ReadAllText($agent.FullName) -replace "`r`n", "`n"
        if ($raw -notmatch '(?s)^---\n(.*?)\n---\n(.*)$') { Write-Warning "No frontmatter: $($agent.Name)"; continue }
        $front = $Matches[1]; $body = $Matches[2]
        $managed = $raw.TrimEnd() + "`n`n<!-- agent-skills:managed (installed from $($agent.DirectoryName); edit there) -->`n"
        # Cursor and Claude Code read Markdown subagents with YAML frontmatter.
        Install-AgentFile (Join-Path $profileRoot ".cursor/agents/$($agent.Name)") $managed
        Install-AgentFile (Join-Path $profileRoot ".claude/agents/$($agent.Name)") $managed
        # Codex custom agents are TOML files.
        $name = if ($front -match '(?m)^name:\s*(.+)$') { $Matches[1].Trim().Trim('"') } else { $agent.BaseName }
        $desc = if ($front -match '(?m)^description:\s*(.+)$') { $Matches[1].Trim().Trim('"') } else { $name }
        $toml = "# agent-skills:managed (installed from $($agent.FullName); edit there)`n" +
            "name = `"$($name -replace '"', '\"')`"`n" +
            "description = `"$($desc -replace '\\', '\\\\' -replace '"', '\"')`"`n" +
            "developer_instructions = '''`n$($body.Trim())`n'''`n"
        Install-AgentFile (Join-Path $CodexHomePath "agents/$($agent.BaseName).toml") $toml
    }
}

# pstack model rule: every role inherits the chat model (Cursor reads ~/.cursor/rules).
$pstackRule = ([IO.File]::ReadAllText((Join-Path $repo 'rules/pstack-models.mdc')) -replace "`r`n", "`n").TrimEnd() + "`n<!-- agent-skills:managed (installed from $repo\rules; edit there) -->`n"
Install-AgentFile (Join-Path $profileRoot '.cursor/rules/pstack-models.mdc') $pstackRule

# Always-on pstack rule. {{POTETO_MODE}} and {{CODEX_ADAPTER}} resolve to absolute paths in this repository.
$potetoMode = ($repo -replace '\\', '/') + '/vendor/pstack/skills/poteto-mode/SKILL.md'
$codexAdapter = ($repo -replace '\\', '/') + '/harness/codex.md'
function Expand-Rule([string]$Name) {
    $text = [IO.File]::ReadAllText((Join-Path $repo "rules/$Name")) -replace "`r`n", "`n"
    return $text.Replace('{{POTETO_MODE}}', $potetoMode).Replace('{{CODEX_ADAPTER}}', $codexAdapter).Trim()
}
function Set-ManagedBlock([string]$Path, [string]$Id, [string]$Body) {
    $start = "<!-- agent-skills:$($Id):start -->"; $end = "<!-- agent-skills:$($Id):end -->"
    $block = "$start`n$Body`n$end"
    $text = if (Test-Path -LiteralPath $Path) { [IO.File]::ReadAllText($Path) -replace "`r`n", "`n" } else { '' }
    $pattern = '(?s)' + [regex]::Escape($start) + '.*?' + [regex]::Escape($end)
    if ($text -match $pattern) { $text = [regex]::Replace($text, $pattern, { param($m) $block }) }
    else { $text = ($text.TrimEnd() + "`n`n" + $block).TrimStart() }
    Save-Text $Path ($text.TrimEnd() + "`n")
}
Install-AgentFile (Join-Path $profileRoot '.cursor/rules/pstack-default.mdc') ((Expand-Rule 'pstack-default.mdc') + "`n<!-- agent-skills:managed (installed from $repo\rules; edit there) -->`n")
$codexAgents = Join-Path $CodexHomePath 'AGENTS.md'
if (Test-Path -LiteralPath (Join-Path $CodexHomePath 'AGENTS.override.md') -PathType Leaf) { $codexAgents = Join-Path $CodexHomePath 'AGENTS.override.md' }
Set-ManagedBlock $codexAgents 'pstack-default' (Expand-Rule 'pstack-default.codex.md')

# Vendored pstack skills: one junction per skill, so each host discovers them next to the personal skills.
function Sync-SkillLinks([string]$Root, [hashtable]$Links) {
    if (-not (Test-Path -LiteralPath $Root)) {
        if (-not $PSCmdlet.ShouldProcess($Root, 'Create skills folder')) { return }
        New-Item -ItemType Directory -Path $Root -Force | Out-Null
    }
    foreach ($name in ($Links.Keys | Sort-Object)) {
        $link = Join-Path $Root $name; $target = $Links[$name]
        if (Test-Path -LiteralPath $link) {
            $item = Get-Item -LiteralPath $link -Force
            if ($item.LinkType -and ([string]$item.Target).TrimEnd('\') -eq $target.TrimEnd('\')) { continue }
            if (-not ($item.LinkType -and ([string]$item.Target).StartsWith($repo, [StringComparison]::OrdinalIgnoreCase))) {
                Write-Warning "Skipped, a different skill folder exists: $link"; continue
            }
            if (-not $PSCmdlet.ShouldProcess($link, "Repoint junction to $target")) { continue }
            cmd /c rmdir "$link" | Out-Null
        } elseif (-not $PSCmdlet.ShouldProcess($link, "Create junction to $target")) { continue }
        New-Item -ItemType Junction -Path $link -Target $target | Out-Null
        Write-Output "Linked: $link"
    }
    # Drop junctions this script made whose skill no longer exists (archived or removed upstream).
    foreach ($item in @(Get-ChildItem -LiteralPath $Root -Force | Where-Object { $_.LinkType })) {
        if ($item.LinkType -and ([string]$item.Target).StartsWith($repo, [StringComparison]::OrdinalIgnoreCase) -and -not $Links.ContainsKey($item.Name)) {
            if ($PSCmdlet.ShouldProcess($item.FullName, 'Remove stale junction')) { cmd /c rmdir "$($item.FullName)" | Out-Null; Write-Output "Removed stale link: $($item.FullName)" }
        }
    }
}
$pstackLinks = @{}
foreach ($dir in Get-ChildItem -LiteralPath (Join-Path $repo 'vendor/pstack/skills') -Directory) { $pstackLinks[$dir.Name] = $dir.FullName }
# Codex (legacy user skills folder) and Cursor (reads ~/.codex/skills for compatibility). Personal skills stay in ~/.agents/skills.
Sync-SkillLinks (Join-Path $CodexHomePath 'skills') $pstackLinks

if (-not $SkipClaude) {
    # Claude Code discovers skills one level deep in ~/.claude/skills: one junction per personal and pstack skill.
    $claudeSkills = Join-Path $profileRoot '.claude/skills'
    $repoSkills = Join-Path $repo 'skills'
    if (Test-Path -LiteralPath $claudeSkills) {
        $item = Get-Item -LiteralPath $claudeSkills -Force
        if ($item.LinkType -and ([string]$item.Target).TrimEnd('\') -eq $repoSkills) {
            # Older installs linked the whole folder to skills/; replace that single junction (rmdir removes only the link).
            if ($PSCmdlet.ShouldProcess($claudeSkills, 'Replace folder junction with per-skill junctions')) { cmd /c rmdir "$claudeSkills" | Out-Null }
        }
    }
    $claudeLinks = $pstackLinks.Clone()
    foreach ($dir in Get-ChildItem -LiteralPath $repoSkills -Directory) { $claudeLinks[$dir.Name] = $dir.FullName }
    Sync-SkillLinks $claudeSkills $claudeLinks
    Set-ManagedBlock (Join-Path $profileRoot '.claude/CLAUDE.md') 'pstack-default' (Expand-Rule 'pstack-default.md')
    # Personal rule block in ~/.claude/CLAUDE.md (same rule Codex gets through install-personal-engineering.ps1).
    $claudeMd = Join-Path $profileRoot '.claude/CLAUDE.md'
    $start = '<!-- agent-skills:personal-engineering:start -->'; $end = '<!-- agent-skills:personal-engineering:end -->'
    $rule = ([IO.File]::ReadAllText((Join-Path $repo 'rules/personal-engineering.md')) -replace "`r`n", "`n").Trim()
    $block = "$start`n$rule`n$end"
    $text = if (Test-Path -LiteralPath $claudeMd) { [IO.File]::ReadAllText($claudeMd) -replace "`r`n", "`n" } else { '' }
    $pattern = '(?s)' + [regex]::Escape($start) + '.*?' + [regex]::Escape($end)
    if ($text -match $pattern) { $text = [regex]::Replace($text, $pattern, { param($m) $block }) }
    else { $text = ($text.TrimEnd() + "`n`n" + $block).TrimStart() }
    Save-Text $claudeMd ($text.TrimEnd() + "`n")
}
Write-Output 'Integrations done. Restart Cursor and Claude Code; in Codex run /hooks once to trust the new SessionStart hook.'
