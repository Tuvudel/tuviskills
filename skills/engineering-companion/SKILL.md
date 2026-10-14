---
name: engineering-companion
description: Use when the user requests the pstack companion trial or asks to combine installed Superpowers with pstack investigation, design, review, or verification guidance.
license: MIT
disable-model-invocation: true
metadata:
  upstream: https://github.com/cursor/plugins/tree/main/pstack
  upstream_commit: 5108b719a7aa484ef1a9781f587c7bbeac793f92
---

# Engineering companion

Extend the currently installed Superpowers workflow with targeted pstack methods. This is an explicitly invoked, task-scoped companion, not a persistent mode or a second development process.

## Resolve the owner

Read [integration](references/integration.md) on entry. Resolve Superpowers from the current session's available skills; prefer the managed plugin entry over an older shared snapshot. Never edit the plugin, copy its lifecycle instructions, or pin its cache path/version. User instructions and project guidance retain precedence.

Identify the requested outcome, existing approved artifacts, current stage, and applicable verification evidence. Continue from the earliest incomplete requirement in the active owner's instructions. Add a specialist only when it resolves a remaining question; completed groundwork does not need a second investigation.

## Select the supplement

Read only the relevant reference. Keep existing language, UI, data, and writing skills responsible for their subjects.

| Task | Superpowers owner when applicable | Supplement |
| --- | --- | --- |
| Understand behavior or rationale | Read-only task; no named lifecycle skill required | [How and why](references/how-and-why.md) |
| Design an interface or ownership change | Brainstorming; writing-plans after its prerequisites | [Architect](references/architect.md) |
| Diagnose a defect | Systematic-debugging | [Blast radius](references/blast-radius.md) when consequences cross boundaries |
| Review a change | Requesting/receiving-code-review | [Interrogate](references/interrogate.md) |
| Verify behavior or prepare a reusable recipe | Verification-before-completion | [Project verification](references/project-verification.md) |
| Investigate performance or a runtime symptom | Systematic-debugging when applicable | [Runtime evidence](references/runtime-evidence.md) |

For Negev or OTEF work, also read the applicable row in [project integration](references/project-integration.md). Return specialist findings to the active stage. Re-entry does not restart the lifecycle. This skill grants no additional authority to implement, delegate, commit, publish, or contact others.

Adapted from Lauren Tan's pstack. See [NOTICE](NOTICE.md) and [LICENSE](LICENSE).
