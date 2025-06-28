function ToggleMuteSelectedItems()
  -- Check for any selected items
  local item_count = reaper.CountSelectedMediaItems(0)
  if item_count > 0 then

    local any_muted = false
    local all_muted = true

    -- Iterate over selected items to check mute state
    for i = 0, item_count - 1 do
      local item = reaper.GetSelectedMediaItem(0, i)
      local muted = reaper.GetMediaItemInfo_Value(item, "B_MUTE")
      if muted == 1 then
        any_muted = true
      else
        all_muted = false 
      end
    end

    -- Apply mute/unmute based on state
    for i = 0, item_count - 1 do
      local item = reaper.GetSelectedMediaItem(0, i)
      if all_muted then -- All muted, unmute all 
        reaper.SetMediaItemInfo_Value(item, "B_MUTE", 0) 
      else -- Any muted or none muted, mute all
        reaper.SetMediaItemInfo_Value(item, "B_MUTE", 1) 
      end
    end

    reaper.UpdateArrange() -- Refresh the track view
  end
end

ToggleMuteSelectedItems() -- Call the function to execute it

reaper.AddRemoveReaScript(true, 0, "ToggleMuteSelectedItems", 0)
