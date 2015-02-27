--[[
/**
 * ReaScript Name: Toggle Solo tracks of selected items 
 * Description: Automatically solo tracks of selected items
 * Instructions:  Run the script. It will solo tracks of selected items 
 until you run the script again and stop it
 * Author: HeDa
 * Author URl: http://forum.cockos.com/member.php?u=47822
 * Repository: 
 * Repository URl: 
 * File URl: http://stash.reaper.fm/23354/HeDa_Toggle%20Solo%20Tracks%20of%20Selected%20Items.eel
 * License: GPL v3
 * Forum Thread: http://forum.cockos.com/showthread.php?t=155988
 * Forum Thread URl: 
 * Version: 0.1 beta
 * Version Date: 2015-02-21
 * REAPER: 4.76
 * Extensions: 
 */
 
/**
 * Change log:
 * v0.1 (2015-02-22)
	+ initial version Lua translation from EEL version

*/
]]--

-- ///////////// OPTIONS //////////

-- solo_mode = 1; normal solo
-- solo_mode = 2; solo in place
solo_mode = 2
















-- // Don't modify below here 
-- ////////////////////////////////////////////////////////////////////////////////////////////// 

-- Create array of tracks
TracksArray = {}   -- initialize variable array
NumberTracks = 0	-- init variable

reaper.PreventUIRefresh(1) -- don't refresh UI

-- create array of tracks
for i=0,reaper.CountSelectedMediaItems(0)-1 do
  local selected_item = reaper.GetSelectedMediaItem(0,i)
  local track = reaper.GetMediaItemTrack(selected_item)
  TracksArray[i+1] = track
  NumberTracks = NumberTracks + 1
  track_solo_state = reaper.GetMediaTrackInfo_Value(track, "I_SOLO");  --I_SOLO : int * : 0=not soloed, 1=solo, 2=soloed in place
end
--

-- toggle solo
if track_solo_state == 0 then
  solo = solo_mode;
else
  solo = 0;
end

for i=1,NumberTracks do
  reaper.SetMediaTrackInfo_Value(TracksArray[i], "I_SOLO", solo);
end
--

reaper.PreventUIRefresh(-1)  -- can refresh UI now

