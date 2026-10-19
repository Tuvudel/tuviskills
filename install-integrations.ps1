# Installs the plugin-free integrations for Codex, Cursor, and Claude Code:
#   - SessionStart hook that injects skills/using-skills (hooks/run-hook.cmd -> hooks/session-start)
#   - subagent definitions from agents/
#   - Claude Code skill discovery (~/.claude/skills junction) and the personal rule block in ~/.claude/CLAUDE.md
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
    foreach ($agent in Get-ChildItem -LiteralPath (Join-Path $repo 'agents') -Filter *.md -File) {
        $raw = [IO.File]::ReadAllText($agent.FullName) -replace "`r`n", "`n"
        if ($raw -notmatch '(?s)^---\n(.*?)\n---\n(.*)$') { Write-Warning "No frontmatter: $($agent.Name)"; continue }
        $front = $Matches[1]; $body = $Matches[2]
        $managed = $raw.TrimEnd() + "`n`n<!-- agent-skills:managed (installed from $repo\agents; edit there) -->`n"
        # Cursor and Claude Code read Markdown subagents with YAML frontmatter.
        Install-AgentFile (Join-Path $profileRoot ".cursor/agents/$($agent.Name)") $managed
        Install-AgentFile (Join-Path $profileRoot ".claude/agents/$($agent.Name)") $managed
        # Codex custom agents are TOML files.
        $name = if ($front -match '(?m)^name:\s*(.+)$') { $Matches[1].Trim().Trim('"') } else { $agent.BaseName }
        $desc = if ($front -match '(?m)^description:\s*(.+)$') { $Matches[1].Trim().Trim('"') } else { $name }
        $toml = "# agent-skills:managed (installed from $repo\agents\$($agent.Name); edit there)`n" +
            "name = `"$($name -replace '"', '\"')`"`n" +
            "description = `"$($desc -replace '\\', '\\\\' -replace '"', '\"')`"`n" +
            "developer_instructions = '''`n$($body.Trim())`n'''`n"
        Install-AgentFile (Join-Path $CodexHomePath "agents/$($agent.BaseName).toml") $toml
    }
}

if (-not $SkipClaude) {
    # Claude Code discovers personal skills in ~/.claude/skills.
    $claudeSkills = Join-Path $profileRoot '.claude/skills'
    $repoSkills = Join-Path $repo 'skills'
    if (Test-Path -LiteralPath $claudeSkills) {
        $item = Get-Item -LiteralPath $claudeSkills -Force
        if ($item.LinkType -and ([string]$item.Target).TrimEnd('\') -eq $repoSkills) { Write-Output "Unchanged: $claudeSkills" }
        elseif (@(Get-ChildItem -LiteralPath $claudeSkills -Force).Count -eq 0) {
            if ($PSCmdlet.ShouldProcess($claudeSkills, 'Replace empty folder with a junction to the repository skills')) {
                Remove-Item -LiteralPath $claudeSkills; New-Item -ItemType Junction -Path $claudeSkills -Target $repoSkills | Out-Null
            }
        } else { Write-Warning "Skipped: $claudeSkills already has content. Move it aside to share the repository skills with Claude Code." }
    } elseif ($PSCmdlet.ShouldProcess($claudeSkills, 'Create junction to the repository skills')) {
        New-Item -ItemType Directory -Path (Split-Path $claudeSkills -Parent) -Force | Out-Null
        New-Item -ItemType Junction -Path $claudeSkills -Target $repoSkills | Out-Null
    }
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
