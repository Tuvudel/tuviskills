# tuviskills

Hi! This is my personal collection of agent skills: some I wrote, most I picked up from people who make great ones. They work in Codex, Cursor, Claude Code and Grok Build. I'm sharing them as-is, so take what's useful, and check the licenses for anything you reuse (see [Credits](#credits)).

A skill is a folder with a `SKILL.md` that tells your agent when and how to do something. Once installed, your agent picks the right one by itself.

## What's inside

There are 38 skills in [`skills/`](skills) plus 56 from pstack in [`vendor/pstack/`](vendor/pstack). [INVENTORY.md](INVENTORY.md) has the full list with descriptions.

| Group | Skills | What they're for |
| --- | --- | --- |
| **pstack** | 56 skills, including `poteto-mode` | The engineering workflow: planning, building, debugging, reviewing and shipping. `poteto-mode` is the entry point and routes to the rest. |
| **better-\*** | `better-interface`, `better-accessibility`, `better-colors`, `better-layout`, `better-typography`, `better-ui`, `better-writing`, plus `break` and `explain-interface` | UI review and polish. `better-interface` runs them all in one pass. |
| **PRs and CI** (cursor-team-kit) | `fix-ci`, `fix-merge-conflicts`, `get-pr-comments`, `make-pr-easy-to-review`, `pr-review-canvas`, `what-did-i-get-done`, `thermo-nuclear-code-quality-review`, `control-cli`, `control-ui` | Fix failing checks, resolve conflicts, prep and review PRs, and drive CLIs or UIs from the agent. |
| **Visuals** | `illustrate`, `anatomy`, `tufte-viz`, `ian-xiaohei-illustrations`, `playground`, `hatch-pet`, `clean-product-research-illustrations` | Diagrams, isometric figures, honest charts, illustrations, and interactive HTML playgrounds. `illustrate` picks one for you. |
| **Writing and product** | `docs-writing`, `google-developer-style`, `product-requirements`, `docs-propose-first` | Docs and prose, PRDs, and a careful "propose before you patch" docs flow. |
| **Decisions and handoffs** | `perspective-ensemble`, `session-handoff`, `receiving-code-review`, `git-diff-hygiene` | Get several independent opinions on a hard call, hand off context between sessions, handle review feedback, and keep diffs clean. |
| **Misc** | `design-ui`, `apca-contrast`, `israel-gov-api`, `playwright` | The UI entry point, APCA contrast math, Israeli government open data, and browser automation. |
| **Grok Bot-specific, optional** | `design-a-grok-bot`, plus `scripts/sync-box` and `rules/pstack-default.grokbot.txt` | Only useful on a Grok Bot box. Everyone else can ignore them. |

Old skills I don't use anymore live in [`archive/`](archive). They aren't installed.

## Install

Clone the repo anywhere you like:

```sh
git clone https://github.com/Tuvudel/tuviskills.git
cd tuviskills
```

### macOS and Linux

```sh
./install.sh             # Codex, Cursor and Grok Build: links every skill into ~/.agents/skills
./install.sh --claude    # same, plus ~/.claude/skills for Claude Code
./install.sh --dry-run   # show what it would do
```

It creates one symlink per skill. It never touches a folder it didn't create (it skips it and tells you), and it's safe to run again.

### Windows (PowerShell)

```powershell
.\install.ps1 -WhatIf   # preview
.\install.ps1
```

This links `%USERPROFILE%\.agents\skills` to the repo's `skills` folder, which covers Codex and Cursor. It also runs `install-integrations.ps1`, which adds the pstack skills, the subagents in `agents/`, and a session-start hook, and sets up Claude Code (`~/.claude/skills`). If you already have skills in `%USERPROFILE%\.agents\skills`, it moves matching copies into a dated folder under `%USERPROFILE%\.agents\skill-backups` first. If something there differs from this repo, it stops so nothing gets lost.

To skip Claude Code: `.\install.ps1 -SkipIntegrations`, then `.\install-integrations.ps1 -SkipClaude`.

If PowerShell blocks scripts, run them as `powershell -NoProfile -ExecutionPolicy Bypass -File .\install.ps1`.

### Per harness

| Harness | macOS / Linux | Windows |
| --- | --- | --- |
| Codex | `./install.sh` | `.\install.ps1` |
| Cursor | `./install.sh` | `.\install.ps1` |
| Grok Build | `./install.sh` | `.\install.ps1` |
| Claude Code | `./install.sh --claude` | `.\install.ps1` (included) |

Then start a new chat or reload the app so it sees the skills. Cursor can read `~/.claude/skills` too, so if you see doubles in Cursor, leave out `--claude`.

### Optional: always-on pstack rule and auto-update

```sh
sh scripts/install-autoupdate.sh          # macOS / Linux
```

```powershell
.\scripts\install-autoupdate.ps1          # Windows
```

This adds a small session-start hook to Codex, Claude Code and Cursor. The hook tells your agent to use `poteto-mode` for real engineering work, and it fast-forwards this repo when `main` has moved (at most every 4 hours, and only when you have no local edits). Check its status with `--check` / `-Check`. Codex asks you to trust the hook once: run `/hooks` in `codex`.

## Update

```sh
git pull && ./install.sh          # macOS / Linux (re-run to link new skills)
```

```powershell
.\sync.ps1                        # Windows: pull and refresh the integrations
```

## Uninstall

```sh
./install.sh --uninstall          # macOS / Linux: removes only the links that point into this repo
sh scripts/install-autoupdate.sh --uninstall
```

```powershell
.\restore.ps1 -BackupPath <folder printed by install.ps1>   # Windows: removes the link and puts back what was there
.\scripts\install-autoupdate.ps1 -Uninstall
```

## For tinkerers

- `scripts/check-skills` checks frontmatter, names and the inventory. Run `scripts/build-inventory` after adding or removing a skill.
- `python -m unittest discover tests` runs the tests. The PowerShell ones need Windows.
- pstack is vendored unmodified. Update it with `scripts/sync-pstack.sh`, as described in [UPSTREAM.md](UPSTREAM.md).
- `harness/codex.md` maps pstack's Cursor-flavored names onto Codex.

## Credits

Most of the good stuff here comes from these folks. Thank you!

- [pstack](https://github.com/cursor/plugins/tree/main/pstack) by poteto, and [cursor-team-kit](https://github.com/cursor/plugins/tree/main/cursor-team-kit), both from cursor/plugins
- [jakubkrehel/skills](https://github.com/jakubkrehel/skills) for the better-\* skills, `break` and `explain-interface`
- [openai/skills](https://github.com/openai/skills) for `playwright` and `hatch-pet`
- [obra/superpowers](https://github.com/obra/superpowers) for `receiving-code-review` and the hook runner
- [anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official/tree/main/plugins/playground) for `playground`
- [softaworks/agent-toolkit](https://github.com/softaworks/agent-toolkit) for `session-handoff`
- [skills-il/government-services](https://github.com/skills-il/government-services) for `israel-gov-api`
- [wheresryan22/anatomy](https://github.com/wheresryan22/anatomy) for `anatomy`
- [helloianneo/ian-xiaohei-illustrations](https://github.com/helloianneo/ian-xiaohei-illustrations) for `ian-xiaohei-illustrations`
- [nbbaier/agent-skills](https://github.com/nbbaier/agent-skills) for `tufte-viz`
- [stellarlinkco/myclaude](https://github.com/stellarlinkco/myclaude) for `product-requirements`
- [rhino-ty/apca-contrast-skill](https://github.com/rhino-ty/apca-contrast-skill) for `apca-contrast`

License files for vendored code are in [`licenses/`](licenses) and `vendor/pstack/LICENSE`. Versions are pinned in [UPSTREAM.md](UPSTREAM.md).
