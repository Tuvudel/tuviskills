# pstack in Codex

pstack skills use Cursor names. In Codex, read this file once per session, then map each Cursor name in a pstack skill with the tables below. `<pstack>` is the vendored folder `vendor/pstack/` in Tuvudel/agent-skills (it holds `skills/`, `docs/`, `agents/`). If a Cursor field has no row, drop it and say so in one line. Never pass a field or value Codex rejects.

This adapter is personal, not part of pstack. It follows `<pstack>/docs/harness/claude-code.md`, adjusted for Codex as documented at <https://developers.openai.com/codex/subagents>, <https://developers.openai.com/codex/skills>, and <https://developers.openai.com/codex/models> (checked 2026-10-21).

## Tools

| Cursor | Codex |
| --- | --- |
| `Task` | Spawn a Codex subagent. Codex spawns one when you ask directly or when a skill or `AGENTS.md` instruction asks for it, so say "spawn a subagent" with the brief. Give its model and `model_reasoning_effort` per [Models](#models). |
| `AskQuestion` | Ask in plain text. In `codex exec` (non-interactive) nobody answers: apply the default and report it. |
| Open a todolist | Use Codex's plan tool if the session offers it. Otherwise keep the list in your reply and update it at each phase. |
| Run another pstack skill (`/name` or "the **name** skill") | Read `<pstack>/skills/<name>/SKILL.md` and follow it. When you tell the user to type it, write `$name` (Codex mentions skills with `$`, or `/skills`). |
| `Grep`, `Glob` | Shell with `rg`. |

## Subagent fields

| Cursor | Codex |
| --- | --- |
| `subagent_type: generalPurpose` | The built-in `default` agent, or `worker` for implementation and fixes. |
| `poteto-agent`, `comment-sicko` | The custom agents of the same name in `~/.codex/agents/*.toml` (installed from `<pstack>/agents/` by `install-integrations.ps1`). |
| `readonly: true` | The built-in `explorer` agent, and the brief says "do not edit files". Subagents inherit the parent's sandbox, so this is an instruction, not a guarantee: check `git status` afterwards. |
| `readonly: false` | `worker` or `default`. |
| `environment: "cloud"` | A local subagent. Codex has no Cursor cloud agents. Parallel writers each get their own `git worktree` and branch (one writer per worktree, per principle-separate-before-serializing-shared-state); read-only fan-out shares the checkout. |
| `environment: "local"` | Omit. |
| `cloud_base_branch: <b>` | Tell the worker to check out `<b>` (in its worktree) first. |
| `run_in_background: true` | Omit. Codex runs the requested subagents in parallel and returns when their results are in. Spawn every independent unit in one request, then collect. |
| `resume` | Send the follow-up to the existing agent thread (`/subagents` lists them). If it was closed, spawn a new agent and paste the earlier result into its brief. |
| `file_attachments` | List the paths in the brief. |
| Concurrency | Capped by `agents.max_concurrent_threads_per_session` in `~/.codex/config.toml`. A swarm or arena wider than the cap runs in waves. |

## Models

Codex subagents can use different models and reasoning efforts, but only OpenAI models. Resolution order: explicit spawn value, then `[agents] default_subagent_model` / `default_subagent_reasoning_effort`, then the parent. A custom agent file's `model` / `model_reasoning_effort` win over all of these. Efforts, low to high: `low`, `medium`, `high`, `xhigh`, `max` (`ultra` is a subagent mode, not a per-agent effort; Luna has no `ultra`).

Models as of 2026-10-21: `gpt-6.1-sol` (the default for demanding agents) and `gpt-6-luna` (fast, for clear high-volume work). **Never use `gpt-6-astra` unless the user names it in their prompt for that task**; no role, panel, or judge defaults to it. Use only models the account lists in `/model`; if one is missing, say so.

| pstack slug or role | Codex model and effort |
| --- | --- |
| `inherit-parent`, `auto` | Omit `model` and effort; the subagent inherits the parent. |
| `claude-opus-*` / "judgment and prose", "hardest tasks", `architect runners`, `interrogate reviewers`, `why synthesizer`, `reflect judgment, divergent, synthesizer` | `gpt-6.1-sol` `xhigh`. |
| `grok-*` code roles: "feature, refactoring", "bug-fix", "perf-issue", "hillclimb", `arena runners` | `gpt-6.1-sol` `high`. |
| Explorers and fan-out: `how explorer`, `why investigators`, `swarm workers`, `reflect tooling`, trivial mechanical edits | `gpt-6-luna` `medium` (`high` when the slice needs judgment, `low` for pure extraction). |
| `how explainer` | `gpt-6.1-sol` `medium`. |
| Effort tokens in a slug (`-max`, `-xhigh`, `-high`, `-medium`, `-low`) | Keep the token; drop `-fast`. If the chosen model lacks that effort, use its highest effort below it. |

**Cross-model judging.** pstack asks for a judge or verifier "on a different model family" (arena cross-judge, architect cross-judge, interrogate's multi-model panel, orchestrate's verifier). Codex has one family, and Astra is off unless the user names it, so: workers on `gpt-6-luna` are judged by `gpt-6.1-sol` (`xhigh`); workers on `gpt-6.1-sol` are judged by `gpt-6.1-sol` at a higher effort than the workers (`xhigh` over `high`, `max` over `xhigh`) in a fresh subagent whose brief carries the candidates and the rubric but none of the workers' reasoning. A multi-model panel mixes Sol and Luna seats and varies Sol's effort before it repeats a configuration. When the judge shares the workers' model, add one line to the reply: `Judge independence reduced: same model, higher effort, fresh context.`

**pstack-models rule.** Codex never reads `.mdc` files. `rules/pstack-models.mdc` sets every role to `inherit-parent`; in Codex that means: omit the model unless a skill step needs a different judge, in which case use the cross-model rule above. If a Codex-specific budget is wanted, set it with `[agents]` defaults in `~/.codex/config.toml` or in a custom agent file, not in `AGENTS.md`.

## setup-pstack

`setup-pstack` writes a Cursor rule. In Codex, do not run its Write step. Show the role table from [Models](#models) instead, and when the user picks models, write them as `[agents]` defaults or per-agent `model` / `model_reasoning_effort` in `~/.codex/agents/*.toml`, after they confirm.

## Paths

| Cursor | Codex |
| --- | --- |
| `~/.cursor/skills/`, `.cursor/skills/` | `~/.agents/skills/` (documented user location; legacy `~/.codex/skills/` is also installed), `.agents/skills/` in the repo. |
| `.cursor/rules/*.mdc`, always-applied rules | `AGENTS.md`: `~/.codex/AGENTS.md` (global, or `AGENTS.override.md` when present) and `AGENTS.md` files in the repo. |
| `~/.cursor/agents/*.md` | `~/.codex/agents/*.toml` with `name`, `description`, `developer_instructions`. |
| `https://github.com/cursor/plugins/blob/main/pstack/<path>` | `<pstack>/<path>` when that file exists. Read the local copy. |
| Transcripts in `~/.cursor/projects/<slug>/agent-transcripts/` | Codex session logs under `~/.codex/sessions/` (JSONL per session). Read only sessions for this workspace. |

## Cursor-only features

Codex has no Cursor Automations, Bugbot, Cursor cloud agents, Custom Modes, or built-in PR tool. When a step needs one, put one line in your reply, `Skipped in Codex: <step>. <reason>.`, then go on. Do not stop, ask, or retry. When a later step needs what the skipped step made, leave a placeholder and name it in the line.

| Cursor | Codex |
| --- | --- |
| Cursor Automations, routines, routine wakes, `SendToUser` secret requests | Skip with the line. |
| Bugbot | Bugbot comments on a GitHub PR are ordinary review threads: triage them with `gh`. Skip a step that starts, waits for, or configures Bugbot. |
| Cursor cloud agents | Local subagents, per Subagent fields. Skip a step that needs the cloud agent itself (its dashboard, its machine, videos it recorded). |
| Custom Mode (Option+Enter) | Not needed: the always-on block in `~/.codex/AGENTS.md` loads poteto-mode. |
| A built-in PR tool | `gh pr create` / `gh pr view`. Not a skip. |
| `cursor-team-kit` skills (`control-cli`, `control-ui`, `deslop`) | Use the personal copies in `~/.agents/skills/` when present; otherwise skip with the line. |
