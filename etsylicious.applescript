###############################################
# PROPERTIES
###############################################

set AppleScript's text item delimiters to ","
property repeatCount : 0
property s : 0.5
property comma : ","
property stripParens : "replace(/[()]/g,'')"
property stripCommas : "replace(/,/g,'')"
property stripListedOn : "replace(/Listed on /g,'')"
property stripResults : "replace(/[ Results]/g,'')"
property newLine : "\n"
property default_delay : 0.01


on _delay()
	delay default_delay
end _delay

-----------------------------------------------
-- SELECTORS
-----------------------------------------------

property selector_tagName : "#content > div > div.content.bg-white.col-md-12.pl-xs-1.pr-xs-0.pr-md-1.pl-lg-0.pr-lg-0.bb-xs-1 > div > div > div.col-group.pl-xs-0.search-listings-group > div:nth-child(2) > div.clearfix.pb-xs-1-5 > div.float-left > div > h1"

property selector_totalListingResults : "#content > div > div.content.bg-white.col-md-12.pl-xs-1.pr-xs-0.pr-md-1.pl-lg-0.pr-lg-0.bb-xs-1 > div > div > div.col-group.pl-xs-0.search-listings-group > div:nth-child(2) > div.clearfix.pb-xs-1-5 > div.float-left > div > span:nth-child(5)"

property selector_shopName : ".v2-listing-card__shop > p"
property selector_listingTitle : ".v2-listing-card__info > div > p"
property selector_totalReviews : ".v2-listing-card__rating > div + span"
property selector_listingPrice : ".n-listing-card__price .currency-value"
property selector_badge : ".v2-listing-card__badge"

###############################################
# WAIT FOR PAGE LOAD
###############################################

on page_loaded(timeout_value)
	_delay()
	repeat with i from 1 to the timeout_value
		tell application "Safari"
			if (do JavaScript "document.readyState" in document 1) is "complete" then
				return true
			else if i is the timeout_value then
				return false
			else
				_delay()
			end if
		end tell
	end repeat
	return false
end page_loaded


##############################################
# LIST HANDLING
##############################################

----------------------------------------------
-- Set file path
----------------------------------------------
on setFilePath(fileName)
	tell application "Finder"
		set thePath to (((path to desktop) as string) & fileName)
	end tell
	
	return thePath
end setFilePath

----------------------------------------------
-- Make a list from an existing file
----------------------------------------------
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


----------------------------------------------
-- Insert item into a list
----------------------------------------------
on insertItemInList(theItem, theList, thePosition)
	set theListCount to length of theList
	if thePosition is 0 then
		return false
	else if thePosition is less than 0 then
		if (thePosition * -1) is greater than theListCount + 1 then return false
	else
		if thePosition is greater than theListCount + 1 then return false
	end if
	if thePosition is less than 0 then
		if (thePosition * -1) is theListCount + 1 then
			set beginning of theList to theItem
		else
			set theList to reverse of theList
			set thePosition to (thePosition * -1)
			if thePosition is 1 then
				set beginning of theList to theItem
			else if thePosition is (theListCount + 1) then
				set end of theList to theItem
			else
				set theList to (items 1 thru (thePosition - 1) of theList) & theItem & (items thePosition thru -1 of theList)
			end if
			set theList to reverse of theList
		end if
	else
		if thePosition is 1 then
			set beginning of theList to theItem
		else if thePosition is (theListCount + 1) then
			set end of theList to theItem
		else
			set theList to (items 1 thru (thePosition - 1) of theList) & theItem & (items thePosition thru -1 of theList)
		end if
	end if
	return theList
end insertItemInList




###############################################
## FILE READING AND WRITING
###############################################

---------------------------------------------
-- File Subroutine
---------------------------------------------
on writeTextToFile(theText, theFile, overwriteExistingContent)
	try
		set theFile to theFile as string
		set theOpenedFile to open for access file theFile with write permission
		
		if overwriteExistingContent is true then set eof of theOpenedFile to 0
		write theText to theOpenedFile starting at eof
		close access theOpenedFile
		
		return true
	on error
		try
			close access file theFile
		end try
		
		return false
	end try
end writeTextToFile


---------------------------------------------
-- File Read/Write Handler
---------------------------------------------
on writeFile(theContent, writable, fileName, fileExtension)
	set now to current date
	set mo to (month of now as string)
	set addDaytoYear to (year of now) * 100 + (day of now) as string
	set d to text -2 thru -1 of addDaytoYear
	set e to text 1 thru 3 of mo
	set f to text -6 thru -3 of addDaytoYear
	set this_Story to theContent
	tell application "Finder"
		set theFile to (((path to desktop) as string) & "" & fileName & "." & fileExtension & "")
	end tell
	writeTextToFile(this_Story, theFile, writable)
end writeFile


----------------------------------------------
-- Open a File
----------------------------------------------
on openFile(theFile, theApp)
	tell application "Finder"
		open file ((path to desktop folder as text) & theFile) using ((path to applications folder as text) & theApp)
	end tell
end openFile

###############################################
# DOM INTERACTIONS
###############################################
----------------------------------------------
-- Set URL of Safari
----------------------------------------------
on setURL(keyword)
	tell application "Safari"
		set theURL to "https://www.etsy.com/search/handmade?q=" & keyword & "&use_mmx=1&kubernetes_fanout=2&original_query=" & keyword & ""
		set URL of document 1 to theURL
	end tell
end setURL

###############################################
# WRITE HEADERS
###############################################
----------------------------------------------
-- Write Headers
----------------------------------------------
on writeHeaders()
	set headers to "Tag, Total Listings, Avg Reviews, Avg Price, % Offer Free Shipping"
	
	writeFile(headers & newLine, false, "tag-research-results", "csv")
