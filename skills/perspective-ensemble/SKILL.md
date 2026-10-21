---
name: perspective-ensemble
description: "Use for non-code strategy, product, adoption, org, or ethics decisions that prototyping or measurement can't settle: runs a pre-mortem with 2-3 independent critics on different models and returns tradeoffs, early warnings, and what would change the call. Not for code or design questions (interrogate, arena, or poteto-mode's prototype playbook)."
---

# Perspective ensemble

Use this when the decision is about strategy, product direction, adoption, organization, or ethics, and no experiment you can run this week would settle it. If a prototype, benchmark, or the repo's verification skill can answer the question, do that instead. Code review goes to interrogate, competing designs to arena or architect, and product or UX alternatives to poteto-mode's prototype playbook.

## Run it

1. State the decision in one sentence, the option currently favored, and what is already known. Mark guesses as guesses.
2. Spawn 2-3 critics as fresh subagents. Give each the same brief (decision, options, known facts) and none of your own reasoning. Put them on different available models: in Cursor, per the pstack-models rule; in Codex, `gpt-6.1-sol` and `gpt-6-luna` (never `gpt-6-astra` unless Tuval names it); in Claude Code, Opus and Sonnet. With only one model, use different reasoning efforts and say that independence is reduced. Run inline only for a small, low-stakes question, and say so.
3. Give each critic a different job, not a persona:
   - **Tradeoffs:** which legitimate goals pull against each other, and what choosing the favored option gives up.
   - **Pre-mortem:** it is a year later and this failed. Write the most likely story of how.
   - **Adoption** (optional third): who has to change behavior, who pays, who maintains it, and who quietly opts out.
4. Each attack ends with a cheap probe that could show the worry is real. Product or UX probes go to the prototype playbook or the repo's verification skill. Pure strategy probes are real-world checks: ask two users, read the support queue, price the alternative, check what a comparable team did, run a small pilot.
5. Synthesize. Keep real disagreements visible instead of averaging them away, and drop attacks that rephrase another critic's.

## Reply

- **Decision and favored option** (one line each).
- **Tradeoffs:** the 2-3 tensions that actually cost something.
- **Pre-mortem:** the strongest failure story, in one paragraph.
- **Attacks and probes:** each worry with its cheap probe and who runs it.
- **Early warnings:** observable signals that the pre-mortem is coming true.
- **Recommendation:** the choice, because..., and **would revise if...**.

Skip the ensemble for factual questions, mechanical tasks, or when the user asks for a single quick take. Tuval's instructions override the format.
