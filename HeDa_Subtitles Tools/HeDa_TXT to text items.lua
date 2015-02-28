--[[
 * ReaScript Name: Txt lines to empty items with notes
 * Description: Creates empty items with notes from the lines in a txt file.
 * Instructions: 
 Create and select a track where the items will be created. 
 Set the cursor position to where you want to insert the items
 Run the script
 Select a txt file containing lyrics 
 Set the time in seconds per character and separator lines if any.
 * Author: HeDa
 * Author URl: http://forum.cockos.com/member.php?u=47822
 * Version: 0.1 beta
 * Repository: 
 * Repository URl: 
 * File URl: 
 * License: GPL v3
 * Forum Thread:
 * Forum Thread URl: http://forum.cockos.com/showthread.php?t=156239
 * REAPER: 5.0
 * Extensions: 
 */
 
/**
 * Change log:
 * v0.1 (2015-02-26)
	+ configurable time length per character and separator lines
	+ Lua translation of EEL version

 */
]]

------------------- OPTIONS ----------------------------------
-- this script has no options

----------------------------------------------- End of Options


-- my second Lua script... what a beauty is to code in Lua



	dbug_flag = 0 -- set to 0 for no debugging messages, 1 to get them
	function dbug (text) ; if dbug_flag==1 then ; reaper.ShowConsoleMsg(text) ; end; end


	-- see if the file exists
	function file_exists(file)
	  local f = io.open(file, "rb")
	  if f then f:close() end
	  return f ~= nil
	end

	-- get all lines from a file, returns an empty 
	-- list/table if the file does not exist
	function lines_from(file)
	  if not file_exists(file) then return {} end
	  lines = {}
	  for line in io.lines(file) do 
		lines[#lines + 1] = line
	  end
	  return lines
	end


	function SetNote(item,newnote)  -- HeDa - SetNote v1.0
		--ref: Lua: boolean retval, string str reaper.GetSetItemState(MediaItem item, string str)
		retval, s = reaper.GetSetItemState(item, "")	-- get the current item's chunk
		dbug("\nChunk=" .. s .. "\n")
		has_notes = s:find("<NOTES")  -- has notes?
		if has_notes then
			-- there are notes already
			chunk, note, chunk2 = s:match("(.*<NOTES\n)(.*)(\n>\nIMGRESOURCEFLAGS.*)")
			newchunk = chunk .. newnote .. chunk2
			dbug(newchunk .. "\n")
			
		else
			--there are still no notes
			chunk,chunk2 = s:match("(.*IID%s%d+)(.*)")
			newchunk = chunk .. "\n<NOTES\n" .. newnote .. "\n>\nIMGRESOURCEFLAGS 0" .. chunk2
			dbug(newchunk .. "\n")
		end
		reaper.GetSetItemState(item, newchunk)	-- set the new chunk with the note
	end

	
----------------------------------------------------------------------
function CreateEmptyItem(notetext)
	starttime = reaper.GetCursorPosition();	
	longline = string.len(notetext) - 1;
	dbug("length = " .. longline .. "\n")
	if longline > 0 then 
		endtime = starttime + (charlength*longline)
	else
		-- if the line is only 1 character it is a separator line
		endtime = starttime + (seplength)
	end
	
	if longline > 0 then 
		--ref: Lua: number startOut retval, number endOut reaper.GetSet_LoopTimeRange(boolean isSet, boolean isLoop, number startOut, number endOut, boolean allowautoseek)
		reaper.GetSet_LoopTimeRange(1,0,starttime,endtime,0)	-- define the time range for the empty item
		
		--ref: Lua:  reaper.Main_OnCommand(integer command, integer flag)
		reaper.Main_OnCommand(40142,0) -- insert empty item
		
		--ref: Lua: MediaItem reaper.GetSelectedMediaItem(ReaProject proj, integer selitem)
		item = reaper.GetSelectedMediaItem(0,0) -- get the selected item
		
		SetNote(item, "|" .. notetext) -- set the note  add | character to the beginning of each line. only 1 line for now.
	end
	
	reaper.SetEditCurPos(endtime, 1, 0)	-- moves cursor for next item
end


function read_lines(file)
	local lines = lines_from(file)
	for k,v in pairs(lines) do
		dbug( "Line = " .. k .. " " .. v .. '\n')
		CreateEmptyItem(v);  --creates the empty item
	end
	reaper.GetSet_LoopTimeRange(1,0,0,0,1) -- reset timerange
	reaper.Main_OnCommand(40289,0) -- unselect all items
end






-- START -----------------------------------------------------
  
--ref: Lua: boolean retval, string filenameNeed4096 reaper.GetUserFileNameForRead(string filenameNeed4096, string title, string defext)
retval, filetxt = reaper.GetUserFileNameForRead("", "Select txt file", "txt") --ref: boolean retval, string filenameNeed4096 reaper.GetUserFileNameForRead(string filenameNeed4096, string title, string defext)

if retval then 
	defaultvals_csv = "0.1,0.5"; --default values

	--ref: boolean retval, string retvals_csv reaper.GetUserInputs(string title, integer num_inputs, string captions_csv, string retvals_csv)
	retval, retvals_csv = reaper.GetUserInputs("Settings", 2, "Seconds per character:, Seconds per separator line", defaultvals_csv) 
	charlength, seplength = retvals_csv:match("(%d?.?%d+),(%d?.?%d+)")
	
	read_lines(filetxt);
else
	--ref: Lua: integer reaper.ShowMessageBox(string msg, string title, integer type)
	-- type 0=OK,1=OKCANCEL,2=ABORTRETRYIGNORE,3=YESNOCANCEL,4=YESNO,5=RETRYCANCEL : ret 1=OK,2=CANCEL,3=ABORT,4=RETRY,5=IGNORE,6=YES,7=NO
	reaper.ShowMessageBox("Cancelled and nothing was imported into REAPER","Don't worry",0)
end
