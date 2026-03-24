-- Unit tests for lib/ajsfx_core.lua
-- Run with: lua tests/test_core.lua (from the repository root)
-- These tests mock the REAPER API since they run outside REAPER.

local passed = 0
local failed = 0

local function test(name, fn)
    local ok, err = pcall(fn)
    if ok then
        passed = passed + 1
        print("  PASS: " .. name)
    else
        failed = failed + 1
        print("  FAIL: " .. name .. " - " .. tostring(err))
    end
end

-- Minimal REAPER API mock
local mock_console = {}
local mock_msgbox = {}
local mock_tracks = {}
local mock_extstate = {}

reaper = {
    ShowConsoleMsg = function(msg) table.insert(mock_console, msg) end,
    ShowMessageBox = function(msg, title, typ) table.insert(mock_msgbox, {msg=msg, title=title}) end,
    GetParentTrack = function(track)
        if track and track.parent then return track.parent end
        return nil
    end,
    GetMediaTrackInfo_Value = function(track, key)
        if not track or not track.info then return 0 end
        return track.info[key] or 0
    end,
    SetMediaTrackInfo_Value = function(track, key, val)
        if track then track.info[key] = val end
    end,
    CountSelectedTracks = function() return 0 end,
    CountTracks = function() return 0 end,
    GetSetMediaTrackInfo_String = function(track, key, val, set)
        if track and track.razor then
            return true, track.razor
        end
        return false, ""
    end,
    GetMediaItemInfo_Value = function(item, key)
        if item and item.info then return item.info[key] or 0 end
        return 0
    end,
    SetMediaItemInfo_Value = function(item, key, val)
        if item then item.info[key] = val end
    end,
    Undo_BeginBlock = function() end,
    Undo_EndBlock = function() end,
    PreventUIRefresh = function() end,
    HasExtState = function(section, key)
        return mock_extstate[section] and mock_extstate[section][key] ~= nil
    end,
    GetExtState = function(section, key)
        if mock_extstate[section] then return mock_extstate[section][key] or "" end
        return ""
    end,
    SetExtState = function(section, key, val, persist)
        if not mock_extstate[section] then mock_extstate[section] = {} end
        mock_extstate[section][key] = val
    end,
    UpdateArrange = function() end,
}

-- Load core library
package.path = "lib/?.lua;" .. package.path
local core = require("ajsfx_core")

print("\n=== ajsfx_core.lua Unit Tests ===\n")

-- --- Color Conversion Tests ---
print("Color Conversion:")

test("ColorToRGBA round-trip", function()
    local original = 0x99FFFFFF -- AABBGGRR: A=0x99 B=0xFF G=0xFF R=0xFF
    local rgba = core.ColorToRGBA(original)
    local back = core.RGBAToColor(rgba)
    assert(back == original, string.format("Expected 0x%08X, got 0x%08X", original, back))
end)

test("ColorToRGBA known value", function()
    -- AABBGGRR: A=0xFF B=0x00 G=0x80 R=0x40
    local aabbggrr = 0xFF008040
    local rgba = core.ColorToRGBA(aabbggrr)
    -- Expected RRGGBBAA: R=0x40 G=0x80 B=0x00 A=0xFF
    local expected = 0x408000FF
    assert(rgba == expected, string.format("Expected 0x%08X, got 0x%08X", expected, rgba))
end)

test("RGBAToColor known value", function()
    -- RRGGBBAA: R=0x40 G=0x80 B=0x00 A=0xFF
    local rgba = 0x408000FF
    local aabbggrr = core.RGBAToColor(rgba)
    -- Expected AABBGGRR: A=0xFF B=0x00 G=0x80 R=0x40
    local expected = 0xFF008040
    assert(aabbggrr == expected, string.format("Expected 0x%08X, got 0x%08X", expected, aabbggrr))
end)

test("ColorToRGBA with zero alpha", function()
    local original = 0x00FF8040 -- A=0x00 B=0xFF G=0x80 R=0x40
    local rgba = core.ColorToRGBA(original)
    local back = core.RGBAToColor(rgba)
    assert(back == original, string.format("Round-trip failed: 0x%08X -> 0x%08X", original, back))
end)

-- --- GetTrackDepth Tests ---
print("\nGetTrackDepth:")

test("nil track returns 0", function()
    assert(core.GetTrackDepth(nil) == 0)
end)

test("top-level track returns 0", function()
    local track = { info = {} }
    assert(core.GetTrackDepth(track) == 0)
end)

test("nested track returns correct depth", function()
    local root = { info = {} }
    local child = { parent = root, info = {} }
    local grandchild = { parent = child, info = {} }
    assert(core.GetTrackDepth(grandchild) == 2)
end)

