###############################################
# PROPERTIES

set AppleScript's text item delimiters to ","
property repeatCount : 0
property s : 0.5
property comma : ","
property stripParens : "replace(/[()]/g,'')"
property stripCommas : "replace(/,/g,'')"
property stripListedOn : "replace(/Listed on /g,'')"
property stripResults : "replace(/[ Results]/g,'')"
property stripFavorites : "replace(/[ favorites]/g,'')"
property newLine : "\n"
property default_delay : 0.15

# Load Script
on load_script(_scriptName)
	tell application "Finder"
		set scriptsPath to "scripts:" as string
		set _myPath to container of (path to me) as string
		set _loadPath to (_myPath & scriptsPath & _scriptName) as string
		load script (alias _loadPath)
	end tell
end load_script

###############################################
# SCRIPT REFERENCES

on load(_scriptName)
	set _script to load_script(_scriptName)
	set a to run _script
	return
end load

##############################################
# PROGRESS INDICATORS

on progress_reset()
	-- Reset the progress information
	set progress total steps to 0
	set progress completed steps to 0
	set progress description to ""
	set progress additional description to ""
end progress_reset

###############################################
# FILE READING AND WRITING

# File Subroutine
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


# File Read/Write Handler
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


# Write to File
on writeToFile(a)
	writeFile(a, false, "related-tags-results", "csv")
end writeToFile


# Open a File
on openFile(theFile, theApp)
	tell application "Finder"
		open file ((path to desktop folder as text) & theFile) using ((path to applications folder as text) & theApp)
	end tell
end openFile


##############################################
# LIST HANDLING


# Set file path
on setFilePath(fileName)
	tell application "Finder"
		set thePath to (((path to desktop) as string) & fileName)
	end tell
	
	return thePath
end setFilePath


# Make a list from an existing file
on makeListFromFile(a)
	set filePath to setFilePath(a)
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


# Insert item into a list
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
	delay default_delay
	return theList
end insertItemInList


###############################################
# URLS


on setQueryURL(keyword)
	tell application "Safari"
		set theURL to "https://www.etsy.com/search/?q=" & keyword & ""
		delay default_delay
		set URL of document 1 to theURL
		delay default_delay
	end tell
end setQueryURL

# Full URL
on setFullURL(a)
	tell application "Safari"
		delay default_delay
		set URL of document 1 to a
		delay default_delay
	end tell
end setFullURL


###############################################
# DOM

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
# CONSTRUCTORS





# Total number of tags within a listing
on get_listingTagTotal()
	set a to getFromDom(".listing-tag-list", 0, "childElementCount")
	return a
end get_listingTagTotal

# Get listing tag
on get_listingTags(instance)
	set a to getFromDom(".tag-button-link", instance, "innerText.replace(/,/g,'').replace(/[&]/g,'and')")
	return a
end get_listingTags

# Get Shop Name
on get_shop_name()
	set a to getFromDom("#seller-wrapper > div > div:nth-child(1) > div > div.flag-body > div.mb-xs-1 > a > span", 0, "innerText.replace(/[$+]/g,'')")
	return a
end get_shop_name

# Get Shop Link
on get_shop_link()
	set a to getFromDom(".flag-body > div > a", 0, "href")
	return a
end get_shop_link

# Get Shop Sales
on get_shop_sales()
	set a to getFromDom(".contact-shop-owner-button + div :first-child", 0, "innerText.replace(/[, Sales]/g,'')")
	return a
end get_shop_sales

# Get listing favorites
on get_listingFavorites()
	set a to getFromDom("#item-overview a", 0, "innerText.replace(/[,personpeople]/g,'')")
	return a
end get_listingFavorites

# Get listing start date
on get_listingDate()
	set a to getFromDom("#tags + .ui-toolkit > ul :first-child", 0, "innerText.replace(/,/g,'').replace(/Listed on/g,'')")
	return a
end get_listingDate

# Get number of listing reviews
on get_reviews()
	set a to getFromDom("#reviews > div > div.col-xs-12.pb-xs-3.pl-xs-0.pr-lg-0.pt-xs-0.pt-md-0 > div > span.pl-xs-1.text-gray-lighter", 0, "innerText.replace(/[(),]/g,'')")
	return a
end get_reviews

# Get listing price
on get_listing_price()
	set a to getFromDom("#listing-page-cart > div:nth-child(1) > div > div:nth-child(3) > p > span.text-largest.strong.override-listing-price", 0, "innerText.replace(/[$+,]/g,'')")
	return a
end get_listing_price

