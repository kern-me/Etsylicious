# Load Script
on load_script(_scriptName)
	tell application "Finder"
		set scriptsPath to "scripts:" as string
		set _myPath to container of (path to me) as string
		set _loadPath to (_myPath & scriptsPath & _scriptName) as string
		load script (alias _loadPath)
	end tell
end load_script

on setFilePath(fileName)
	tell application "Finder"
		set thePath to (((path to desktop) as string) & fileName)
	end tell
	
	return thePath
end setFilePath

on makeListFromFile("base-keywords.txt")
	set filePath to setFilePath("base-keywords.txt")
	set posixPath to (the POSIX path of filePath)
	set theList to {}
	set theLines to paragraphs of (read POSIX file posixPath)
	repeat with nextLine in theLines
		if length of nextLine is greater than 0 then
			copy nextLine to the end of theList
		end if
	end repeat
	return theList
end makeListFromFile

###############################################
# URLS
###############################################

---------------------------------
# GET CURRENT URL
---------------------------------
on get_currentURL()
	tell application "Safari"
		set currentURL to URL of current tab of window 1
		return currentURL
	end tell
end get_currentURL

---------------------------------
# SET VARIABLE URL
---------------------------------
on setVarURL(var)
	tell application "Safari"
		set theURL to url_shop_prefix & var
		delay 0.01
		set URL of document 1 to theURL
		delay 0.01
	end tell
end setVarURL


---------------------------------
# SET FULL URL
---------------------------------
on setFullURL(a)
	tell application "Safari"
		delay 0.01
		set URL of document 1 to a
		delay 0.01
	end tell
end setFullURL

####

on make_keyword_list()
	#set text item delimiters to newLine
	set theList to makeListFromFile("base-keywords.txt")
	return theList
end make_keyword_list

###

on queue_keywords()
	set theList to make_keyword_list()
	
	repeat with a from 1 to length of theList
		set queuedKeyword to item a of theList as string
		set queuedURL to "https://www.etsy.com/search/q=" & queuedKeyword & ""
		setFullURL(queuedURL)
		delay 5
		set theScript to load_script("global-handlers.scpt")
		tell theScript
			get_search_results_loops()
get_shop_data()
	end tell
		
	end repeat
end queue_keywords

queue_keywords()

