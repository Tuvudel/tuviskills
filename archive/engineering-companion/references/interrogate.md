# Interrogate

Add adversarial scrutiny to the review already in progress. State the requested behavior and constraints before judging the diff. Review the current change and its relevant callers, not hypothetical future requirements.

Use independent reviewers only when justified and authorized. Give each the same intent, change, and necessary surrounding context. Select relevant lenses such as correctness, data contracts, security, maintainability, or user-visible behavior. Reuse the existing review phase rather than add a second mandatory panel.

As lead reviewer, trace each proposed failure through the real callers and boundaries. Read evidence that clears a risk as carefully as evidence that supports it. Agreement is a search priority, not proof; one demonstrated correctness bug remains actionable even when other reviewers missed it.

Classify findings:

| Verdict | Requirement |
| --- | --- |
| Act on | A concrete failure path or material maintainability problem within the actual goals |
| Consider | A supported concern whose benefit versus cost remains uncertain |
| Noted | Valid context with no justified change in the current task |
| Dismissed | Refuted, outside scope, or a preference without a demonstrated problem |

Each actionable item names the mechanism, source location, consequence, evidence, and smallest appropriate verification. Retain consequential disagreements and the reason for dismissal. A majority null-crash finding is dismissed when real callers exclude null; a lone stale-command path is retained when the path is reachable.

Return the filtered findings to the active reviewer/implementer. The review itself does not authorize fixes, commits, publishing, new abstractions, or removal of constraint comments. Follow existing review and verification requirements for an authorized fix. Do not claim model diversity when all reviewers used the same model.
