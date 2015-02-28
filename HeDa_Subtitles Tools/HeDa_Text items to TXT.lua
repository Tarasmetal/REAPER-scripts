--[[
 * ReaScript Name: Text items to TXT file
 * Description: Exports selected items notes to a txt file
 * Instructions: 
 * Author: HeDa
 * Author URl: http://forum.cockos.com/member.php?u=47822
 * Version: 0.1 beta
 * Repository: 
 * Repository URl: 
 * File URl: 
 * License: GPL v3
 * Forum Thread:
 * Forum Thread URl: 
 * REAPER: 5.0
 * Extensions: 
 */
 
/**
 * Change log:
 * v0.1 (2015-02-28)
	+ initial version

 */
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
			if note then note = string.gsub(note, "|", ""); end;
		end
		
		return note;
	end

	
	

	
----------------------------------------------------------------------




function export_txt(file)
	
	local f = io.open(file, "w")
	io.output(file)
	local selected_items_count = reaper.CountSelectedMediaItems(0);
	for i=0, selected_items_count-1 do
		item = reaper.GetSelectedMediaItem(0, i)
		
		--ref: number reaper.GetMediaItemInfo_Value(MediaItem item, string parmname)
		itemstart = reaper.GetMediaItemInfo_Value(item, "D_POSITION") --get itemstart
		itemlength = reaper.GetMediaItemInfo_Value(item, "D_LENGTH") --get length
		itemend = itemstart + itemlength
		
		if itemend_prev == itemstart or itemend_prev==nil then
			newline=""
		else
			newline="\n"
		end
		itemend_prev=itemend
		note = HeDaGetNote(item)
		f:write(newline .. note)
	end
	
	f:close()
	
	
end





-- START -----------------------------------------------------
  
--ref: Lua: boolean retval, string filenameNeed4096 reaper.GetUserFileNameForRead(string filenameNeed4096, string title, string defext)
--retval, filetxt = reaper.GetUserFileNameForRead("", "Select txt file", "txt") --ref: boolean retval, string filenameNeed4096 reaper.GetUserFileNameForRead(string filenameNeed4096, string title, string defext)
retval=true
if retval then 

	defaultvals_csv = "C:\\\\export.txt"; --default values
	--ref: boolean retval, string retvals_csv reaper.GetUserInputs(string title, integer num_inputs, string captions_csv, string retvals_csv)
	retval, retvals_csv = reaper.GetUserInputs("Enter file", 1, "Enter full path of txt file to write", defaultvals_csv) 
	
	
	dbug(retvals_csv)
	export_txt(retvals_csv)
else
	--ref: Lua: integer reaper.ShowMessageBox(string msg, string title, integer type)
	-- type 0=OK,1=OKCANCEL,2=ABORTRETRYIGNORE,3=YESNOCANCEL,4=YESNO,5=RETRYCANCEL : ret 1=OK,2=CANCEL,3=ABORT,4=RETRY,5=IGNORE,6=YES,7=NO
	reaper.ShowMessageBox("Cancelled and nothing was exported","Don't worry",0)
end
