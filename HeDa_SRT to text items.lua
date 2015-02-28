 -- SRT import to Text items
 -- dev alpha code. Use at your own risk
 
 

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



	function HeDaSetNote(item,newnote)  -- HeDa - SetNote v1.0
		--ref: Lua: boolean retval, string str reaper.GetSetItemState(MediaItem item, string str)
		retval, s = reaper.GetSetItemState(item, "")	-- get the current item's chunk
		--dbug("\nChunk=" .. s .. "\n")
		has_notes = s:find("<NOTES")  -- has notes?
		if has_notes then
			-- there are notes already
			chunk, note, chunk2 = s:match("(.*<NOTES\n)(.*)(\n>\nIMGRESOURCEFLAGS.*)")
			newchunk = chunk .. newnote .. chunk2
			--dbug(newchunk .. "\n")
			
		else
			--there are still no notes
			chunk,chunk2 = s:match("(.*IID%s%d+)(.*)")
			newchunk = chunk .. "\n<NOTES\n" .. newnote .. "\n>\nIMGRESOURCEFLAGS 0" .. chunk2
			--dbug(newchunk .. "\n")
		end
		reaper.GetSetItemState(item, newchunk)	-- set the new chunk with the note
	end



----------------------------------------------------------------------
function CreateTextItem(starttime, endtime, notetext)

	--ref: Lua: number startOut retval, number endOut reaper.GetSet_LoopTimeRange(boolean isSet, boolean isLoop, number startOut, number endOut, boolean allowautoseek)
	reaper.GetSet_LoopTimeRange(1,0,starttime,endtime,0)	-- define the time range for the empty item
	
	--ref: Lua:  reaper.Main_OnCommand(integer command, integer flag)
	reaper.Main_OnCommand(40142,0) -- insert empty item
	
	--ref: Lua: MediaItem reaper.GetSelectedMediaItem(ReaProject proj, integer selitem)
	item = reaper.GetSelectedMediaItem(0,0) -- get the selected item
	
	HeDaSetNote(item, "|" .. notetext) -- set the note  add | character to the beginning of each line. only 1 line for now.
	
	reaper.SetEditCurPos(endtime, 1, 0)	-- moves cursor for next item
end


function read_lines(filepath)

	local f = io.input(filepath)
	repeat
	  s = f:read ("*l") -- read one line
	  if s then  -- if not end of file (EOF)
	   dbug("\nline = " .. s) -- print that line
		if string.find(s,'-->') then
			
			--00:04:22,670 --> 00:04:26,670
			sh, sm, ss, sms, eh, em, es, ems = s:match("(.*):(.*):(.*),(.*)%-%->(.*):(.*):(.*),(.*)")
			if sh then
				positionStart = tonumber(sh)*3600 + tonumber(sm)*60 + tonumber(ss) + (tonumber(sms)/1000)
				positionEnd = tonumber(eh)*3600 + tonumber(em)*60 + tonumber(es) + (tonumber(ems)/1000)
				dbug ("positionStart=" .. positionStart)
				dbug ("positionEnd=" .. positionEnd)
				textline = f:read ("*l") -- read next line with the text
				dbug ("textline=" .. textline)
				CreateTextItem(positionStart, positionEnd, textline);  --creates the text item
			end
			
		end
	  end
	until not s  -- until end of file

	f:close()


end



-- START -----------------------------------------------------
  
--ref: Lua: boolean retval, string filenameNeed4096 reaper.GetUserFileNameForRead(string filenameNeed4096, string title, string defext)
retval, filetxt = reaper.GetUserFileNameForRead("", "Select SRT file", "srt") --ref: boolean retval, string filenameNeed4096 reaper.GetUserFileNameForRead(string filenameNeed4096, string title, string defext)

if retval then 
	
	reaper.Undo_BeginBlock()
	read_lines(filetxt);
	--ref: Lua:  reaper.Undo_EndBlock(string descchange, integer extraflags)
	reaper.Undo_EndBlock("import SRT subtitles", 0)

else
	--ref: Lua: integer reaper.ShowMessageBox(string msg, string title, integer type)
	-- type 0=OK,1=OKCANCEL,2=ABORTRETRYIGNORE,3=YESNOCANCEL,4=YESNO,5=RETRYCANCEL : ret 1=OK,2=CANCEL,3=ABORT,4=RETRY,5=IGNORE,6=YES,7=NO
	reaper.ShowMessageBox("Cancelled and nothing was imported into REAPER","Don't worry",0)
end