# Get reviews on listing page
on get_listing_shop_reviews()
	set a to getFromDom("#seller-wrapper > div > div:nth-child(1) > div > div.flag-body > div.mb-xs-1 > div > a > span", 0, "innerText.replace(/[(,)]/g,'')")
	return a
end get_listing_shop_reviews



################################################
# GET DATA

# Get total listings
on get_page1_totalListings()
	set a to getFromDom("#reorderable-listing-results", 0, "childElementCount")
	return a
end get_page1_totalListings


# Get listing url
on get_listing_url(instance)
	set a to getFromDom("#reorderable-listing-results .listing-link", instance, "href")
	return a
end get_listing_url


# Get Total Listings of Page 1
on getURLs()
	set theList to {}
	set listingsTotal to get_page1_totalListings()
	
	repeat with x from 1 to (listingsTotal - 1)
		set i to get_listing_url(x)
		log i
		insertItemInList(i, theList, x)
	end repeat
	
	return theList
end getURLs

###############################################
# CHECK PAGE LOADED

on check_page_loaded(selector)
	delay 0.5
	tell application "Safari"
		repeat
			try
				set a to do JavaScript "document.querySelector('" & selector & "').DOCUMENT_TYPE_NODE"
				log "Loaded!"
				delay 2
				exit repeat
			on error
				log "Loading..."
			end try
		end repeat
		return true
	end tell
end check_page_loaded

###############################################
# SAVE DATA

on save_tags(fileName)
	try
		set theList to {}
		set repeatCount to get_listingTagTotal()
		
		repeat with a from 1 to repeatCount
			set theTag to get_listingTags(a) as string
			insertItemInList(theTag, theList, 1)
			writeFile(theTag & newLine, false, fileName & "-related-tags", "csv")
		end repeat
		return theList
	on error
		return "No Tags on this Listing."
	end try
end save_tags

###############################################
# FILE HEADERS

on write_tagList_headers(fileName)
	set headers to "Tag"
	writeFile(headers & newLine, false, fileName & "-related-tags", "csv")
end write_tagList_headers

on write_listing_data_headers(fileName)
	set headers to "Shop, Sales, Reviews, Favs, Date, Price, Tags"
	writeFile(headers & newLine, false, fileName & "-tag-query-results", "csv")
end write_listing_data_headers

# Get Listing Data
on save_listing_data(fileName)
	set theShopName to get_shop_name()
	set theShopSales to get_shop_sales()
	set theReviews to get_reviews()
	set theFavorites to get_listingFavorites()
	set theDate to get_listingDate()
	set theListingPrice to get_listing_price()
	set theTags to save_tags(fileName)
	
	set theShopLink to get_shop_link()
	
	setFullURL(theShopLink)
	
	delay 8
	#check_page_loaded("#seller-wrapper")	
	
	set theShopSales to get_shop_sales()
	
	delay default_delay
	
	writeFile(theShopName & "," & theShopSales & "," & theReviews & "," & theFavorites & "," & theDate & "," & theListingPrice & "," & theTags & newLine, false, fileName & "-tag-query-results", "csv")
end save_listing_data


# Make base keyword List
on make_base_keyword_list(a)
	set theList to makeListFromFile(a)
	return theList
end make_base_keyword_list




################################################
################################################
# MAIN ROUTINE - finding relevant tags

on makeURLArray()
	(*set etsyURL to "https://www.etsy.com"
	setFullURL(etsyURL)
	check_page_loaded(".vesta-hero")*)
	
	# Make list of keywords
	set theList to make_base_keyword_list("base-keywords.txt")
	set initial_query to item 1 of theList
	setQueryURL(initial_query)
	
	# Wait for page load
	#check_page_loaded(".search-listings-group")
	delay 8
	
	
	set theLinkList to getURLs()
	set theTagList to {}
	
	# Set number of times to repeat
	set listCount to length of theLinkList
	
	# Progress Indicators
	set progress total steps to listCount
	set progress completed steps to 0
	set progress description to "Processing Base Keywords..."
	set progress additional description to ""
	
	write_tagList_headers(initial_query)
	write_listing_data_headers(initial_query)
	
	repeat with a from 1 to length of theLinkList
		# Process each line of the base file
		set progress additional description to "Processing Listing " & a & " of " & listCount & ""
		set queuedURL to item a of theLinkList
		
		# Initiate the queued URL
		setFullURL(queuedURL)
		
		# Wait for page load
		#check_page_loaded(".search-listings-group")
		delay 8
		save_tags(initial_query)
		save_listing_data(initial_query)
		
		delay 2
	end repeat
end makeURLArray


makeURLArray()

