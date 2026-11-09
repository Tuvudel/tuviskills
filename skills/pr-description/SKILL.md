---
name: pr-description
description: Use whenever you write or update a pull request description. Puts a glanceable What/Why/Verify/Heads up top, and collapses the full agent write-up in a details/summary block so humans can skim. Also for "PR body format", "details summary PR", or rewriting a PR description to be readable at a glance.
---

# PR description

Write every PR body in this shape. A non-technical teammate should get the point from the top alone. Inspired by [Simon Willison's details/summary pattern](https://simonwillison.net/2026/Nov/9/details-summary/).

## Format

```markdown
**What:** One plain sentence on what this PR does.
**Why:** One sentence on the problem or the request behind it.

<screenshot or short before/after, if anything is visible>

**Verify:** ✅ <verify CLI pass/fail summary> (or what failed and why)
**Heads up:** Risks, breaking changes, or steps a reviewer must take. Write "None" if there are none.

<details>
<summary>Codex · <model> · <effort></summary>

Full agent write-up: approach, what changed, scope, blast radius, verification detail, decisions.
</details>
```

A tiny table is fine at the top for perf numbers.

## Rules

- Keep What, Why, Verify, and Heads up always visible. Never put them inside `<details>`.
- Write the top in plain words. No internal jargon, ticket IDs as the only explanation, or file-path essays.
- Name the real agent, model, and effort in `<summary>`. Never invent them. If one is unknown, omit that part (for example `Grok Bot` or `Codex · gpt-6.1-sol`).
- Never fabricate verify results. Report what you ran, or say you did not run a verify.
- Leave a blank line after `</summary>` so GitHub renders the Markdown inside the block.
- When poteto-mode's opening-a-pr sections apply (Why, What changed, Scope, Tradeoffs, Blast Radius, Verification), put them inside the details block. The glanceable top still owns What, Why, Verify, and Heads up.
- History cleanup and reviewability still belong to `make-pr-easy-to-review`. This skill owns the description shape only.

## Examples

### iso-israel #21

```markdown
**What:** Removes the renderer picker from the diagnostics panel and fixes a crash when switching renderers mid-blend.
**Why:** WebGL2 is the normal renderer, and switching during a terrain blend could draw with a renderer that was already shut down.

**Verify:** ✅ `scripts/verify.sh` passed
**Heads up:** WebGPU is now reachable only through the engineering checks. The fix also touches switching from Iso to Streets.

<details>
<summary>Codex</summary>

## Why
WebGL2 is the normal renderer. The viewer's diagnostics panel still offered three renderer choices. Changing backends during a terrain blend could also leave the viewer trying to draw with a disposed compositor.

## What changed
- Remove the renderer picker. Keep the active renderer readout and use the existing engineering API for backend checks.
- Detach a retiring renderer before queued terrain selection can start another blend.

## Scope
- The startup renderer stays WebGL2. WebGPU and forced WebGL2 remain available to engineering checks.

## Blast Radius
The lifecycle change also affects switching from Iso to Streets.

## Verification
- `scripts/verify.sh` passed on the identical legacy test inputs.
</details>
```

### nur-cityscope #50

```markdown
**What:** Adds the nine roadside shelters along Highway 232 to the map, and each one turns red as the investigation reaches it.
**Why:** The exhibit needs to show the shelters, and the 84 people killed at them, on the road it already draws.

**Verify:** Not run in this rewrite.
**Heads up:** Shelters only draw if their data file matches its recorded fingerprint, so a changed data file will make them disappear on purpose.

<details>
<summary>Agent</summary>

Nine shelters from the October 7 record sit on that road. They carry the 84 people tied directly to those sites. Each shelter turns incident red when a confirmed investigation feature comes within 25 m, when a Nova escape that ends there finishes, or when the general timeline reaches noon. The legend adds **מיגוניות** / **Roadside shelters**.
</details>
```
