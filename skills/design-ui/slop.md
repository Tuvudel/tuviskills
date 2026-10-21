# Slop

Slop is what ships when nobody decided. Each pattern below is fine once, chosen on purpose. It is slop when it arrives by default, on every section, or with nothing to carry. The test for every element and string: what does the user lose without it? No answer, no element.

Banning a list does not work on its own. Avoid one default and the next popular one takes its place. Run the [subtraction pass](#subtraction-pass), not a lookup.

Each pattern's rule lives in its owning skill; this file is the index the pass checks against.

## Patterns

| Pattern | Spot it | Default fix | Legitimate when | Owner |
| --- | --- | --- | --- | --- |
| Eyebrow / overline | Small uppercase or mono label above a heading, often on every section | Delete. Fold any real information into the heading | It carries navigation or category the heading lacks: a breadcrumb, a step ("Step 2 of 4"), a section in a long doc | better-writing |
| Subtitle restating the title | Second line says the heading again in more words | Delete | It adds a fact the title lacks: a count, a date, a scope, a consequence | better-writing |
| Tagline / hero filler | Headline that would fit any product ("Elevate your workflow"), adjectives in place of facts | Say what it does, for whom, specifically. Or cut the hero | Marketing page with a real, specific claim | better-writing |
| Decorative badge / pill / sparkle / emoji | "✨ New", "AI-powered" pill, emoji bullets, pill above the headline | Delete | A real state or count the user acts on: unread, Beta, Draft, Failed | better-ui |
| Icon on everything | Icon beside every label, icon tile above every card heading | Keep icons only where they speed recognition or stand alone with an accessible name | Toolbars, nav, file types, status | better-ui |
| Gradient text, glows, halos | `background-clip: text`, radial glow behind content, neon borders | One solid color; emphasis through size and weight | A brand mark that is itself a gradient | better-colors |
| Card in card | A bordered or shadowed container inside another | Flatten: one surface, group inner content with space | The inner element is independently interactive (draggable, selectable row) | better-layout |
| Excess borders, dividers, shadows | Border and shadow on the same box; a divider between every row; same shadow on every box | Space first; one edge treatment per surface | Dense tables, real elevation (menus, dialogs) | better-layout, better-ui |
| Made-up stats | "10x faster", "99.9% uptime", "10,000+ teams" with no source | Delete, or use a real number with its source and context | The number is true, sourced and the reason the user is here | better-writing |
| Feature grid of three | Three identical icon + heading + blurb cards, repeated | Show the product, or a list that ranks by importance | The items really are parallel and equal | better-layout |
| Redundant helper text / placeholders | Label, placeholder, helper and tooltip saying the same thing | One label; a placeholder only as a format example; helper text only for a constraint | A non-obvious constraint (password rules, units) | better-writing |
| Toast for a trivial action | "Saved!" toast for a visible, instant change | Let the change itself be the feedback | The result is off-screen, delayed, or undoable ("Archived. Undo") | better-writing |
| Gratuitous animation / stagger | Entrances on routine views, staggered lists, pulsing dots, bounce easing | Remove; instant or ≤150ms opacity/color | Infrequent staged moments, motion that explains a spatial change | better-ui |
| Empty-state cheerleading | "You're all caught up! 🎉", "Let's get started on your journey!" | What this place is, how to fill it, one action | A real completion the user worked toward, once | better-writing |
| Over-explaining microcopy | Intro sentence on a self-evident screen, "Click the button below to…" | Delete; let labels and verbs carry it | First-run of a genuinely unfamiliar concept | better-writing |
| Too many CTAs | Several filled buttons, or "Get started" and "Learn more" and "Book a demo" side by side | One primary per view; demote or cut the rest | Never more than one filled primary | better-colors |

## Subtraction pass

Mandatory before you finish building, and in every review. Checkable steps:

1. **Inventory.** List every visible element and string in scope: headings, labels above or below them, badges, icons, dividers, containers, toasts, animations, buttons.
2. **Justify or delete.** For each, write the one thing the user loses without it. Delete anything with no answer, or whose answer is "it looks nicer" or "fills space". Check each against the table above.
3. **Merge duplicates.** Where two strings or elements say one thing, keep one.
4. **Recheck the rest.** After deleting, check spacing and hierarchy still hold; do not refill the gap.
5. **Report.** List what was removed, each with a one-line reason, and anything kept from the table with its "legitimate when" reason. A pass that removed nothing says "Subtraction pass: nothing removed" and names what was inventoried.

In a review, each item the pass would delete is a finding owned by the skill in the **Owner** column, with `Delete` as the fix.

Sources: Jakub Krehel, [Less is more, more or less](https://jakub.kr/writing/less-is-more); Lauri Lännenmäki, [Is your website AI slop?](https://dev.to/laurilllll/is-your-website-ai-slop-how-to-tell-and-how-to-fix-it-1fn5); Impeccable, [AI slop patterns](https://impeccable.style/slop).
