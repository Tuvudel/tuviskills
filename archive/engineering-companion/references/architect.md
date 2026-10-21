# Architect

Supply an interface and ownership sketch to the active design stage. The caller's usage comes first; derive inputs, outputs, domain types, and module responsibilities from that usage.

1. Read existing owners, callers, shared implementations, and the relevant accepted decisions. Reuse a clear contract before designing another implementation.
2. State the invariants and invalid states the interface must exclude. Validate external input at its boundary; keep framework, transport, and storage details out of unrelated callers.
3. Sketch the smallest suitable shape. For a consequential unresolved choice, compare structurally distinct alternatives; a settled design or routine function change does not require a competition.
4. Check whether callers must coordinate internals, two modules own the same mutable state, or a wrapper hides no complexity. Keep separate calculations independent even when their UI shares components.
5. Return usage, types/signatures or pseudocode, ownership, rationale, tradeoffs, and acceptance evidence to the current design artifact.

Remain inside the requested stage. Design-only work stops at the sketch. Implementation follows the active Superpowers prerequisites and the user's authorization, not pstack's default proceed-to-code behavior. Do not commit scaffolding or add dependencies as a side effect of design.

During implementation, repeated deviations of the same shape can indicate a wrong interface. Surface the pattern, trace its cause, and use the active owner's change procedure. One unexpected edge case alone does not justify redesigning the system.
