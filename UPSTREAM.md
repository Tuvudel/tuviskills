# Upstream sources

| Source | What | Version | License |
|---|---|---|---|
| [cursor/plugins pstack](https://github.com/cursor/plugins/tree/main/pstack) | The whole `pstack/` folder, unmodified, in [`vendor/pstack/`](vendor/pstack): 56 skills (incl. `poteto-mode` and its playbooks), agents `poteto-agent` and `comment-sicko`, docs, automations | <!-- pstack-pin -->190d287, pstack 0.15.29<!-- /pstack-pin --> (exact commit and tree in [`vendor/pstack.lock`](vendor/pstack.lock)) | MIT, `vendor/pstack/LICENSE` |
| [obra/superpowers](https://github.com/obra/superpowers) | `receiving-code-review` (trigger narrowed to arriving review comments; from plugin 6.1.1); `hooks/run-hook.cmd` unmodified from v7.0.0 (tag commit 7f043e5). The other superpowers skills are in `archive/`. | 6.1.1 / v7.0.0 | MIT, `licenses/superpowers-LICENSE` |
| [cursor/plugins cursor-team-kit](https://github.com/cursor/plugins/tree/main/cursor-team-kit) | CI, PR, review, control-* skills; agents `ci-watcher`, `thermo-nuclear-code-quality-review`; rules folded into `rules/personal-engineering.md` | 1.2.0 | MIT, `licenses/cursor-team-kit-LICENSE` |
| [rhino-ty/apca-contrast-skill](https://github.com/rhino-ty/apca-contrast-skill) | `apca-contrast` | 32e2a95 | MIT |
| [wheresryan22/anatomy](https://github.com/wheresryan22/anatomy) | `anatomy` | 2026-10-12 | MIT |

## pstack

pstack is vendored as-is. Do not edit `vendor/pstack/`: `scripts/sync-pstack.sh --check` (and `tests/test_vendor_pstack.py`) fail when it differs from the recorded upstream tree.

- Update: `scripts/sync-pstack.sh` (latest `main`) or `scripts/sync-pstack.sh <sha>`, then run the tests, regenerate the inventory (`scripts/build-inventory`), and commit `vendor/`, `vendor/pstack.lock`, and `UPSTREAM.md` together.
- Personal behavior lives outside the vendor folder: `rules/pstack-default.*` (the always-on rule), `rules/pstack-models.mdc` (all roles `inherit-parent`), and [`harness/codex.md`](harness/codex.md) (Codex adapter, modelled on `vendor/pstack/docs/harness/claude-code.md`).
