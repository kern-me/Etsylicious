###############################################
# PROPERTIES
##############################################

set AppleScript's text item delimiters to ","
property repeatCount : 0
property s : 0.5
property comma : ","
property stripParens : "replace(/[()]/g,'')"
property stripCommas : "replace(/,/g,'')"
property stripListedOn : "replace(/Listed on /g,'')"
property stripResults : "replace(/[ Results]/g,'')"
property newLine : "\n"
property default_delay : 0.05


###############################################
# SELECTORS
##############################################

property selector_inputValue : "#search-query"

property selector_tagName : "#content > div > div.content.bg-white.col-md-12.pl-xs-1.pr-xs-0.pr-md-1.pl-lg-0.pr-lg-0.bb-xs-1 > div > div > div.col-group.pl-xs-0.search-listings-group > div:nth-child(2) > div.clearfix.pb-xs-1-5 > div.float-left > div > h1"

property selector_totalListingResults : "#content > div > div.content.bg-white.col-md-12.pl-xs-1.pr-xs-0.pr-md-1.pl-lg-0.pr-lg-0.bb-xs-1 > div > div > div.col-group.pl-xs-0.search-listings-group > div:nth-child(2) > div.clearfix.pb-xs-1-5 > div.float-left > div > span:nth-child(5)"

property selector_shopName : ".v2-listing-card__shop > p"
property selector_listingTitle : ".v2-listing-card__info > div > p"
property selector_totalReviews : ".v2-listing-card__rating > div + span"
property selector_listingPrice : ".n-listing-card__price .currency-value"
property selector_badge : ".v2-listing-card__badge"

on strip(a)
	set b to "replace(/[" & a & "]/g,'')"
	return b as string
end strip

###############################################
# FILE READING AND WRITING
###############################################

-- Set file path
on setFilePath(fileName)
	tell application "Finder"
		set thePath to (((path to desktop) as string) & fileName)
	end tell
	
	return thePath
end setFilePath


-- File Subroutine
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


-- File Read/Write Handler
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

-- Open a File
on openFile(theFile, theApp)
	tell application "Finder"
		open file ((path to desktop folder as text) & theFile) using ((path to applications folder as text) & theApp)
	end tell
end openFile


##############################################
# LIST HANDLING
##############################################


-- Make a list from an existing file
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



-- Insert item into a list
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
	delay 0.01
	return theList
end insertItemInList


##############################################
# MATH
##############################################

-- MATH - List Sum and Avg
on listAvg(theList)
	set the_list to theList
	set sum to 0
	set n to count the_list
	
	repeat with i from 1 to n
		delay 0.01
		
		set sum to sum + (item i of the_list)
	end repeat
	
	delay 0.01
	return sum / n
end listAvg


on listSum(theList)
	set the_list to theList
	set sum to 0
	set n to count the_list
	
	repeat with i from 1 to n
		delay 0.01
		
		set sum to sum + (item i of the_list)
	end repeat
	
	delay 0.01
	return sum
end listSum


###############################################
# Set URLs
###############################################
on setQueryURL(keyword)
	tell application "Safari"
		set theURL to "https://www.etsy.com/search/?q=" & keyword & ""
		delay 0.01
		set URL of document 1 to theURL
		delay 0.01
	end tell
end setQueryURL

# Full URL
on setFullURL(a)
	tell application "Safari"
		delay 0.01
		set URL of document 1 to a
		delay 0.01
	end tell
end setFullURL



###############################################
# GET DATA FROM DOM
###############################################
# Get from DOM handler
on getFromDom(selector, instance, method)
	try
		tell application "Safari"
			set a to do JavaScript "document.querySelectorAll('" & selector & "')[" & instance & "]." & method & "" in document 1
		end tell
		return a
	on error
		return false
	end try
end getFromDom


###############################################
# URLS
###############################################
on get_currentURL()
	tell application "Safari"
		set currentURL to URL of current tab of window 1
		return currentURL
	end tell
end get_currentURL


-- Set URL of Safari

on setURL(keyword)
	tell application "Safari"
		set theURL to "https://www.etsy.com/search/?q=" & keyword & ""
		delay default_delay
		set URL of document 1 to theURL
		delay default_delay
		return theURL as string
	end tell
end setURL

--


###############################################
# SPECIFIC DOM DATA
###############################################

-- Iterative Handler
on getListingData(instance, selector, method)
	try
		tell application "Safari"
			set a to do JavaScript "document.querySelectorAll('#reorderable-listing-results li')[" & instance & "].querySelector('" & selector & "')." & method & "" in document 1
			delay 0.01
		end tell
		return a
	on error
		return 0
	end try
end getListingData


-- Total # of Listings on Pg 1
on get_totalListingsCount()
	tell application "Safari"
		set a to do JavaScript "document.querySelector('#reorderable-listing-results').childElementCount" in document 1
		delay default_delay
		return a
	end tell
end get_totalListingsCount



-- Total # of Tags on the Listing
on get_totalListingsTags()
	tell application "Safari"
		set a to do JavaScript "document.querySelector('.listing-tag-list').childElementCount" in document 1
		delay default_delay
		return a
	end tell
end get_totalListingsTags



