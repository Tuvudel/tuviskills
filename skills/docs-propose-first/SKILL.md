---
name: docs-propose-first
description: "Use when a propose-first docs bot drafts a docs patch from a merge wake or standing sweep: verify UX against the live UI, never ban what the code ships, keep superpowers gitignored, honor WIP quiet."
---
# Docs propose-first

Use this when Docs (or any propose-first docs bot) is about to propose a docs/plans/GAPS patch from a merge wake or a standing sweep.

## Product rules vs live UI

- Do not invent or enforce product bans that contradict shipped UI.
- Before proposing to remove or forbid a control (joystick, tab, layer, etc.), verify against the live code and the running UI — not against an old seed in a routine prompt or a remembered CoS note.
- If a CoS / standing rule conflicts with what the code does, treat the rule as an open question to Tuval, not as a patch default. Ask once; do not keep re-proposing the ban.

## Superpowers / agent plans

- Superpowers plans and specs stay local and gitignored. Do not propose pointing `AGENTS.md` or other tracked agent docs at those paths.
- Do not propose retargeting tracked docs at ignored Sept-locked (or similar) superpowers specs.
- If tracked docs already reference those paths, propose removing the reference — never expanding it.

## WIP quiet

- When Tuval says he will not reply until he asks for a sweep (or similar WIP quiet), stop sending “say yes” propose digests for residual/soft drift.
- Batch residual items for the next requested sweep. Stay quiet unless a hard documented contract actually breaks.
- A hard contract break still gets one short propose note. Soft drift and style nits wait.

## Propose shape

Keep proposals short: repo/branch, what is wrong now, the proposed fix. Wait for yes before editing. Never silent-rewrite.
