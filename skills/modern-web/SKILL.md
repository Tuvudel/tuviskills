---
name: modern-web
description: Use when writing or changing web UI, HTML, CSS, or client-side browser JavaScript, to look up today's built-in platform features before adding a library or an older pattern. Not for backend, Python, data or GIS scripts, CI, tooling, tests, copy edits, or 3D/WebGL internals unless DOM or CSS is involved.
---

# Modern web

Before you write or change HTML, CSS, or client-side browser JavaScript, look up the current built-in way to do it with the [Modern Web Guidance](https://github.com/GoogleChrome/modern-web-guidance) CLI. Use it only for that work, not as a mandatory first step for every task.

`design-ui` and the better-* skills decide how something looks, reads, and is laid out. This skill decides which browser feature or API to build it with.

## Do not use for

Backend work, Python, data or GIS scripts, CI, tooling, tests, copy edits, or 3D/WebGL internals unless the change also involves DOM or CSS.

## Lookup

Search with a 2-5 word query for one capability. Keep it generic: name the UI pattern or platform feature, not the framework, file, or product. Split mixed tasks into separate searches. If the user described intent without naming the control, translate it. For example, "confirm first" becomes `confirmation dialog`.

```sh
npx -y modern-web-guidance@latest search "<query>"
```

The command returns `[{ "id", "description" }, ...]`. Use the descriptions to decide whether a guide matches.

- If a description matches, retrieve that id. Do not also run `list`.
- If the results are empty or unrelated, rephrase the search once with a concrete HTML, CSS, or UI noun. If still nothing matches, continue without a guide.
- Do not invent guide names or quotes from memory. If context was compacted, search and retrieve again.

```sh
npx -y modern-web-guidance@latest retrieve "<id>"
```

You can pass several ids, separated by commas. If the command writes a large result to a temp file, read that file with your file-reading tool.

Follow the guide. If a feature is not Baseline widely available, use the fallback the guide recommends. Adapt vanilla HTML, CSS, and JS examples to the project's framework without dropping the modern feature. For new HTML attributes in React, spread or cast them rather than removing them. Call `showModal()` and similar methods through refs. Guard `window` and `HTMLElement` in SSR.

## Browser support

Baseline widely available features are fine as-is. Use a newer feature only with the fallback the guide gives. A project's `AGENTS.md` can override this.

## Do not add a summary section

Do not add a `### Modern Web Guidance` section to replies. If a guide mattered, mention its id briefly in the PR description's Heads up or write-up when that is relevant.

## Broad audits

Run this only when asked for a broad modernization audit of an existing codebase, not when adding or fixing a specific feature:

```sh
npx -y modern-web-guidance@latest legacy-scan <path> --json
```

`legacy-scan` covers about 20% of the catalog. Check each finding against the guide's rules for when to keep or drop it, then report. Retrieve and apply guides only if the user asked to modernize, not only to audit.

## Running the CLI

The command needs outbound network access. In Codex or other sandboxes, allow network before the first run. On Windows, use `npx.cmd`. If `~/.npm` is read-only, set `NPM_CONFIG_CACHE=/tmp/npm-cache`. If the command hangs because you are offline, retry with `npx --offline`.

This skill is a wrapper around the Modern Web Guidance CLI (Apache-2.0). It is not an unmodified copy of the upstream skill.
