---
name: new-branch-and-pr
description: "Use when starting a change that should land as its own PR: create a fresh branch, do the work, and open the pull request."
---

# New branch and PR

## Trigger

Starting work that should be shipped through a clean branch and pull request workflow.

## Workflow

1. Ensure the working tree is clean or explicitly handled.
2. Create a descriptive branch from the latest main.
3. Complete implementation and tests.
4. Commit focused changes and push.
5. Create a concise PR that explains why the change was needed, what changed, and the resulting behavior for a reader who has not seen the chat. Follow `google-developer-style` when available.

## Guardrails

- Keep branch scope focused on one change set.
- Perform appropriate checks before requesting review. For owner-maintained repositories, omit routine testing and verification sections from the PR description; include them only when the user requests them or contribution requirements explicitly require them.
- State known failures or unverified behavior that materially limit the change as a relevant limitation. Keep the description focused on the final diff, not the sequence of work.

## Output

- New branch name
- PR description explaining the change and its purpose
- PR URL
