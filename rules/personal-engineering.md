## Personal skills workflow

Engineering work runs on pstack (vendored unmodified in `vendor/pstack/`): the always-on pstack rule loads `poteto-mode`, which routes to its playbooks, skills, and principles. Other personal entry skills: `design-ui` for UI, `illustrate` for figures and charts, `docs-writing` for prose. Personal skills live in `~/.agents/skills/<name>/SKILL.md` (Claude Code: `~/.claude/skills/<name>/SKILL.md`). Re-read poteto-mode at task start, after resume or compaction, and when the phase changes. Skip all of this for trivial edits and ordinary conversation. User and project instructions take precedence over skills, and the user can opt out for a task.

## Code conventions

- Keep imports at the top of the module. No inline imports in function bodies, type annotations, or interface fields unless a documented circular dependency requires it.
- In TypeScript, switch statements over discriminated unions or enums end with a `never` check in the default case, so a new variant fails to compile until it is handled.
