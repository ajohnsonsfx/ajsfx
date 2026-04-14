# pvx REAPER Tool — Implementation Plan

## Context

The `ajsfx` repo (`/home/user/ajsfx`) is a ReaPack-distributed collection of REAPER Lua scripts. This adds a new feature: a tool that applies time-varying **pitch** and **time-stretch** curves to a single audio item, processed offline by [`pvx`](https://github.com/TheColby/pvx), a Python phase-vocoder CLI. Primary use case is doppler/whoosh sound design — draw a pitch contour against an item, render, pull snippets from the result.

Non-negotiables: curves persist with the `.rpp` project (no sidecar files), REAPER's native FX parameter envelope UI is the drawing surface, Render and Preview can be triggered from the Action List / toolbar / keyboard shortcut, pvx is a dependency called via subprocess, output quality must be uncompromised.

## Architecture (decided)

**JSFX placeholder FX on the Take FX chain + two Lua orchestrator scripts.** A pass-through JSFX exposes `slider1:` (Pitch, semitones) and `slider2:` (Stretch, log2 factor) as automation targets. The user draws envelopes on those sliders using REAPER's built-in Take FX envelope UI. Envelopes persist in the RPP automatically (stock REAPER behavior). Render and Preview are plain Lua scripts invoked from outside the JSFX — they find the PVX Host on the selected item's active take, sample the envelopes via `TakeFX_GetEnvelope` + `Envelope_Evaluate`, bake CSVs, shell out to pvx, and insert the result **as a new take on the source item**.

Rejected alternatives (research done in-session): pure Lua with companion-track envelopes (orphan risk); CLAP/VST plugin (CLAP/VST3 plugins cannot read their full automation curve from the host); REAPER C++ extension (build complexity out of line with this repo's zero-build Lua conventions).

## Render Pipeline (three stages, takes-only)

For the currently selected single audio item (reject multi-select, MIDI, empty; see PrepareItem):

1. **Pre-PVX bake.** Snapshot enabled state of all Take FX. Disable PVX Host and every FX after it in the chain. Run action **41999** `Item: Render items to new take` to produce WAV #1 — captures pre-PVX FX + playrate + start offset natively, ignores track FX (per requirement). Restore the original take (delete the scratch render take that 41999 creates on the item, keep only WAV #1 on disk). Restore FX enabled state.
2. **pvx.** Sample the PVX Host pitch and stretch envelopes over `[0, item_length]` (item-local time; envelope is queried at `item_pos + t` in project seconds per `Envelope_Evaluate`'s contract). Emit `pitch.csv` and `stretch.csv` only when an envelope exists or the slider is off-default; otherwise omit the corresponding pvx flag. Spawn pvx detached, produce WAV #2.
3. **Post-PVX bake.** If any Take FX sit after PVX Host, import WAV #2 as a temporary take, disable PVX Host + all pre-PVX FX, run 41999 again to produce WAV #3 with post-chain applied. If no post-PVX FX, WAV #3 = WAV #2.

**Import.** Add WAV #3 as a new take on the source item with name `pvx_v<n>` (n auto-increments from existing `pvx_v*` takes), make it active, clear its Take FX chain. Wrap the import step in `core.Transaction` (see `scripts/lib/ajsfx_core.lua`:26) for single-step undo.

Stage 1 + Stage 3 orchestration runs **synchronously** inside the Transaction. Stage 2 (pvx) runs **async + cancellable** — see below.

## Async + Cancellable pvx Invocation

`reaper.ExecProcess` is blocking; we don't use it for pvx. Instead:

- Spawn pvx detached via `os.execute`, writing `pid.txt`, `log.txt`, `done.txt` to the scratch subdir. Platform-specific wrapper:
  - macOS / Linux: `(pvx ... > log 2>&1; echo $? > done) & echo $! > pid`
  - Windows: small `.bat` wrapper that captures `%ERRORLEVEL%` → `done` and PID via a PowerShell sidecar, or use `start /B` with `%!`.
- ImGui progress window (spinner + Cancel) runs in a `defer` loop polling `done.txt` at ~10 Hz (configurable). On done: read exit code, continue to Stage 3. On Cancel: read `pid.txt`, call `kill -9 <pid>` (Unix) / `taskkill /F /PID <pid>` (Windows), abort pipeline, leave scratch for debugging.
- Timeout (default 300s, configurable) triggers same cancel path with an error message.

## Preview

Preview does **not** mutate the project. It:
1. Runs Stage 1 + 2 on a short window (time selection if present, else ±N seconds around edit cursor, N default 2.0, capped at 10s).
2. Skips Stage 3 (post-FX). Preview intentionally auditions the raw pvx output so the user hears exactly what the vocoder is producing.
3. Plays WAV #2 via SWS `CF_Preview_PlayEx` — hard dependency on SWS for Preview only. If SWS is missing, error message points to install.

No project state touched. Re-invoking Preview stops the previous preview and starts the new one.

## MIDI / Empty Item Handling (`ajsfx_PVX_PrepareItem.lua`)

Separate action. For a MIDI or empty item: run action 41999 on the selected item (picks up track input for empty-items-on-master, the NVK Tools case), then add the `ajsfx PVX Host` JSFX to the fresh audio take's FX chain via `TakeFX_AddByName`. Stop there — user draws curves, then runs Render normally. Two-step workflow is explicit and documented.

## File Inventory

New files:
- `scripts/FX/ajsfx_PVXHost.jsfx` — placeholder JSFX (sliders only, pass-through `@sample`).
- `scripts/Items/ajsfx_PVX_Render.lua` — full render entry point.
- `scripts/Items/ajsfx_PVX_Preview.lua` — time-selection preview entry point.
- `scripts/Items/ajsfx_PVX_PrepareItem.lua` — MIDI/empty → audio + insert PVX Host.
- `scripts/Items/ajsfx_PVX_Settings.lua` — ImGui settings panel (pvx binary path, scratch dir, poll rate, preview seconds, render timeout, Clear Scratch button).
- `scripts/lib/ajsfx_pvx.lua` — shared pvx-specific helpers (see below).
- `tests/test_pvx.lua` — unit tests for pure helpers.

Modified:
- `README.md` — new "PVX Time-Varying Pitch/Stretch" section under Item Management.
- `CHANGELOG.md` — entry under `[Unreleased]`.
- `index.xml` — regenerated via `reapack-index` after merging to main (standards.md:75).

## JSFX (`scripts/FX/ajsfx_PVXHost.jsfx`)

```jsfx
desc:ajsfx PVX Host
// @description ajsfx PVX Host
// @author ajsfx
// @version 0.1
// @about Placeholder FX exposing automation lanes for PVX Render/Preview.

slider1:0<-24,24,0.01>Pitch (semitones)
slider2:0<-2,2,0.001>Stretch (log2 factor: 0=1x, +1=2x, -1=0.5x)
slider3:0<0,2,1{Linear,Cubic,Sinc}>Interp
slider4:1<0,2,1{Off,Loose,Strict}>Phase Lock
slider5:1<0,1,1{Off,On}>Preserve Transients

@init
ext_tail_size = 0;

@sample
// pass-through

@gfx 320 60
gfx_clear = 0;
gfx_x = 10; gfx_y = 10;
gfx_set(0.8, 0.8, 0.8, 1);
gfx_drawstr("Draw envelopes on Pitch and Stretch.");
gfx_y += 14;
gfx_drawstr("Run 'ajsfx PVX Render' or 'Preview' from Action List.");
```

No global settings for sliders 3–5; defaults are hardcoded. Users override per-item.

## `scripts/lib/ajsfx_pvx.lua` (shared helpers)

Pure functions (unit-testable):
- `pvx.Log2StretchToFactor(v) -> number` — `2^v` clamped.
- `pvx.FormatCSV(samples, rate_hz) -> string` — `"0.000000,0.123\n..."`.
- `pvx.ShouldEmitCurve(has_envelope, slider_value, default) -> bool`.
- `pvx.BuildArgv(config) -> {string,...}` — centralized pvx flag construction.
- `pvx.QuoteArg(s, os_name) -> string` — cross-platform shell escaping.
- `pvx.BumpTakeVersion(existing_names, base) -> string` — e.g. `pvx_v3`.

REAPER-coupled (manual-test only):
- `pvx.FindHostFX(take) -> fx_index | nil` — matches `TakeFX_GetFXName` against `"ajsfx PVX Host"`.
- `pvx.SampleEnvelope(take, fx_idx, param_idx, item_pos, item_len, rate_hz) -> samples[] | nil` — iterates `Envelope_Evaluate`, project-second time domain.
- `pvx.BakeTakeViaAction41999(item, bypass_fx_indices) -> wav_path` — disables listed FX, runs action 41999, captures render path, restores FX state.
- `pvx.RunPVXAsync(argv, scratch_dir, on_done, on_cancel, on_error)` — detached spawn, cancel window, defer-poll.
- `pvx.LoadConfig() / pvx.SaveConfig(cfg)` — ExtState wrappers, section `ajsfx_pvx`.
- `pvx.ResolveScratchDir() -> string` — project path subdir, fall back to `os.tmpname()` dir when project unsaved.

Existing core helpers reused: `core.Transaction` (`scripts/lib/ajsfx_core.lua`:26), `core.Print`, `core.Error` (:14, :19). ImGui wrapper pattern from `scripts/Items/ajsfx_MediaItemCounter_Settings.lua`:17–25 (load via `pcall`), `:191–290` (defer loop + Begin/End + ExtState save).

## Known Risks / Flagged at Implementation Time

1. **Envelope value units.** `TakeFX_GetEnvelope` + `Envelope_Evaluate` — verify at first-run whether values come back in slider units (likely) or 0–1 normalized (common forum misconception). Add a calibration check: set slider1 to known value, sample envelope at t=0, compare. If normalized, apply inverse mapping before CSV emit. Single place to fix: `pvx.SampleEnvelope`.
2. **Windows PID capture for cancel.** `start /B` + `echo %!` is unreliable. Fallback: a tiny `.bat` wrapper that uses `wmic process where` or a PowerShell one-liner. Budget time; if it gets ugly, v1 ships cancel as mac/Linux only and Windows shows a "cannot cancel — wait for completion" warning.
3. **pvx flag drift.** Pin known-good commit in README; run `pvx --version` at Settings save and store it.
4. **Post-PVX bake via 41999.** Needs a temporary item hosting WAV #2 with the post-PVX FX chain copied. Implementation detail: insert a hidden item on a hidden scratch track long enough to render, then delete. If this becomes fragile, fallback is to require all Take FX be pre-PVX in v1 and flag post-PVX as v1.1.

## Testing

`tests/test_pvx.lua` follows `tests/test_core.lua` conventions (inline mocks, `test(name, fn)` helper, exits 1 on failure). `run_tests.sh` auto-globs `test_*.lua`. Covered helpers: all pure functions above. Not covered: subprocess invocation, envelope reading, JSFX behavior — manual verification via the Verification Plan.

## ReaPack Packaging

Per script headers per `.agents/standards.md`:43–57. Each Lua script `@provides` bundles `../lib/ajsfx_core.lua`, `../lib/ajsfx_pvx.lua`, and `../FX/ajsfx_PVXHost.jsfx` as `[nomain]`. The JSFX gets its own `[effect]` entry under `scripts/FX/`. README documents: SWS (required for Preview), ReaImGui (required for Settings), js_ReaScriptAPI (optional, enables file browse dialog), pvx venv binary (required).

## Verification Plan (manual, in REAPER)

1. Install via ReaPack from dev branch. Verify all 4 Lua scripts + 1 JSFX appear.
2. Run `ajsfx_PVX_Settings`, set pvx binary path, save. Verify ExtState written (`reaper-extstate.ini` inspect).
3. Create project, import an audio file, add `ajsfx PVX Host` to the Take FX chain. Draw a pitch envelope (right-click slider → Show take envelope → draw).
4. Run `ajsfx_PVX_Render`. Verify: cancel window appears, pvx log produced, new take `pvx_v1` added on source item, active, FX chain empty, audio sounds correct.
5. Draw a different curve, render again — new take `pvx_v2`, previous `pvx_v1` preserved and reachable via take cycler.
6. With a time selection present, run `ajsfx_PVX_Preview` — preview audio plays through REAPER's preview bus, no project mutation.
7. Press Cancel during a long render; verify subprocess dies and no take is added.
8. Save project, close REAPER, reopen — envelopes and PVX Host persist on the take.
9. Select a MIDI item, run `ajsfx_PVX_PrepareItem` — MIDI rendered to audio take with PVX Host added; then repeat step 4 on that.
10. Select an empty NVK-Tools-style item on the master, run `ajsfx_PVX_PrepareItem` — track input captured, PVX Host inserted.
11. Open Settings → "Clear Scratch" — scratch dir emptied.
12. Run tests: `./run_tests.sh`.

## Critical Files for Implementation

- `/home/user/ajsfx/scripts/FX/ajsfx_PVXHost.jsfx`
- `/home/user/ajsfx/scripts/Items/ajsfx_PVX_Render.lua`
- `/home/user/ajsfx/scripts/Items/ajsfx_PVX_Preview.lua`
- `/home/user/ajsfx/scripts/Items/ajsfx_PVX_PrepareItem.lua`
- `/home/user/ajsfx/scripts/Items/ajsfx_PVX_Settings.lua`
- `/home/user/ajsfx/scripts/lib/ajsfx_pvx.lua`
- `/home/user/ajsfx/tests/test_pvx.lua`
- `/home/user/ajsfx/README.md` (section add)
- `/home/user/ajsfx/CHANGELOG.md` (Unreleased entry)

## Handoff Note (session migration)

This plan file is the portable artifact. Once approved, commit and push to `claude/reaper-pvx-architecture-05EZv`. On your desktop: `git fetch && git checkout claude/reaper-pvx-architecture-05EZv`, run `claude` in the repo, and reference this file to resume implementation where REAPER is available to test against.
