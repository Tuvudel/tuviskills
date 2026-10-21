# Runtime evidence

For a runtime symptom, capture the relevant live signal before calling a source-level candidate its cause. Match the surface: CPU profile for idle work, heap/retainer evidence for growth, browser trace for layout or visual timing, and protocol/log evidence for synchronization.

Reduce the artifact to the responsible mechanism and map it to a source symbol. Use a focused, authorized experiment to confirm the mechanism. Parse large artifacts in an independent reader only when justified and authorized. Live instrumentation is not permission to alter production state or the user's active session.

If live access is unavailable, return the source candidate and the exact next measurement. Do not claim a diagnosis, fix, or performance improvement from source inspection alone.

## Before comparing performance

Read the measurement harness and state the actual claim. Confirm completed work and correct outputs inside the timed region; count errors and retries. Match realistic workload, versions, build settings, cache state, and concurrency. Use the project's accepted harness rather than change it to improve the result.

Profile separately from reported timing runs. Alternate baseline/treatment runs, sample enough to characterize noise, and report the run count and variation. Identify the limiting mechanism and check the result against plausible physical/workload limits. Include the end-to-end path a user waits for when a microbenchmark informs a product decision.

Return faster, slower, no measurable difference, or inconclusive with units, workload, samples, variation, and evidence. One requested ballpark is labeled as one run and does not establish a winner between alternatives. A fast failure, unconsumed generator, or unresolved promise is not completed work.
