--[[
 * ReaScript Name: Export SRT
 * Description: Exports selected items notes to a SRT subtitles file
 * Instructions: Note that the initial cursor position is very important 
 * Author: HeDa
 * Author URl: http://forum.cockos.com/member.php?u=47822
 * Version: 0.2 beta
 * Repository: 
 * Repository URl: 
 * File URl: 
 * License: GPL v3
 * Forum Thread:
 * Forum Thread URl: 
 * REAPER: 5.0
 * Extensions: 
 
 
 * Change log:
 * v0.2 (2015-02-28)
	+ initial cursor position offset
 * v0.1 (2015-02-27)
	+ initial version

]]

------------------- OPTIONS ----------------------------------
-- this script has no options


----------------------------------------------- End of Options



	dbug_flag = 0 -- set to 0 for no debugging messages, 1 to get them
	function dbug (text) 
		if dbug_flag==1 then  
			if text then
				reaper.ShowConsoleMsg(text .. '\n')
			else
				reaper.ShowConsoleMsg("nil")
			end
		end
	end


	function HeDaGetNote(item) 
		retval, s = reaper.GetSetItemState(item, "")	-- get the current item's chunk
		if retval then
			--dbug("\nChunk=" .. s .. "\n")
			note = s:match(".*<NOTES\n(.*)>\nIMGRESOURCEFLAGS.*");
			if note then note = string.gsub(note, "|", ""); end;	-- remove all the | characters
		end
		
		return note;
	end

	
	

	
----------------------------------------------------------------------


function tosrtformat(position)
	hour = math.floor(position/3600)
	minute = math.floor((position - 3600*math.floor(position/3600)) / 60)
	second = math.floor(position - 3600*math.floor(position/3600) - 60*math.floor((position-3600*math.floor(position/3600))/60))
	millisecond = math.floor(1000*(position-math.floor(position)) )
	
	return string.format("%02d:%02d:%02d,%03d", hour, minute, second, millisecond)
end

function export_txt(file)
	reaper.PreventUIRefresh(-10) -- prevent refreshing
	
	reaper.Undo_BeginBlock() -- Begin undo group
	
	initialtime = reaper.GetCursorPosition();	-- store initial cursor position as time origin 00:00:00
	
	local f = io.open(file, "w")
	io.output(file)
	
	
	reaper.Main_OnCommand(40421,0) -- select all items in track
	
	
	local selected_items_count = reaper.CountSelectedMediaItems(0);
	for i=0, selected_items_count-1 do
		
		item = reaper.GetSelectedMediaItem(0, i)
		
		--ref: number reaper.GetMediaItemInfo_Value(MediaItem item, string parmname)
		itemstart = reaper.GetMediaItemInfo_Value(item, "D_POSITION") - initialtime --get itemstart
		itemlength = reaper.GetMediaItemInfo_Value(item, "D_LENGTH") --get length
		itemend = itemstart + itemlength
		
		note = HeDaGetNote(item)  -- get the note text
		
		-- write item number 
		f:write(i+1 .. "\n")
		
		-- write start and end   00:04:22,670 --> 00:04:26,670
		str_start = tosrtformat(itemstart)
		str_end = tosrtformat(itemend)
		f:write(str_start .. " --> " ..  str_end .. "\n")

		-- write text
		f:write(note)

		-- write new line for next subtitle
		f:write("\n")
	end
	
	f:close() -- never forget to close the file
	
	
	
	reaper.Main_OnCommand(40289,0) -- unselect all items
	
	--ref: reaper.SetEditCurPos(number time, boolean moveview, boolean seekplay)
	reaper.SetEditCurPos(initialtime, 1, 1) -- move cursor to original position before running script
	
	--ref: Lua:  reaper.Undo_EndBlock(string descchange, integer extraflags)
	reaper.Undo_EndBlock("Export SRT subtitles", 0) -- End undo group
	
	reaper.PreventUIRefresh(10) -- can refresh again
	
	
	----- display message to user
	
	
	--ref: Lua: MediaTrack reaper.GetSelectedTrack(ReaProject proj, integer seltrackidx)
	track = reaper.GetSelectedTrack(0, 0)
	--ref: boolean retval, string stringNeedBig reaper.GetSetMediaTrackInfo_String(MediaTrack tr, string parmname, string stringNeedBig, boolean setnewvalue)
	retval, track_label = reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "", false)
	
	if initialtime > 0 then
		offsetmsg= "\n\nThe file has been exported with an offset time of " .. initialtime .." seconds"
	else
		offsetmsg=""
	end
	reaper.ShowMessageBox("\"" .. track_label .. "\" track has been exported to: " .. file .. offsetmsg, "Information",0)
end





-- START -----------------------------------------------------


if reaper.CountSelectedTracks(0) > 0 then
	--ref: Lua: MediaTrack reaper.GetSelectedTrack(ReaProject proj, integer seltrackidx)
	track = reaper.GetSelectedTrack(0, 0)
	--ref: boolean retval, string stringNeedBig reaper.GetSetMediaTrackInfo_String(MediaTrack tr, string parmname, string stringNeedBig, boolean setnewvalue)
	retval, track_label = reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "", false)
	
	defaultvals_csv = "C:\\subtitles"; --default values
	--ref: boolean retval, string retvals_csv reaper.GetUserInputs(string title, integer num_inputs, string captions_csv, string retvals_csv)
	retval, retvals_csv = reaper.GetUserInputs("Where to save the file?", 1, "Enter full path of the folder:", defaultvals_csv) 
		
	if retval then 
		--dbug(retvals_csv)
		filenamefull = retvals_csv .. "\\" .. track_label .. ".srt"
		export_txt(filenamefull)
	else
		--ref: Lua: integer reaper.ShowMessageBox(string msg, string title, integer type)
		-- type 0=OK,1=OKCANCEL,2=ABORTRETRYIGNORE,3=YESNOCANCEL,4=YESNO,5=RETRYCANCEL : ret 1=OK,2=CANCEL,3=ABORT,4=RETRY,5=IGNORE,6=YES,7=NO
		reaper.ShowMessageBox("Cancelled and nothing was exported","Don't worry",0)
	end

else
	reaper.ShowMessageBox("Select a track with the Text items first","Please",0)
end
