---
name: coding-workflow
description: Use at the start of, or when switching phase in, any non-trivial engineering task (feature, bug, refactor, review, CI, ship) to pick the specialist skill for that phase. Skip for one-line edits.
---

# Coding workflow (router)

Use when starting or changing phase in engineering work. Open the skill for the current phase; open the next one when the phase changes. Project rules win over these skills.

| Phase / situation | Open |
|---|---|
| Task is unclear or could be aimed better (default first step) | sharpen; in-your-own-words to play the goal back |
| New feature or design with open questions | brainstorming (after sharpen) |
| Ideas need opposing views or a red team | perspective-ensemble |
| Understand how code works / why it is this way | how / why; teach for a plain explanation |
| Design types, modules, interfaces | architect; principle-type-system-discipline |
| Large migration or unknown-shape problem | figure-it-out |
| Write the plan | writing-plans |
| Execute a plan | subagent-driven-development (includes inline execution) |
| Independent slices or races in parallel | swarm |
| Competing candidates for one artifact | arena |
| Long or unattended run needs a decision log | show-me-your-work |
| Tests | tdd: only when asked, or the bug has a cheap local repro; principle-test-behavior-not-implementation |
| TypeScript files | typescript-best-practices |
| Bug, failing test, unexpected behavior | systematic-debugging; principle-fix-root-causes |
| Isolated workspace | using-git-worktrees |
| Drive a CLI/TUI or browser UI to verify | control-cli / control-ui / playwright |
| Before claiming done | verification-before-completion; verify-this for one claim; blast-radius before shipping |
| Build a reusable verifier | create-verification-skill / maintain-verification-skill (formal: create-/maintain-formal-verification-skill) |
| Perf / benchmarks | benchmark-checklist; principle-explain-the-number |
| Review code | requesting-code-review, interrogate, thermo-nuclear-code-quality-review, no-comments |
| Review feedback received | receiving-code-review; get-pr-comments to fetch it |
| Ship | review-and-ship, new-branch-and-pr, make-pr-easy-to-review, pr-review-canvas, finishing-a-development-branch |
| CI and build | fix-ci, loop-on-ci, fix-merge-conflicts, check-compiler-errors, run-smoke-tests |
| Formatting noise in the diff | git-diff-hygiene |
| Product/flow alignment (Circles) | product-alignment-gate, matching-flow-lab, user-flows-and-guided-paths |
| After a session | reflect, correct, session-handoff (write), recall / ketchup (read), what-did-i-get-done |
| Full opinionated mode, opt-in only | poteto-mode (setup-pstack configures its models; poteto-help explains it) |

Principles (`principle-*`) are one-rule skills; open one when its trigger applies, not by default.
