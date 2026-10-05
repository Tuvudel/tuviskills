# Handoff: UTCI Viewer Multi-Project (Ben-Gurion + Ness-Tziona)

## Session Metadata
- Created: 2026-03-10 21:58:59
- Project: d:/Projects/Nur/Shade/fast-utci
- Branch: [not a git repo or detached HEAD for this handoff context]
- Session duration: [manual estimate needed]

### Recent Commits (for context)
  - [no recent commits or not a git repo]

## Handoff Chain

- **Continues from**: None (fresh start)
- **Supersedes**: None

> This is the first handoff for this task.

## Current State Summary

We are extending an existing UTCI analysis + viewer pipeline, originally built solely around the Ben-Gurion campus, to support an additional project, Ness-Tziona, which currently has two competing model variants (heavy “OG” and simplified “exploded”). The backend analysis code (`run_analysis.py`, `quick_analysis.py`, `scripts/export_for_viewer.py`) already supports exporting data for the web viewer, but only assumes a single project; the viewer loads analyses via an `analysis` query parameter with hard-coded defaults and scenario selection designed only for Ben-Gurion. A corrected, repo-aware design for multi-project support has been written in `docs/plans/2026-03-10-multi-project-ness-tziona-design-v2.md`, but implementation has not yet started—no changes have been made to the analysis scripts or viewer files in this session.

## Codebase Understanding

### Architecture Overview

- **Core analysis library:** `src/fast_utci/...` handles MRT and UTCI computations; it is already project-agnostic and driven by model/weather paths and config.
- **Analysis runners:**
  - `run_analysis.py` provides an interactive CLI and a `run_analysis_core(...)` function that accepts a `category` parameter and calls `scripts/export_for_viewer.export_utci_for_viewer(...)`.
  - `quick_analysis.py` is a thin wrapper that iterates over `ANALYSIS_CONFIGS` and calls `run_analysis_core(**config)`, currently with a single Ben-Gurion config and no explicit `category`.
- **Export pipeline:** `scripts/export_for_viewer.py`:
  - Writes binary + JSON metadata into `data/analyses` (with optional `category` as a subfolder).
  - Uses `generate_analysis_id` for date/grid-based IDs by default, but when `category` is set it uses `Path(model_file).stem` as `analysis_id`.
- **Data layout:**
  - Ben-Gurion analyses live under `data/analyses/Ben-Gurion/...`, including base (`20250815_grid_2m_fullday.*`) and scenario subfolders (`existing_buildings`, `existing_trees`, `new_high_buildings`, `new_low_buildings`, `new_trees`).
  - Ness-Tziona 3D models live under `data/3d_models/Ness-Tziona/`, but no finalized analysis folder structure has been wired into the scripts yet.
- **Viewer app:**
  - `viewer/src/lib/services/dataLoader.ts` fetches `{analysisId}.json`/`.bin` from `data/analyses` using a base path and the `analysis` query parameter.
  - `viewer/src/routes/+page.svelte`:
    - Reads `analysis` from the URL, defaults to `"20250815_grid_2m_fullday"`.
    - Holds the main 3D scene, loads models from `metadata.model_file`, and drives UTCI point cloud rendering.
    - Integrates `ScenarioSelector.svelte` and comparison rendering for Ben-Gurion scenarios only.

### Critical Files

