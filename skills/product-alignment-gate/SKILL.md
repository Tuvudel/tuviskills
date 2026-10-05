---
name: product-alignment-gate
description: Use when proposing or changing app features, user flows, or copy and alignment must be checked against questionnaire intent, product docs, route guards, and role constraints before implementation.
---

# Product Alignment Gate

## Overview

Use this skill to stop drift between ideas and product intent.  
Before implementation, force a traceability pass from proposal to questionnaire goals, docs, and runtime constraints.

## When to Use

Use this skill when:
- A new feature, flow, screen, or copy change is proposed
- Existing behavior is being reshaped (especially routes or roles)
- Requirements feel fuzzy and scope might creep
- Multiple docs exist and source-of-truth risk is high

Do not use this skill for:
- Pure refactors with no behavior change
- Mechanical fixes with clear, local acceptance criteria

## Required Inputs

Collect and cite the relevant sources first:
- Product docs under `social-matching-web/docs/`
- Questionnaire-related artifacts (if present for the request)
- Matching V1 spec set when in scope:
  - `social-matching-web/docs/superpowers/specs/2026-05-06-circles-matching-v1-transparent-selection-design.md`
  - `social-matching-web/docs/superpowers/specs/2026-05-06-circles-matching-v1-flows-spec.md`
  - `social-matching-web/docs/superpowers/specs/2026-05-06-circles-matching-v1-algorithm-spec.md`
- Design system source:
  - `social-matching-web/DESIGN.md`
- Runtime route/guard files:
  - `social-matching-web/src/app/router/AppRouter.tsx`
  - `social-matching-web/src/app/router/guards.tsx`
- Current role/routing assumptions (participant/admin/host model)

If a source is missing, stop and ask for it. Do not invent policy.

## Source-of-Truth Precedence

Use this order to resolve conflicts:
1. Algorithm spec for data/logic/privacy contracts
2. Flows spec for UX state/role interactions
3. Overview spec for framing and phase boundaries
4. DESIGN.md for visual/copy tone rules
5. Mockups as communication artifacts (never the source of truth)

If mockups contradict specs, specs win.

## Gate Workflow

1. **Define proposed change**
   - One sentence: what changes for whom.
   - One sentence: what user outcome should improve.

2. **Build traceability matrix**
   - Map each proposed behavior to:
     - questionnaire intent (or "no questionnaire dependency")
     - doc source
     - runtime constraint (route guard, role gate, API boundary)
     - measurable acceptance criterion

3. **Run contradiction scan**
   - Flag mismatches between docs and runtime files.
   - Flag cases where behavior depends on undocumented assumptions.
   - Flag role leaks (participant/admin/host ambiguity).

4. **Screen contract coverage gate**
   - Build a screen inventory from the flows spec.
   - For each required screen/state, require:
     - route family
     - actor/role
     - device targets (mobile/desktop)
     - lifecycle states shown
     - primary CTA/next action
     - required payload/data contract reference
     - privacy boundary
     - phase (Phase 1 shipped vs Phase 2 target)
     - mockup file + anchor (or explicit gap)
   - Coverage evidence rule:
     - `covered` is allowed only when every required state and the primary action are explicitly evidenced by anchors/artifacts.
     - If even one required state/action is missing evidence, mark `partial` (never `covered`).
   - Any missing row is a blocker for "mockups are ready."

5. **Mockup readability gate**
   - Confirm explainer lane and product lane are visibly separated.
   - Confirm every explainer block maps to a concrete screen/interaction below it.
   - Confirm copy in the product lane is concise and non-duplicative per `DESIGN.md`.
   - Flag pages where explainer text overwhelms UI comprehension.

6. **Scope and risk gate**
   - Classify each item:
     - `in-scope now`
     - `defer`
     - `needs product decision`
   - For deferred/decision items, provide exact blocker.

7. **Ship/no-ship recommendation**
   - Approve only if every behavior has traceability + acceptance criteria.
   - Otherwise return a minimal decision packet of missing info.

## Output Format

Produce:
- **Alignment summary** (3-6 bullets)
- **Traceability matrix** with columns:
  - Behavior
  - User/role
  - Questionnaire intent
  - Source doc
  - Runtime constraint
  - Acceptance criteria
  - Status
- **Screen contract coverage matrix** with columns:
  - Screen id
  - Route
  - Role
  - Device
  - Required states
  - Primary action
  - Payload contract source
  - Phase
  - Mockup coverage
  - Gap severity
- **Open contradictions**
- **Decision**

## Quality Bar

- No implementation before alignment is explicit
- No role changes without guard/route verification
- No copy/flow changes without a measurable acceptance criterion
- No "spec complete" claim without screen contract coverage completeness
- No "mockup ready" claim without explainer-vs-product lane readability checks
- Prefer reducing scope over carrying unclear assumptions
