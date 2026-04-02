# REAPER API & Environment

## Common API Functions
- `r.CountSelectedTracks(0)` / `r.GetSelectedTrack(0, i)` — iterate selected tracks
- `r.CountSelectedMediaItems(0)` / `r.GetSelectedMediaItem(0, i)` — iterate selected items
- `r.GetMediaTrackInfo_Value(track, "I_FOLDERCOMPACT")` — folder collapse state: `0`=normal, `1`=small, `2`=collapsed
- `r.GetMediaTrackInfo_Value(track, "B_SHOWINTCP")` — track visibility in TCP
- `r.GetParentTrack(track)` — parent track for depth traversal
- `r.CalculateNormalization(source, type, target, 0, 0)` — returns linear gain needed to hit target level
- `r.JS_Window_FindChildByID` / `r.JS_Window_GetRect` — js_ReaScriptAPI extension for window geometry

## State Change Count Usage
Use `r.GetProjectStateChangeCount(0)` for cache invalidation or as a signal for project-state changes to avoid redundant per-frame iteration in overlay scripts.

## External Resources
- [ReaScript Documentation](https://raw.githubusercontent.com/ReaTeam/Doc/master/reascripthelp.html) (Community Maintained)
- [REAPER API Reference](https://www.reaper.fm/sdk/reascript/reascript.php) (Official)
- [js_ReaScriptAPI](https://github.com/juliansader/ReaExtensions) (Essential Extension)
- [reaper-imgui](https://github.com/cfillion/reaper-imgui) (GUI Extension)
