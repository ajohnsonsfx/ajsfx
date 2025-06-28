function ajsfx_Track_UnCollapseVisibleChildrenAtHighestSelectedLevel()
  -- Get the selected tracks
  local selected_tracks = reaper.CountSelectedTracks(0)

  -- If no track is selected, do nothing
  if selected_tracks == 0 then return end

  -- Find the highest nesting level among VISIBLE selected tracks
  local highest_level = 0 -- Initialize with the lowest possible value
  for i = 0, selected_tracks - 1 do
    local track = reaper.GetSelectedTrack(0, i)

    -- Skip if the track is not visible (its parent is collapsed)
    local parent_track = reaper.GetParentTrack(track)
    local parent_collapsed = false
    if parent_track then
      parent_collapsed = reaper.GetMediaTrackInfo_Value(parent_track, "I_FOLDERCOMPACT") > 0
    end
    if parent_collapsed then goto continue end -- Skip to the next iteration

    -- Calculate nesting level for the selected track
    local current_level = 0
    while parent_track do
      current_level = current_level + 1
      parent_track = reaper.GetParentTrack(parent_track)
    end

    if current_level > highest_level then
      highest_level = current_level
    end

    ::continue::
  end

  -- If no visible track is selected, do nothing
  if highest_level == 0 then return end

  -- Find all tracks with the highest nesting level and uncollapse them,
  -- but only if their parent is not collapsed
  local track_count = reaper.CountTracks(0)
  for i = 0, track_count - 1 do
    local current_track = reaper.GetTrack(0, i)

    -- Calculate nesting level for the current track
    local current_level = 0
    parent_track = reaper.GetParentTrack(current_track)
    while parent_track do
      current_level = current_level + 1
      parent_track = reaper.GetParentTrack(parent_track)
    end

    -- If the current track has the highest nesting level and its parent is not collapsed, uncollapse it
    if current_level == highest_level then
      local parent_collapsed = false
      if parent_track then
        parent_collapsed = reaper.GetMediaTrackInfo_Value(parent_track, "I_FOLDERCOMPACT") > 0
      end
      if not parent_collapsed then
        reaper.SetMediaTrackInfo_Value(current_track, "I_FOLDERCOMPACT", 0) 
      end
    end
  end

  reaper.UpdateArrange()
end

ajsfx_Track_UnCollapseVisibleChildrenAtHighestSelectedLevel()