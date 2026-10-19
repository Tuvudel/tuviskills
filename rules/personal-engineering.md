## Personal skills workflow

Before acting on a non-trivial task, check whether a personal skill applies, and if one does, open it and follow it. Start from the entry skill for the kind of work:

- `coding-workflow` for code: features, bugs, refactors, review, CI, shipping. `sharpen` is the default first step for unclear tasks.
- `design-ui` for UI: layout, color, type, UI copy, accessibility, screenshot review.
- `illustrate` for figures, diagrams, illustrations, and charts.
- `docs-writing` for prose: docs, READMEs, specs, PR text, Hebrew content.

Each entry skill is a short routing table that names the specialist skill to open. `using-skills` summarizes this. Skills live in `~/.agents/skills/<name>/SKILL.md` (Claude Code: `~/.claude/skills/<name>/SKILL.md`).

Re-check at task start, after resume or compaction, and at each phase change (clarify, plan, build, verify, ship). Keep the current approved stage and valid evidence. Include the relevant skill paths in delegated task briefs, and carry the phase, approved artifacts, and open gates into handoffs. For deeper engineering methods, `engineering-companion` adds pstack supplements. Skip all of this for trivial edits and ordinary conversation. User and project instructions take precedence over skills, and the user can opt out for a task.

## Code conventions

- Keep imports at the top of the module. No inline imports in function bodies, type annotations, or interface fields unless a documented circular dependency requires it.
- In TypeScript, switch statements over discriminated unions or enums end with a `never` check in the default case, so a new variant fails to compile until it is handled.
