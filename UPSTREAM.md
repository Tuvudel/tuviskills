# Upstream sources

| Source | What | Version | License |
|---|---|---|---|
| [cursor/plugins pstack](https://github.com/cursor/plugins/tree/main/pstack) | 55 skills listed in `scripts/pstack-skills.txt`; agents `poteto-agent`, `comment-sicko` | d457567 (2026-10-19), plugin 0.15.28 | MIT, `licenses/pstack-LICENSE` |
| pstack `make-bot-ui` | Box (Grok Bot) edit wins over pstack's copy | box version | MIT |
| [obra/superpowers](https://github.com/obra/superpowers) | brainstorming, writing-plans, subagent-driven-development, systematic-debugging, code review pair, worktrees, finishing, verification, writing-skills; `tdd/references/*`; `hooks/run-hook.cmd` | plugin 6.1.1 | MIT, `licenses/superpowers-LICENSE` |
| [cursor/plugins cursor-team-kit](https://github.com/cursor/plugins/tree/main/cursor-team-kit) | CI, PR, review, control-* skills; agents `ci-watcher`, `thermo-nuclear-code-quality-review`; rules folded into `rules/personal-engineering.md` | 1.2.0 | MIT, `licenses/cursor-team-kit-LICENSE` |
| [rhino-ty/apca-contrast-skill](https://github.com/rhino-ty/apca-contrast-skill) | `apca-contrast` | 32e2a95 | MIT |
| Anatomy skill (local zip) | `anatomy` | 2026-10-12 | MIT |

Local changes to vendored pstack skills: `sharpen`, `swarm`, `arena`, `tdd` are model-invocable (the `disable-model-invocation` flag was removed so routers and agents can pick them); descriptions sharpened for `sharpen`, `swarm`, `arena`, `unslop`, `typescript-best-practices`; `tdd` gained a Reference section; links from `poteto-help` to pstack's README and guide point at GitHub. Not imported: the Benny automation pack (see README).
