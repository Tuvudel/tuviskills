---
name: engineering-companion
description: "Use alongside coding-workflow when substantive engineering work needs a deeper pstack method (how/why, architect, blast radius, interrogate, project verification, runtime evidence), or for Negev/OTEF project pointers. Skip trivial edits."
license: MIT
disable-model-invocation: false
metadata:
  upstream: https://github.com/cursor/plugins/tree/main/pstack
  upstream_commit: 5108b719a7aa484ef1a9781f587c7bbeac793f92
---

# Engineering companion

Extend the lifecycle skills routed by coding-workflow with targeted pstack methods. This is a personal default for substantive engineering tasks, activated through personal rules or skill selection. It is not a second development process. The user can opt out for a task.

## Resolve the owner

On task start or resume, after compaction, and before entering a different lifecycle phase, recover this routing table and read the applicable supplement if it is absent from current context. Read [integration](references/integration.md) on entry. The lifecycle skills (brainstorming, writing-plans, systematic-debugging, code review, verification) are personal skills in this repository, no longer a plugin; coding-workflow routes between them. User instructions and project guidance retain precedence.

Identify the requested outcome, existing approved artifacts, current stage, and applicable verification evidence. Continue from the earliest incomplete requirement in the active owner's instructions. Add a specialist only when it resolves a remaining question; completed groundwork does not need a second investigation.

## Select the supplement

Read only the relevant reference. Keep existing language, UI, data, and writing skills responsible for their subjects.

| Task | Lifecycle owner when applicable | Supplement |
| --- | --- | --- |
| Understand behavior or rationale | Read-only task; no named lifecycle skill required | [How and why](references/how-and-why.md) |
| Design an interface or ownership change | Brainstorming; writing-plans after its prerequisites | [Architect](references/architect.md) |
| Diagnose a defect | Systematic-debugging | [Blast radius](references/blast-radius.md) when consequences cross boundaries |
| Review a change | Requesting/receiving-code-review | [Interrogate](references/interrogate.md) |
| Verify behavior or prepare a reusable recipe | Verification-before-completion | [Project verification](references/project-verification.md) |
| Investigate performance or a runtime symptom | Systematic-debugging when applicable | [Runtime evidence](references/runtime-evidence.md) |

For Negev or OTEF work, also read the applicable row in [project integration](references/project-integration.md). Return specialist findings to the active stage. Re-entry does not restart the lifecycle. This skill grants no additional authority to implement, delegate, commit, publish, or contact others.

For delegated work, pass the companion path and only the applicable reference paths in the task brief. In handoffs, preserve the active phase, approved-artifact pointers, relevant supplements, and outstanding gates. Recover existing task records when context is missing; do not invent prior approvals. Personal rules provide a durable entry point, but instructions alone are not a verified runtime hook or a guarantee of post-compaction execution.

Adapted from Lauren Tan's pstack. See [NOTICE](NOTICE.md) and [LICENSE](LICENSE).
