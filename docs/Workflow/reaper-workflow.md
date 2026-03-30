# REAPER Sound Design Workflow

> A living document covering project setup, track architecture, naming conventions, and export workflow for game audio sound design in REAPER.
>
> **Companion docs:** Filename Conventions *(TODO: link when added to repo)*

---

## 1. Overview

This document describes a professional game audio sound design workflow built around REAPER. It is intended for intermediate-to-advanced practitioners and prioritizes clarity, portability, and repeatability — from first session to final deliverable.

The workflow is REAPER-centric but tool-agnostic where possible. References to specific plugins (e.g. iZotope RX for spectral cleanup, NVK Tools for export) indicate one valid option, not a requirement.

---

## 2. Project Setup

### When to Create a Project

Each project maps to a single **scope unit** — not a deliverable count. Typical scopes:

- A **character** (all SFX for that character)
- An **environment** (ambiences, layers, stingers)
- A **prop or feature** (a specific weapon, vehicle, interactive object)

If work started inside one project is later recognized as reusable across multiple characters or contexts, it should be migrated to its own standalone project. REAPER's self-contained Group Master architecture (see §3) makes this straightforward.

### Folder Structure

Every project uses the following folder structure:

```
ProjectName_v1_YYYY_MMDD\
├── Audio\           # REAPER media folder — all source audio
├── Renders\         # Intermediate renders (e.g. printed FX, consolidated takes)
├── Exports\         # Final exports for use outside the project
└── ProjectName.rpp  # REAPER project file
```

> **Note:** `Exports\` may be replaced by — or mirror to — a central game implementation folder:
> `\To_Be_Implemented\[Category]\$project\`

---

## 3. Track Architecture

### Group Masters

Each distinct sound asset is organized as a **Group Master** — a REAPER folder track that acts as a self-contained bus for that asset. The term "Group Master" is used to distinguish it from REAPER's actual master track, which is left untouched.

A Group Master is named with the full asset name plus version and date:

```
sword_impact_ground_v1_2026_0330
```

This name becomes the top-level folder name in the export path (see §7).

### Child Tracks

Audio content lives on child tracks nested under the Group Master. Each child track represents a **single sonic layer** — even if layers never overlap in time.

**Rule:** Do not mix conceptually distinct layers on a single child track.

Example — a sci-fi door open might have:
- `mechanical` — servos, hinges
- `electrical` — hum, spark
- `air` — pressure release

Each gets its own child track. This enforces clean separation for per-layer processing and makes surgical edits or swaps trivial.

### Portability

Because each Group Master is fully self-contained — its own bus, its own child tracks, its own processing chain — any group can be cut and moved to another REAPER project without side effects. This is the intended migration path when a sound outgrows its original project scope.

---

## 4. Asset Naming

### Variation Items

Items on child tracks (individual audio files / takes) are named with version and variation number:

```
sword_impact_ground_v1_01
sword_impact_ground_v1_02
```

**Variation number goes last.** Rationale:

- All `v1` variations sort together.
- A variation number in an earlier version carries no meaningful continuity into a new version. `sword_impact_ground_v2_01` is the *first variation of v2* — not a revision of the original `_01`. Placing the version before the variation makes this relationship unambiguous, at zero extra cost in character count.

### Further Reading

*TODO: Link to Filename Conventions doc when added to repo.*

---

## 5. NVK Tools

[NVK Tools](https://nvk.tools) is a REAPER extension used at two key points in this workflow:

- **Item visibility on folder tracks** — NVK renders child track items visible at the Group Master level, giving a consolidated view of all variations without leaving the top-level track.
- **Batch export by track/item name** — NVK's export system uses track and item names to construct output filenames and paths automatically (see §7).

Refer to the [NVK Tools documentation](https://nvk.tools) for full feature reference and installation.

---

## 6. Working Practice

### Layer Separation

As described in §3, each sonic layer gets its own child track. This is enforced even when layers don't overlap. The benefits compound over time: independent processing, easy muting/soloing, clean export separation, and legible session layout for anyone opening the project later.

### Mid-Version Backups

While working within a version, informal backups are made by **duplicating the Group Master folder and muting the duplicate**. This preserves a recoverable snapshot of an interesting idea without committing to a version bump.

These backups are never exported and do not affect the naming or versioning of the active group.

---

## 7. Versioning

### What Triggers a Version Bump

A version increment (`v1` → `v2`) occurs when **assets are rendered and delivered** — i.e. exported for use in the game. This represents a discrete, auditable milestone.

Minor in-session backups (see §6) do not constitute a version.

### How Versions Are Managed

New versions are created by duplicating the entire project folder:

```
ProjectName_v1_2026_0115\   # previous version — preserved, untouched
ProjectName_v2_2026_0330\   # new working version
```

The previous version folder is kept as a permanent record. Nothing is deleted.

---

## 8. Export

### Render Path

All exports are performed via NVK Tools. REAPER's native render dialog is not used for final output.

### Output Naming

NVK is configured to construct export filenames from track and item names:

```
$track\$item
```

This produces a folder-per-asset structure:

```
Exports\
└── sword_impact_ground_v1_2026_0330\
    ├── sword_impact_ground_v1_01.wav
    ├── sword_impact_ground_v1_02.wav
    └── sword_impact_ground_v1_03.wav
```

The track name (Group Master name, with version + date) becomes the subfolder. The item name (version + variation, no date) becomes the filename. Date is omitted from the filename to keep asset names concise at the implementation level — the version number alone is sufficient to identify the revision.

### Export Destinations

Exports go to one of two locations depending on workflow stage:

| Destination | Path | When |
|---|---|---|
| Local project | `\Exports\` | Default; for review or iteration |
| Game implementation | `\To_Be_Implemented\[Category]\$project\` | When ready for integration |