test("depth guard prevents infinite loop", function()
    -- Create a circular reference (should not happen in REAPER, but tests the guard)
    local track_a = { info = {} }
    local track_b = { info = {} }
    track_a.parent = track_b
    track_b.parent = track_a
    local depth = core.GetTrackDepth(track_a)
    assert(depth == 100, "Expected depth guard at 100, got " .. depth)
end)

-- --- GetRazorEdits Tests ---
print("\nGetRazorEdits:")

test("empty razor edits returns empty table", function()
    local track = {}
    local edits = core.GetRazorEdits(track)
    assert(#edits == 0)
end)

test("quoted GUIDs parsed correctly", function()
    local track = { razor = '1.0 2.0 "{GUID-1}" 3.0 4.0 "{GUID-2}"' }
    local edits = core.GetRazorEdits(track)
    assert(#edits == 2, "Expected 2 edits, got " .. #edits)
    assert(edits[1].start_time == 1.0)
    assert(edits[1].end_time == 2.0)
    assert(edits[1].guid == "{GUID-1}")
    assert(edits[2].start_time == 3.0)
    assert(edits[2].end_time == 4.0)
end)

test("unquoted GUIDs parsed as fallback", function()
    local track = { razor = "1.0 2.0 {GUID-1}" }
    local edits = core.GetRazorEdits(track)
    assert(#edits == 1, "Expected 1 edit, got " .. #edits)
    assert(edits[1].guid == "{GUID-1}")
end)

test("non-GUID unquoted entries are skipped", function()
    local track = { razor = "1.0 2.0 NOTGUID" }
    local edits = core.GetRazorEdits(track)
    assert(#edits == 0, "Expected 0 edits for non-GUID, got " .. #edits)
end)

-- --- ToggleMuteItems Tests ---
print("\nToggleMuteItems:")

test("mutes all when any unmuted", function()
    local items = {
        { info = { B_MUTE = 0 } },
        { info = { B_MUTE = 1 } },
        { info = { B_MUTE = 0 } },
    }
    core.ToggleMuteItems(items)
    for _, item in ipairs(items) do
        assert(item.info.B_MUTE == 1, "Expected all muted")
    end
end)

test("unmutes all when all muted", function()
    local items = {
        { info = { B_MUTE = 1 } },
        { info = { B_MUTE = 1 } },
    }
    core.ToggleMuteItems(items)
    for _, item in ipairs(items) do
        assert(item.info.B_MUTE == 0, "Expected all unmuted")
    end
end)

test("empty list does nothing", function()
    core.ToggleMuteItems({}) -- should not error
end)

-- --- ToggleMuteTracks Tests ---
print("\nToggleMuteTracks:")

test("mutes all tracks when any unmuted", function()
    local tracks = {
        { info = { B_MUTE = 1 } },
        { info = { B_MUTE = 0 } },
    }
    core.ToggleMuteTracks(tracks)
    for _, track in ipairs(tracks) do
        assert(track.info.B_MUTE == 1, "Expected all tracks muted")
    end
end)

-- --- Error Function Tests ---
print("\nError:")

test("core.Error logs to console and msgbox", function()
    mock_console = {}
    mock_msgbox = {}
    core.Error("test error")
    assert(#mock_console == 1, "Expected 1 console message")
    assert(mock_console[1]:find("test error"), "Console message should contain error text")
    assert(#mock_msgbox == 1, "Expected 1 message box")
end)

-- --- Transaction Tests ---
print("\nTransaction:")

test("Transaction catches errors via core.Error", function()
    mock_console = {}
    mock_msgbox = {}
    core.Transaction("Test", function()
        error("intentional error")
    end)
    assert(#mock_msgbox == 1, "Expected error message box")
    assert(mock_msgbox[1].msg:find("intentional error"), "Should contain error message")
end)

-- --- LoadMediaCounterConfig Tests ---
print("\nLoadMediaCounterConfig:")

test("returns defaults when no ExtState", function()
    mock_extstate = {}
    local cfg = core.LoadMediaCounterConfig()
    assert(cfg.FONT_SIZE == 12)
    assert(cfg.REFRESH_RATE == 30)
    assert(cfg.VERTICAL_ALIGN == 0.5)
end)

test("reads from ExtState when available", function()
    mock_extstate = {
        ajsfx_MediaItemCounter = {
            FONT_SIZE = "20",
            REFRESH_RATE = "60",
        }
    }
    local cfg = core.LoadMediaCounterConfig()
    assert(cfg.FONT_SIZE == 20, "Expected 20, got " .. tostring(cfg.FONT_SIZE))
    assert(cfg.REFRESH_RATE == 60, "Expected 60, got " .. tostring(cfg.REFRESH_RATE))
    assert(cfg.VERTICAL_ALIGN == 0.5, "Unset values should use defaults")
end)

-- --- Summary ---
print(string.format("\n=== Results: %d passed, %d failed ===\n", passed, failed))
if failed > 0 then
    os.exit(1)
end
