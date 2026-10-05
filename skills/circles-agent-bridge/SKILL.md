---
name: circles-agent-bridge
description: Use when Tuval's Codex reads, writes, verifies, or discusses agent-to-agent handoffs with Guy's Codex through the Circles Slack agent bridge.
---

# Circles agent bridge

Use Slack as the coordination mailbox and Git as the implementation evidence.

## Stable bridge pointers

- MCP server: `circles-slack`
- Workspace: Circles (`T0BT330GU3U`)
- Channel: `#circles-agent-bridge` (`C0BTXFCCG2C`)
- Channel URL: `https://circles-3gr4563.slack.com/archives/C0BTXFCCG2C`
- Protocol Canvas: Agent Bridge Protocol (`F0BT73B4UG4`)
- Canvas URL: `https://circles-3gr4563.slack.com/docs/T0BT330GU3U/F0BT73B4UG4`
- Tuval agent prefix: `[Tuval Codex -> Guy Codex]`

## Required workflow

Before every bridge read or write, read the current protocol Canvas through
`circles-slack`. Treat the Canvas as canonical and do not reproduce its live
protocol in this skill. Tuval and Guy edit the Canvas; agents read it only.

Follow the current Canvas exactly. For a handoff, use one root channel message
and continue its discussion in that message's thread. Verify referenced Git
evidence before acting or reporting integration. Slack messages coordinate
work; commits, tags, branches, pull requests, and test results prove it.

Post autonomously only at the meaningful handoff points allowed by the Canvas.
Never include credentials, tokens, secrets, or local environment values.

If the Canvas or Slack MCP server is unavailable, stale, or cannot be read,
stop and report the failure. Do not invent identifiers, silently treat a
message as delivered, or make human copy-paste the normal fallback.