-- Get Tags from Listing Page
on getTag(instance)
	tell application "Safari"
		try
			delay default_delay
			set a to do JavaScript "document.querySelectorAll('.listing-tag-list li')[" & instance & "].innerText" in document 1
			delay default_delay
			return a
		on error
			return false
		end try
	end tell
end getTag


-- Get Listing Link
on getListingLink(instance)
	tell application "Safari"
		try
			delay default_delay
			set a to do JavaScript "document.querySelectorAll('.listing-link')[" & instance & "].href" in document 1
			delay default_delay
			return a
		on error
			return false
		end try
	end tell
end getListingLink




################################################
# PAGE LOAD
###############################################

# Wait for page load
on compareURLS(queuedURL)
	repeat
		#Get the current URL
		set currentURL to get_currentURL()
		delay default_delay
		if currentURL is queuedURL then exit repeat
	end repeat
end compareURLS



###############################################
# PROGRESS INDICATORS
###############################################

on progress_indicator_top(theList, progress_description)
	set listCount to length of theList
	set progress total steps to listCount
	set progress completed steps to 0
	set progress description to progress_description
end progress_indicator_top

on progress_indicator_inline(unit, instance, listCount)
	set progress additional description to "Processing " & unit & " " & instance & " of " & listCount & ""
end progress_indicator_inline

on progress_indicator_reset()
	set progress total steps to 0
	set progress completed steps to 0
	set progress description to ""
	set progress additional description to ""
end progress_indicator_reset


###############################################
# WRITE HEADERS
###############################################

# Write Headers
on writeHeaders()
	set headers to "Tag, Total Listings, Avg Reviews, Avg Price, % Offer Free Shipping"
	writeFile(headers & newLine, false, "results", "csv")
end writeHeaders


###############################################
# CONSTRUCTORS
###############################################

on makeList()
	set a to makeListFromFile("base-keywords.txt")
	return a
end makeList


###############################################
# LOOPS
###############################################
on getAllData(a, b, c, d, n)
	# Get all the data from the dom
	repeat with i from 0 to n
		delay default_delay
		
		# Get and Record Total Reviews
		set totalReviews to getListingData(i, selector_totalReviews, "innerText." & stripParens & "." & stripCommas)
		insertItemInList(totalReviews, a, 1)
		
		set listingPrice to getListingData(i, selector_listingPrice, "innerText")
		insertItemInList(listingPrice, b, 1)
		
		# Get and Record Free Shipping
		set freeShipping to getListingData(i, selector_badge, "innerText")
		
		if freeShipping does not contain "Free shipping" then
			set freeShipping to 0
		else
			set freeShipping to 1
		end if
		
		delay default_delay
		insertItemInList(freeShipping, c, 1)
		
		# Get and Record Best Sellers
		set bestSeller to getListingData(i, selector_badge, "innerText")
		
		if bestSeller does not contain "Bestseller" then
			set bestSeller to 0
		else if bestSeller contains "Bestseller" then
			set bestSeller to 1
		end if
		
		delay default_delay
		insertItemInList(bestSeller, d, 1)
	end repeat
end getAllData


# Get Data Loop
on getDataLoop()
	set theCount to -1
	set theReviewsList to {}
	set thePricingList to {}
	set theFreeShippingList to {}
	set theBestSellerList to {}
	
	set text item delimiters to ","
	
	# Get Tag Name
	set tagSearchQuery to getFromDom(selector_tagName, 0, "innerText")
	
	# Get Competition
	set totalListingResults to getFromDom(selector_totalListingResults, 0, "innerText." & stripParens & "." & stripCommas & "." & stripResults)
	
	# Count the number of listings on page 1
	set n to get_totalListingsCount()
	
	# Get all the data from the dom
	getAllData(theReviewsList, thePricingList, theFreeShippingList, theBestSellerList, n)
	
	delay default_delay
	
	set avgReviews to listAvg(theReviewsList)
	set avgPrice to listAvg(thePricingList)
	set freeShippingPercentage to (listSum(theFreeShippingList) / n)
	set bestSellerPercentage to (listSum(theBestSellerList) / n)
	
	writeFile(tagSearchQuery & "," & totalListingResults & "," & avgReviews & "," & avgPrice & "," & freeShippingPercentage & "," & bestSellerPercentage & newLine, false, "tag-research-results", "csv")
end getDataLoop


###############################################

on make_url_list(theList, listCount)
	set queryURLs to {}
	repeat with a from 1 to listCount
		set keyword to item a of theList
		set queuedURL to "https://www.etsy.com/search/?q=" & keyword & ""
		insertItemInList(queuedURL, queryURLs, 1)
	end repeat
	return queryURLs
end make_url_list



# Make the list of query URLs from the base-keywords file
on make_baseList()
	set theList to makeListFromFile("base-keywords.txt")
	set listCount to length of theList
	set url_list to make_url_list(theList, listCount)
	
	return url_list as list
end make_baseList

###############################################

# Process the urlQueryList
on process_urlQueryList()
	set theList to make_baseList()
	set listCount to length of theList
	
	progress_indicator_top(theList, "")
	
	repeat with a from 1 to listCount
		progress_indicator_inline("Search Querys", a, listCount)
		
		set queuedURL to item a of theList
		
		setFullURL(queuedURL)
		
		#wait for page to load
		delay 8
		
		getDataLoop()
	end repeat
	progress_indicator_reset()
	log "Finished"
end process_urlQueryList

process_urlQueryList()