| File | Purpose | Relevance |
|------|---------|-----------|
| `run_analysis.py` | Interactive full-day UTCI analysis runner (`run_analysis_core`) | Entry point for generating analysis data; already supports `category` parameter. |
| `quick_analysis.py` | Batch driver over `ANALYSIS_CONFIGS` | Will be extended to run Ben-Gurion + both Ness-Tziona variants with correct categories. |
| `scripts/export_for_viewer.py` | Converts UTCI results into `.bin` + `.json` for viewer | Controls output directory (`data/analyses`), `category` subfolders, and `analysis_id` naming. |
| `scripts/generate_manifest.py` | Builds `data/analyses/manifest.json` | Needs to understand both date-based Ben-Gurion IDs and model-based Ness-Tziona IDs. |
| `viewer/src/routes/+page.svelte` | Main viewer layout and scene integration | Handles `analysis` query param, loads analyses, hosts header and sidebars. |
| `viewer/src/lib/services/dataLoader.ts` | Low-level loader for binary + metadata | Understands how `analysisId` maps to file paths in `data/analyses`. |
| `viewer/src/lib/components/ui/ScenarioSelector.svelte` | Scenario comparison UI for Ben-Gurion | Must be disabled/informational when a Ness-Tziona base is active. |
| `docs/plans/2026-03-10-multi-project-ness-tziona-design-v2.md` | Detailed implementation plan | Authoritative spec for multi-project work; should be followed instead of older v1. |

### Key Patterns Discovered

- Use of a **`category`** argument to route exports into project/scenario subfolders under `data/analyses`, already implemented in `export_for_viewer.py` and plumbed into `run_analysis_core`.
- Analysis IDs for viewer:
  - Ben-Gurion legacy base: date-based IDs like `20250815_grid_2m_fullday`.
  - Category mode: `analysis_id` derived from `Path(model_file).stem`, which is ideal for Ness-Tziona OG/exploded naming.
- Viewer loading always uses an **`analysisId` → `{analysisId}.json`/`.bin`** convention under `data/analyses`, with the project root derived from `base` and `getDataBasePath()`; no special-case logic for projects yet, so multi-project support should be layered on top via manifests and config, not by hard-coding new paths.

## Work Completed

### Tasks Finished

- [x] Analyzed current analysis + viewer architecture to understand how Ben-Gurion is wired through `run_analysis.py`, `quick_analysis.py`, `export_for_viewer.py`, `generate_manifest.py`, and the Svelte viewer.
- [x] Produced a corrected, repo-aware multi-project implementation plan in `docs/plans/2026-03-10-multi-project-ness-tziona-design-v2.md` that respects the existing `data/analyses/Ben-Gurion/...` layout.
- [x] Created this handoff document to summarize context, decisions, and next steps for a future agent.

### Files Modified

| File | Changes | Rationale |
|------|---------|-----------|
| `docs/plans/2026-03-10-multi-project-ness-tziona-design-v2.md` | New v2 plan file created | Corrects earlier plan assumptions; now accurately reflects actual `data/analyses` layout and orders tasks sensibly. |
| `.claude/handoffs/2026-03-10-utciviewer-multi-project-ness-tziona.md` (in project) | Manual handoff authored earlier in repo | Captures similar context; this skill-based handoff is more generic but can reference it. |

### Decisions Made

| Decision | Options Considered | Rationale |
|----------|-------------------|-----------|
| Keep existing Ben-Gurion analysis file locations and IDs | Restructure folders vs. keep as-is | Minimizes regression risk in the viewer and scripts; easier to add Ness-Tziona than to migrate Ben-Gurion. |
| Use `category="Ness-Tziona"` for new project outputs | Flat `data/analyses` vs per-project folders | Leverages existing `category` pattern and keeps project data cleanly separated. |
| Model-name-based IDs for Ness-Tziona | Date-based IDs vs model name | Model-name IDs (`nes_tziona_og`, `nes_tziona_exploded`) make it obvious which geometry version is loaded and align with existing `export_for_viewer` logic. |
| Simple header dropdown for project/model | Two-level project + scenario UI vs flat list | Matches current requirement (just switch base models) with minimal complexity; scenario selector remains Ben-Gurion-only. |

## Pending Work

### Immediate Next Steps

1. **Implement Task 1 from v2 plan in the actual project repo** (`scripts/export_for_viewer.py` in `d:/Projects/Nur/Shade/fast-utci`):
   - Double-check that `category` drives subfolders exactly as desired for `Ben-Gurion` and `Ness-Tziona`.
   - Add `project` (and optional `kind`) fields to exported metadata.
