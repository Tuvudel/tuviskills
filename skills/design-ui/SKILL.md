---
name: design-ui
description: Use when building, polishing, or reviewing any UI (component, page, layout, color, type, UI copy, accessibility) to pick the taste, checking, or browser-review skill. Not for figures or diagrams (illustrate) or docs prose (docs-writing).
---

# Design UI (router)

Taste comes from the better-* skills. Numbers come from deterministic checkers. Claims about how it looks come from screenshots, not from reading code.

| Need | Open |
|---|---|
| Overall review or "make it better" | better-interface (runs the whole better-* set) |
| Color system, palettes, tokens | better-colors, then apca-contrast to check |
| Type scale, fonts, wrapping | better-typography |
| Spacing, grouping, hierarchy, reading order | better-layout |
| Polish: radius, depth, icons, hit areas, motion | better-ui |
| UI copy: labels, buttons, errors, empty states | better-writing |
| Accessibility | better-accessibility, then apca-contrast for contrast numbers |
| Contrast numbers (APCA Lc, light/dark tokens) | apca-contrast (deterministic script) |
| Screenshots and the visual review loop | playwright: screenshot → review against better-* → fix → re-screenshot until clean; control-ui for a custom harness |
| Stress-test a component's states | break |
| Explore alternative designs | variant |
| "How was this built?" for a live site | explain-interface |
| Multi-step flows, onboarding | user-flows-and-guided-paths |
| Interactive configurator page | playground |
| Grok Bot UI | make-bot-ui, design-a-grok-bot |
| Hebrew UI copy (Circles) | circles-hebrew-content |

Report contrast in WCAG 2 ratios by default; give APCA Lc alongside when the user opts into APCA.
