---
name: circles-hebrew-content
description: >-
  How to write and present information in the Circles project — Hebrew copy
  quality, language mixing rules, and structuring dense content for
  readability. Use when writing Hebrew-facing text (docs, mockups, dashboards,
  reports, in-app copy) or when presenting structured information like
  inventories, gap analyses, or status overviews.
---

# Writing & Presenting Information in Circles

## Rules vs gates

Most guidance here is principles — use judgment. A few critical checks are marked as **gates**. A gate is a concrete condition you evaluate before moving on: "Can I answer this specific question? If no, I'm not done." Gates exist where experience shows agents are most likely to skip a check by rationalizing it away. Don't skip gates.

## Language mixing

Hebrew is the primary language. English is reserved strictly for machine identifiers.

**Hebrew** — titles, headings, descriptions, status labels, action labels, explanations, error messages. Everything a human reads is Hebrew.

**English** — route paths, component names, table/column names, function names, enum values, package names. Always visually distinguished (monospace, `<code>` tags, or equivalent). Never mid-sentence as regular words.

### Gate: read it aloud

Before writing any Hebrew sentence, read it aloud. If you stumble on an English word → check: is it a code identifier? If yes, mark it as code and continue. If no, find the Hebrew word and rewrite. Do not proceed with the sentence until every non-code word is Hebrew.

Good: "הפיצ׳ר עדיין לא התחיל" (not "הפיצ׳ר עדיין not started")
Good: "שומר ל-`localStorage` בלבד" (code identifier stays English)
Bad: "ה-page הזה הוא placeholder" → "המסך הזה הוא שלד ריק"

### Don't translate identifiers

"טבלת `matching_responses`" is clear. "טבלת תגובות התאמה" is confusing — nobody will find that in the codebase. Keep identifiers as-is and wrap them in code formatting.

## Hebrew copy quality

1. **Talk like a colleague, not a manual** — "מארחים יכולים לראות סיכומים אבל לא לנהל" beats "תצוגת סיכום מצרפית זמינה למארח ללא יכולות ניהוליות"
2. **One idea per sentence** — if a sentence has "and also" or "in addition", split it
3. **Active voice** — "המארח רואה ארבעה אריחים" not "ארבעה אריחים מוצגים למארח"
4. **Use plain Hebrew words** over English-borrowed jargon when natural equivalents exist:

   | Instead of | Write |
   |-----------|-------|
   | placeholder | שלד / שלד ריק |
   | complete | מוכן |
   | partial | חלקי |
   | not started / missing | לא קיים / חסר |
   | deferred | מושהה |
   | stub | שלד |
   | high priority | עדיפות גבוהה |

5. **Keep descriptions short** — 2-3 sentences max per item. If more context is needed, separate it visually as a secondary note
6. **Self-contained** — each item (card, section, list entry) should make sense on its own without requiring the reader to have read everything above it

### Gate: description length

After writing a description, count the sentences. If there are more than 3 → split into a main description and a separate note, or cut. Do not move to the next item until the description is 3 sentences or fewer.

## Presenting dense information

When you have many items to show (screen lists, feature inventories, gap analyses), the format matters as much as the content.

### Cards over tables

Tables with 5+ columns become unreadable, especially in RTL. Instead, give each item its own block:

- **Name** — a Hebrew title that explains the item's purpose (not its code name)
- **Status** — a short visual indicator
- **Description** — 2-3 sentences of what it actually is/does
- **Note** (optional) — a secondary line for caveats, context, or links

This pattern works because each item tells its own story top-to-bottom. The reader doesn't need to track column headers across a wide row.

### When tables work

Tables are fine for genuinely columnar data — comparisons, metrics, short reference lookups. The rule of thumb: if the values are all short (a word or number) and the comparison between rows is the point, use a table.

### Gate: naming things in Hebrew

Every page, feature, or screen needs a Hebrew name. Before using any name, ask: could a non-developer understand what this is without seeing the code? If no → rewrite the name before proceeding. The code/component name can appear as a secondary identifier.

Good: "סביבת עבודה לאירוע" (with `/host/events/:eventId` as secondary)
Bad: "HostEventWorkspacePage"

Good: "לוח אישי" (with `/dashboard` as secondary)
Bad: "DashboardPage"

### Group by role/audience, not by implementation

When presenting an inventory, group items by who uses them (participant, host, admin), not by folder structure or technical module. Lead with the audience's perspective.

### Visual hierarchy for status

Use a consistent status vocabulary throughout a document:
- **מוכן** — feature is built and working
- **חלקי** — exists but incomplete or limited
- **שלד** — route exists, UI is empty placeholder
- **לא קיים** — documented/specced but no code at all
- **מושהה** — intentionally deferred, not a gap

## Structuring a status overview

When creating any "state of things" document (what's built, what's missing, priorities):

1. **Start with counts** — give the reader the shape before the details (e.g., "19 מוכנים, 1 חלקי, 7 שלדים")
2. **Show what's built, grouped by audience** — not just what's missing
3. **Describe gaps with impact** — "אין דרך להודיע למשתתפים שהתקבלו" is more useful than "communications system missing"
4. **End with priorities** — what to build first and why, in concrete language
5. **Flag doc drift** — if documentation and code disagree, call it out explicitly

## Checklist

- [ ] All explanatory text is Hebrew; English only for code identifiers
- [ ] Every item has a Hebrew name describing its purpose
- [ ] Descriptions are short, natural voice, active
- [ ] Dense lists use cards/blocks, not wide tables
- [ ] Items grouped by audience, not implementation
- [ ] Status vocabulary is consistent throughout