2. **Implement Task 2 in the project repo**:
   - Update `run_analysis.py` docstrings for `category`.
   - Refactor `quick_analysis.py` to add explicit configs for Ben-Gurion base, Ness-Tziona OG, and Ness-Tziona exploded with appropriate `category` values.
3. **Run `quick_analysis.py` from the project root** and verify expected outputs in `data/analyses/Ben-Gurion/...` and `data/analyses/Ness-Tziona/...` before touching the viewer.

### Blockers/Open Questions

- [ ] Confirm which exact Ness-Tziona model filenames you want to treat as OG vs exploded (`.gltf` vs `.glb`) and ensure the configs in `quick_analysis.py` match those paths.
- [ ] Decide whether any additional Ben-Gurion analyses (other than the existing base) should be considered “base options” in the new header dropdown, or if the single existing base is enough.

### Deferred Items

- Decision on which Ness-Tziona model (OG vs exploded) will be the long-term canonical “base” is intentionally deferred; both will be supported in parallel until you compare performance and UX.
- Any deeper refactor of the viewer to support a true multi-level project → scenario → variant selection UI is deferred; current work focuses only on a flat base dropdown and Ben-Gurion-only scenarios.

## Context for Resuming Agent

### Important Context

- The **single source of truth for implementation details** is `docs/plans/2026-03-10-multi-project-ness-tziona-design-v2.md`; ignore older design artifacts.
- The **repo where all real work must happen** is `d:/Projects/Nur/Shade/fast-utci`, not the `session-handoff` skill directory—this handoff lives in the skill folder but describes work in that project.
- Ben-Gurion behavior must **not regress**:
  - Viewer should still default to loading `20250815_grid_2m_fullday` (or whatever is currently wired).
  - Scenario selector and comparison features must continue to work exactly as before when a Ben-Gurion base is active.
- Ness-Tziona must be added in a way that:
  - Uses its own analyses folder (`data/analyses/Ness-Tziona`).
  - Provides two base analyses (OG + exploded) accessible via a simple header dropdown.
  - Does **not** enable scenarios until the project decides which model to keep and designs scenarios explicitly.

### Assumptions Made

- The Ben-Gurion base analysis ID (`20250815_grid_2m_fullday`) and its folder under `data/analyses/Ben-Gurion/` are stable and should not be renamed.
- There is no existing downstream consumer (outside this repo) relying on specific `data/analyses` filenames for Ness-Tziona yet, so we are free to choose the model-name-based naming convention.
- The viewer will continue to be served from the project root with `data/` accessible at the same relative path it uses today, so no changes are needed to `getDataBasePath()` logic.

### Potential Gotchas

- Mixing up Windows path separators (`\`) and POSIX-style (`/`) when inferring `project` from `model_file` could cause subtle bugs; normalize paths before string checks.
- Accidentally changing the `analysisId` for the existing Ben-Gurion base (e.g. by introducing a category where there was none) would break existing viewer URLs.
- The session-handoff scripts live under the skill folder and operate relative to that directory; they are **not** aware of the project repo by default, so treat this handoff as a high-level guide, not a project-local artifact.

## Environment State

### Tools/Services Used

- Python 3.x for running `create_handoff.py` (in the skill folder) and, in the project repo, for running analysis scripts.
- Node/npm + SvelteKit for the viewer (not exercised yet in this session, but central to future verification).

### Active Processes

- None at handoff time (no dev servers or long-running analysis processes known to be active).

### Environment Variables

- Not explicitly used or modified in this session; rely on project’s `.env` and standard Python/Node environment when running commands.

## Related Resources

- Project plan: `d:/Projects/Nur/Shade/fast-utci/docs/plans/2026-03-10-multi-project-ness-tziona-design-v2.md`
- Manual project-local handoff: `d:/Projects/Nur/Shade/fast-utci/.claude/handoffs/2026-03-10-utciviewer-multi-project-ness-tziona.md`
- Core scripts and viewer files listed in “Critical Files” above.

---

**Security Reminder**: Before finalizing, run `validate_handoff.py` to check for accidental secret exposure.
