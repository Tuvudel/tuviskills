# How and why

Answer how the code works from the current implementation. Answer why it exists from the historical record. Do not turn an explanation request into a change.

## How

For a narrow question, read the function, relevant types, and enough callers to explain inputs, decisions, outputs, state, and side effects. Explain inline. For a subsystem, follow the user-visible path across ownership boundaries; use disjoint readers only when authorized and useful. Keep source locations for important claims.

Give the smallest complete explanation first. Use a flow or structural diagram when it helps; develop a complex picture progressively instead of presenting every component at once. Preserve uncertainty when combining behavior with rationale. Existing teaching, visualization, and writing skills supply presentation guidance.

## Why

Start at the code anchor, then trace the meaningful history before a rename or refactor: commits, PR discussion, tests, and linked decisions. Query connected documents or conversations only when they are relevant to a concrete unresolved question. Record an inaccessible source as a gap; an available connector does not require an exhaustive search.

Use these evidence levels:

| Level | What supports the claim |
| --- | --- |
| Documented | An author or decision record explicitly states the reason |
| Supported | Several independent indirect sources support the interpretation |
| Inferred | The mechanism or surrounding context suggests a reason |
| Speculative | A possible explanation competes with others on thin evidence |
| Unknown | The searched record does not establish the reason |

Code establishes behavior, not author intent. A refactor's blame entry is not necessarily the original decision. A PR mentioning performance does not establish why a specific threshold was chosen. Explain the evidence chain and preserve competing explanations.

Return current behavior, documented reasons, labeled interpretations, and remaining gaps in proportion to the question. When this investigation informs a change, extract the contracts to preserve and the assumptions needing verification. Do not create a second specification.
