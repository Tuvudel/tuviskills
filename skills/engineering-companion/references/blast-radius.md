# Blast radius

Investigate what a change can break outside its diff. Start by stating the changed behavior and the one or two assumptions its safety depends on.

Trace relevant consumers beyond symbol search: serialized data, stable identifiers, database and API contracts, pinned dependency behavior and patches, lifecycle timing, feature flags, and delayed commands. Keep risks with a reachable mechanism. Do not invent callers or assign numerical probabilities without evidence.

For each critical assumption, state the evidence level reached:

1. Unsupported statement.
2. Implementation or authoritative dependency source identified.
3. Failure path traced and shown reachable or excluded.
4. Actual code exercised by a focused probe or behavioral test.
5. Relevant user journey reproduced on the running application.

Run the smallest authorized check that can disprove the important assumption, using disposable state when the operation mutates data. Inspect its output and side effects. A probe of a substitute library version or internal setter does not prove the shipping user path. If actual execution is unavailable, mark the assumption unproven and identify the missing check.

Return changed behavior, critical assumptions and their evidence, confirmed risks, cleared risks, and the next required verification. Reuse the active project's tests and acceptance records; do not widen the implementation or rerun unrelated suites as part of analysis.
