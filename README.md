# ajsfx

A personal toolkit for REAPER — custom ReaScripts and sound design reference docs.

- **[scripts/](scripts/)** — Lua ReaScripts for track and item management
- **[docs/](docs/)** — Sound design guides and workflow references

---

## ReaScripts

### Installation via ReaPack (Recommended)

1. Install [ReaPack](https://reapack.com/) if you haven't already.
2. In REAPER, go to **Extensions → ReaPack → Import repositories...**
3. Paste this URL and click OK:
   ```
   https://github.com/ajohnsonsfx/ajsfx/raw/main/index.xml
   ```
4. Go to **Extensions → ReaPack → Browse packages...**
5. Search for "ajsfx" and install the scripts you want.
6. ReaPack will automatically download the shared core library alongside each script.

### Manual Installation

1. Download the scripts or clone this repository.
2. Place the contents of `scripts/` (`Items/`, `Track/`, `lib/`) in your REAPER Scripts directory (usually `AppData/Roaming/REAPER/Scripts` on Windows, or `~/Library/Application Support/REAPER/Scripts` on macOS).
3. Ensure the `lib/` folder containing `ajsfx_core.lua` is present in the same directory as the scripts.
4. Open REAPER, open the Action List (`?`), click `New Action` → `Load ReaScript...`, and select the desired `.lua` files.

### Track Management

- **scripts/Track/ajsfx_Track_CollapseVisibleChildrenAtHighestSelectedLevel.lua** — Collapses visible children tracks at the highest selected level.
- **scripts/Track/ajsfx_Track_CollapseVisibleChildrenAtLowestSelectedLevel.lua** — Collapses visible children tracks at the lowest selected level.
- **scripts/Track/ajsfx_Track_UnCollapseVisibleChildrenAtHighestSelectedLevel.lua** — Uncollapses visible children tracks at the highest selected level.
- **scripts/Track/ajsfx_Track_UnCollapseVisibleChildrenAtLowestSelectedLevel.lua** — Uncollapses visible children tracks at the lowest selected level.
- **scripts/Track/ajsfx_TrackVersioning.lua** — Duplicates selected tracks, increments a version number on the original, and archives the old version into a folder.

### Item Management

- **scripts/Items/ajsfx_GentleNormalizer.lua** — Normalizes selected items gently to a target level or based on selection average/peak.
- **scripts/Items/ajsfx_MediaItemCounter.lua** — Displays a persistent, configurable counter for the number of media items on each visible track.
- **scripts/Items/ajsfx_MediaItemCounter_Settings.lua** — A GUI for configuring the Media Item Counter.
- **scripts/Items/ajsfx_SetAllSelectedItemsLengthToFirstSelectedItem.lua** — Sets the length of all selected items to match the length of the first selected item.
- **scripts/Items/ajsfx_ToggleMuteSelectedItemsOrTracks.lua** — Toggles mute with priority: Razor Edits > Selected Items > Selected Tracks.

---

## Sound Design Docs

Reference guides and notes for sound design and REAPER workflow. See the **[docs/](docs/)** folder.

---

## License

[MIT](LICENSE)
