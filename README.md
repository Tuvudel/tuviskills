# Personal agent skills

Shared personal skills for Codex and Cursor on Windows. The original consolidation contains 79 unique local skills: 65 personal skills and 14 skills from the existing local Superpowers installation. Additional skills are listed in the inventory as they are adopted.

See [the full inventory](INVENTORY.md) for names and purposes. Skill contents and supporting files are preserved from the existing installations. Fourteen identical Cursor copies are consolidated into the same repository copies.

## pstack is the engineering backbone

[pstack](https://github.com/cursor/plugins/tree/main/pstack) is vendored unmodified in [`vendor/pstack/`](vendor/pstack) (version and commit in [`vendor/pstack.lock`](vendor/pstack.lock)). Update it with `scripts/sync-pstack.sh` (see [UPSTREAM.md](UPSTREAM.md)); `scripts/sync-pstack.sh --check` and `tests/test_vendor_pstack.py` fail if anyone edits it. Personal skills in `skills/` must not reuse a pstack name.

One always-on rule makes pstack automatic without slash commands: for non-trivial engineering work, read `poteto-mode`'s `SKILL.md` by absolute path and follow it. The same text ships as:

- [`rules/pstack-default.mdc`](rules/pstack-default.mdc) (`alwaysApply: true`), installed to `~/.cursor/rules/pstack-default.mdc`. If your Cursor build does not load `~/.cursor/rules` globally, paste [`rules/pstack-default.md`](rules/pstack-default.md) into **Customize → Rules → User Rules**; the SessionStart hook injects the same text anyway.
- [`rules/pstack-default.codex.md`](rules/pstack-default.codex.md), installed as a managed block in `~/.codex/AGENTS.md` (or `AGENTS.override.md`). It also points Codex at the adapter [`harness/codex.md`](harness/codex.md), which maps pstack's Cursor names, subagent fields, and model roles to Codex.
- [`rules/pstack-default.grokbot.txt`](rules/pstack-default.grokbot.txt), for Grok Bot's instructions (box path).
- The same block in `~/.claude/CLAUDE.md`. `rules/pstack-models.mdc` keeps every pstack role on `inherit-parent`.

Other entry skills: `design-ui`, `illustrate`, `docs-writing`. Superpowers lifecycle skills, the old `using-skills` / `coding-workflow` routers, the engineering companion, and the Circles skills are in `archive/`.

- `hooks/session-start` re-injects `rules/pstack-default.md` at session start, clear, and compaction. `hooks/run-hook.cmd` is a cmd/bash polyglot that finds Git Bash on Windows. Pass `cursor`, `claude`, or `codex` to pick the output shape.
- `install-integrations.ps1` (called by `install.ps1` and `sync.ps1`) merges the hook into `~/.cursor/hooks.json`, `~/.claude/settings.json`, and `~/.codex/hooks.json`; installs `agents/*.md` and `vendor/pstack/agents/*.md` as Cursor and Claude Code subagents and Codex custom agents (`~/.codex/agents/*.toml`); links each pstack skill into `~/.codex/skills/` (Codex, and Cursor through its compatibility folder) and each personal and pstack skill into `~/.claude/skills/` (replacing an older single junction to `skills/`); and writes the rules above. It keeps existing entries, backs up each changed file, and skips any file it did not create.
- `scripts/check-skills` fails on missing frontmatter, folder/name mismatches, duplicate names, names that shadow pstack, routers that name unknown skills, and inventory drift. Run `scripts/build-inventory` after adding or removing a skill. `python -m unittest discover tests` runs all checks (the installer test needs Windows PowerShell).

The personal Codex rule block ([`rules/personal-engineering.md`](rules/personal-engineering.md)) is installed separately, once per PC:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File D:\Projects\agent-skills\install-personal-engineering.ps1
```

It updates one marked block in the active global `AGENTS.md` or `AGENTS.override.md` and saves the original under `.local/personal-engineering-backups/`. It honors `CODEX_HOME` and supports `-CodexHomePath`, `-WhatIf`, and `-Remove`.

## Install on another Windows PC

Install Git and GitHub CLI, then authenticate with the GitHub account that can access this private repository:

```powershell
gh auth login
gh repo clone Tuvudel/agent-skills D:\Projects\agent-skills
powershell -NoProfile -ExecutionPolicy Bypass -File D:\Projects\agent-skills\install.ps1 -WhatIf
powershell -NoProfile -ExecutionPolicy Bypass -File D:\Projects\agent-skills\install.ps1
```

The script connects `%USERPROFILE%\.agents\skills` to the repository's `skills` directory using a Windows directory junction. Codex and Cursor both discover skills in that shared location. Existing matching skill folders are moved into a dated backup under `%USERPROFILE%\.agents\skill-backups` before the junction is created. Backups remain on the same drive as the original folders and outside skill discovery paths. Conflicting skills stop installation so you can merge them first. System skills and plugin caches remain managed by their applications.

Start a new Codex chat and reload Cursor after installation. Installation can be run again safely. Use `-UserProfilePath` and `-BackupRoot` to choose alternate locations when testing.

The installer also links `~/.codex/skills/playwright/scripts` to the shared Playwright scripts because the imported instructions reference that location. This compatibility folder has no `SKILL.md` and does not add a duplicate skill.

## Sync changes

Before working on either PC:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File D:\Projects\agent-skills\sync.ps1
```

After changing or adding a skill, commit and push it from the repository:

```powershell
git -C D:\Projects\agent-skills add skills
git -C D:\Projects\agent-skills commit -m "Update personal skills"
git -C D:\Projects\agent-skills push
```

Run the sync command on the other PC. The local shared folder points directly into this checkout, and sync re-runs `install-integrations.ps1` so new or archived skills are linked or unlinked. Sync stops when there are local uncommitted edits or when a fast-forward pull is impossible. It does not automatically commit, push, merge, or resolve conflicts.

New skills do not need an `inventory.json` entry for agent discovery, but add one before migrating an existing matching skill folder on another PC. `inventory.json` records the original import hashes and locations. Installation compares existing local files against the current repository files to detect conflicts. Git preserves imported file bytes across PCs.

## Restore original folders

The installer prints the dated backup path and saves `restore-state.json` there. To undo installation:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File D:\Projects\agent-skills\restore.ps1 -BackupPath "$env:USERPROFILE\.agents\skill-backups\YOUR-BACKUP"
```

The restore script removes only the shared junction and moves the backed-up original folders to their original locations. Repository files remain intact. It stops rather than overwriting newly created folders. Repository edits made after installation stay in the repository; restoring originals returns the old skill versions.

## Scope and compatibility

- Plugin-managed and Codex system skills are not copied. Install their plugins separately on each PC.
- MCP connections, credentials, application settings, and runtime dependencies are not synchronized.
- Some imported skills reference machine-specific paths. Review those paths before using them on another PC.
- The original broken `find-skills` shortcut remains untouched and is recorded in the inventory.
- The superpowers, pstack, and cursor-team-kit plugins are replaced by repository copies (pstack vendored unmodified). Uninstall those plugins so their skills do not load twice.
- Cursor reads `~/.agents/skills`, `~/.cursor/skills`, `~/.codex/skills`, and `~/.claude/skills`, so it may list a skill from more than one folder.
- Cursor Cloud Agents have a separate sync feature for `~/.cursor/skills`. This shared local setup covers local Codex and Cursor sessions on the PCs.
- This repository contains third-party and personal material. Preserve included license files and check upstream licenses before redistributing.

Verified discovery locations: [Codex skill documentation](https://learn.chatgpt.com/docs/build-skills#where-codex-loads-local-skills) and [Cursor skill documentation](https://cursor.com/help/customization/skills).
