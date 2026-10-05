---
name: clean-product-research-illustrations
description: Use when creating, reviewing, or revising image prompts for polished product-research article illustrations, UX research visuals, report graphics, or research-facing conceptual scenes
---

# Clean Product Research Illustrations

## Overview

Create polished editorial illustrations of product research in action. The output should feel like a thoughtful research/report visual: clean, elaborate, specific, and human-operated, not a sparse mascot doodle, stock SaaS graphic, UI screenshot, or PPT infographic.

North star: **This is an editorial illustration of people and product research in action, not a diagram explaining product research.**

## Workflow

1. Identify the section's real claim: what insight, tension, decision, or evidence path should the image support?
2. Choose one cohesive scene: a workshop table, research synthesis wall, handoff tray, field observation, review desk, prototype critique, evidence archive, or team calibration moment.
3. Make the scene specific with artifacts: notes, checklists, folders, anonymized feedback cards, printed journey sheets, clipped evidence, low-detail prototypes, attendance sheets, sticky notes, pens, trays, locks, or review boards.
4. Keep the illustration editorial, not literal UI: use objects, posture, gestures, and spatial relationships to carry meaning.
5. Write an explicit negative prompt block every time.
6. After generation, inspect the image and reject it if it looks like Xiaohei, stock SaaS art, a dashboard, a product screenshot, or a slide infographic.

## Style Defaults

- Landscape article ratio, usually 16:9.
- Clean refined editorial digital illustration.
- Warm but restrained palette: soft whites, muted greens, amber/gold, light blue, charcoal ink.
- Rich enough to inspect: layered objects, purposeful gestures, workspace detail, evidence fragments.
- Human-operated tone: collaboration, judgment, caution, fieldwork, synthesis, handoff.
- No readable text unless the user explicitly needs labels. If notes or screens appear, use abstract marks or illegible scribbles.

## Prompt Template

```text
Create an elaborate editorial product-research article illustration about: [theme].

Purpose:
Support a thoughtful article section about [research question / product problem / decision tension] without explaining it with labels.

Scene:
Depict [specific human research situation] with [concrete artifacts: notes, anonymized feedback cards, checklist, synthesis wall, review tray, prototype props, attendance sheet, evidence folders]. Make the scene feel observed, specific, and layered.

Style:
Clean refined editorial digital illustration, warm restrained palette, sophisticated lighting, rich but orderly detail, human-operated product research mood, landscape 16:9.

Composition:
One cohesive scene. Use depth, objects, gestures, and spatial relationships to communicate the idea.

Text:
No readable text. Use only abstract marks or illegible scribbles on notes/screens.

Avoid:
Sparse white doodle style, Xiaohei-like black mascot figures, cute minimal line art, generic SaaS blog art, corporate Memphis, abstract floating cards, dashboards, realistic app screens, browser chrome, labeled arrows, numbered steps, charts, KPI cards, quadrant diagrams, slide infographic layout, stock metaphors, AI magic, surveillance, person scoring, compatibility percentages, rankings.
```

## QA Checklist

- Does it show one coherent research/product scene rather than a diagram board?
- Does the image support the section's claim without needing labels?
- Are people represented as researchers, operators, or participants in context, not mascots?
- Are concrete artifacts present and relevant to the product problem?
- Is there enough detail to feel deliberate, but not so much that it becomes clutter?
- Is there no readable fake UI, fake metric, fake brand, fake citation, or unintended claim?
- Could it be mistaken for Xiaohei, stock SaaS art, a dashboard screenshot, or a PPT infographic? If yes, revise.

## Common Prompt Corrections

| Drift | Fix |
| --- | --- |
| Sparse mascot doodle | Add realistic research artifacts, richer workspace detail, no mascot language. |
| Stock SaaS illustration | Remove floating cards, gradients, abstract icons, handshakes, rockets, puzzle pieces, lightbulbs. |
| UI screenshot | Convert screens into low-detail props with illegible marks; move meaning into human review activity. |
| PPT infographic | Remove headings, arrows, numbered nodes, KPI cards, and labels; describe one photographed-feeling scene. |
| Too decorative | Tie every object to the section's insight, evidence path, or decision tension. |