end writeHeaders


###############################################
# DOM DATA
###############################################
----------------------------------------------
-- Basic Handler
----------------------------------------------
on getFromDom(selector, method)
	try
		tell application "Safari"
			set a to do JavaScript "document.querySelector('" & selector & "')." & method & "" in document 1
		end tell
		return a
	on error
		return false
	end try
end getFromDom


----------------------------------------------
-- Iterative Handler
----------------------------------------------
on getListingData(instance, selector, method)
	try
		tell application "Safari"
			set a to do JavaScript "document.querySelectorAll('#reorderable-listing-results li')[" & instance & "].querySelector('" & selector & "')." & method & "" in document 1
		end tell
		return a
	on error
		return 0
	end try
end getListingData


----------------------------------------------
-- Total # of Listings on Pg 1
----------------------------------------------
on get_totalListingsCount()
	set a to getFromDom("#reorderable-listing-results", "childElementCount")
	_delay()
	return a
end get_totalListingsCount


----------------------------------------------
-- MATH - List Sum and Avg
----------------------------------------------
on listAvg(theList)
	set the_list to theList
	set sum to 0
	set n to count the_list
	
	repeat with i from 1 to n
		_delay()
		
		set sum to sum + (item i of the_list)
	end repeat
	
	return sum / n
end listAvg


on listSum(theList)
	set the_list to theList
	set sum to 0
	set n to count the_list
	
	repeat with i from 1 to n
		_delay()
		
		set sum to sum + (item i of the_list)
	end repeat
	
	return sum
end listSum


###############################################
# LOOPS
###############################################

----------------------------------------------
-- Main Routine
----------------------------------------------
on getDataLoop()
	set theCount to -1
	set theReviewsList to {}
	set thePricingList to {}
	set theFreeShippingList to {}
	set theBestSellerList to {}
	
	set text item delimiters to ","
	
	# -----------------------------------------
	# Set the input with current keyword
	# -----------------------------------------
	set tagSearchQuery to getFromDom(selector_tagName, "innerText")
	
	
	# ------------------------------------------
	# Get number of Listings with current tag
	# ------------------------------------------	
	set totalListingResults to getFromDom(selector_totalListingResults, "innerText." & stripParens & "." & stripCommas & "." & stripResults)
	
	
	# ------------------------------------------
	# Get total number of listings on page 1
	# ------------------------------------------
	set n to get_totalListingsCount()
	
	
	# ------------------------------------------
	# Iterate over listings to get data
	# ------------------------------------------
	repeat with i from 0 to n
		_delay()
		
		# ------------------------
		# Total Reviews
		# ------------------------
		set totalReviews to getListingData(i, selector_totalReviews, "innerText." & stripParens & "." & stripCommas)
		_delay()
		
		insertItemInList(totalReviews, theReviewsList, 1)
		
		# ------------------------
		# Listing Prices
		# ------------------------
		set listingPrice to getListingData(i, selector_listingPrice, "innerText")
		_delay()
		
		insertItemInList(listingPrice, thePricingList, 1)
		
		# ------------------------
		# Free Shipping
		# ------------------------
		set freeShipping to getListingData(i, selector_badge, "innerText")
		_delay()
		
		if freeShipping does not contain "Free shipping" then
			set freeShipping to 0
		else
			set freeShipping to 1
		end if
		
		log "Free Shipping Value is " & freeShipping & " (This should be a number, always.)"
		
		_delay()
		
		insertItemInList(freeShipping, theFreeShippingList, 1)
		log "Insert " & freeShipping & " into the list..."
		
		_delay()
		
		# ------------------------
		# Best Sellers
		# ------------------------
		set bestSeller to getListingData(i, selector_badge, "innerText")
		_delay()
		
		if bestSeller does not contain "Bestseller" then
			set bestSeller to 0
		else if bestSeller contains "Bestseller" then
			set bestSeller to 1
		end if
		
		_delay()
		log "Best Sellers Value is " & bestSeller & " (This should be a number, always.)"
		
		insertItemInList(bestSeller, theBestSellerList, 1)
		log "Insert " & bestSeller & " into the list..."
		_delay()
	end repeat
	
	# ------------------------
	# CALCULATE AVGS
	# ------------------------
	_delay()
	
	set avgReviews to listAvg(theReviewsList)
	log "Calc Avg Reviews"
	_delay()
	
	set avgPrice to listAvg(thePricingList)
	log "Calc Avg Price"
	_delay()
	
	set freeShippingPercentage to (listSum(theFreeShippingList) / n)
	log "Calc Free Shipping %"
	_delay()
	
	set bestSellerPercentage to (listSum(theBestSellerList) / n)
	log "Calc Best Seller %"
	_delay()
	
	# ------------------------
	# WRITE DATA TO FILE
	# ------------------------
	writeFile(tagSearchQuery & "," & totalListingResults & "," & avgReviews & "," & avgPrice & "," & freeShippingPercentage & "," & bestSellerPercentage & newLine, false, "tag-research-results", "csv")
end getDataLoop


###############################################
-- MAIN ROUTINE
###############################################
on action_set_keywords()
	writeHeaders()
	
	set baseKeywordsList to makeListFromFile("base-keywords.txt")
	
	repeat with a from 1 to length of baseKeywordsList
		set theCurrentListItem to item a of baseKeywordsList
		setURL(theCurrentListItem)
		delay 5
		getDataLoop()
	end repeat
	
	return baseKeywordsList
end action_set_keywords

###############################################

action_set_keywords()

