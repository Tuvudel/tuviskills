---
name: matching-flow-lab
description: Use when designing or changing matching logic, selection policies, or participant/admin/host user flows that require fairness, explainability, and operational edge-case checks before implementation.
---

# Matching Flow Lab

## Overview

Use this skill for combined algorithm and workflow design.  
It treats matching policy, operator actions, and user-facing flow states as one system, not separate tasks.

## When to Use

Use this skill when:
- Matching or selection logic is being introduced or changed
- Admin/operator flow and participant outcomes must stay consistent
- Explainability copy or status semantics may change
- Fairness, edge cases, or refill/offer behavior need explicit treatment

Do not use this skill for:
- Visual polish-only UI work
- Pure technical refactors with unchanged matching behavior

## Design Frame

For each proposal, define:
- **Objective**: what "good matching" means for this event/workflow
- **Constraints**: eligibility, cohort size, deadlines, operational rules
- **Control points**: who can override and how
- **User visibility**: what each role sees and when

## Workflow

1. **State model first**
   - List all relevant states and transitions for participant/admin/host views.
   - Include failure and timeout states, not only happy paths.

2. **Decision policy sketch**
   - Inputs used for ranking or selection
   - Tie-breaker logic
   - Manual override points
   - Persistence boundary (what is stored and where)

3. **Fairness and risk pass**
   - Identify likely bias vectors and proxy risks
   - Add guardrails or review checkpoints
   - Define what to log for post-hoc audits

4. **Explainability pass**
   - Create role-specific explanation copy:
     - operator explanation
     - participant-facing explanation
   - Ensure copy is truthful to actual decision mechanics

5. **Operational resilience pass**
   - Simulate edge cases:
     - late cancellations
     - offer expiration/refill cycles
     - partial failures during persistence
     - rerun/recovery semantics

6. **Verification plan**
   - Scenario tests covering:
     - happy path
     - fairness-sensitive cases
     - rollback/recovery path
   - Define pass/fail signals for each scenario

## Required Output

- **Flow map** by role (participant/admin/host)
- **Policy table**:
  - decision point
  - inputs
  - rule
  - override policy
  - persisted artifact
- **Fairness and explainability notes**
- **Edge-case matrix**
- **Recommendation**:
  - proceed
  - proceed with guardrails
  - block pending product decision

## Quality Bar

- Every user-visible state maps to a real backend/decision state
- Manual overrides are explicit and auditable
- Explainability copy matches actual decision behavior
- No matching change ships without edge-case and rollback scenarios
