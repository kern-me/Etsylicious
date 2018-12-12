###############################################
# PROPERTIES
###############################################
set AppleScript's text item delimiters to ","
property newLine : "\n"
property default_delay : 0.05
property stripNonDigits : "replace ( /[^0-9.]/g, '' )"

---------------------------------
# SELECTORS
---------------------------------

property selector_inputValue : "#search-query"

property selector_tag_name : ".search-listings-group h1"
property selector_results : ".search-listings-group > div:nth-child(2) > div > div > div > span:last-child"

property selector_shopName : ".v2-listing-card__shop > p"
property selector_title : ".v2-listing-card__info > div > p"
property selector_reviews : ".v2-listing-card__rating > div + span"
property selector_price : ".n-listing-card__price .currency-value"
property selector_badge : "#reorderable-listing-results > li"
property selector_badge_secondary : ".v2-listing-card__badge"
property selector_listingLink : ".listing-link"

property selector_sales : ".contact-shop-owner-button + div :first-child"
property selector_age : ".etsy-since"
property selector_favorites : "a.favorite-shop-action"
property selector_items : "#items-label span"

property url_shop_prefix : "https://www.etsy.com/shop/"

property selector_results_shop_name : ".v2-listing-card__shop > p"


###############################################
# DOM
###############################################

on getFromDom(selector, selectorSecondary, instance, method, option)
	if option is 1 then
		try
			tell application "Safari"
				set a to do JavaScript "document.querySelectorAll('" & selector & "')[" & instance & "]." & method & "" in document 1
			end tell
			return a
		on error
			return false
		end try
		
	else if option is 2 then
		try
			tell application "Safari"
				set a to do JavaScript "document.querySelectorAll('" & selector & "')[" & instance & "].querySelector('" & selectorSecondary & "')." & method & "" in document 1
				delay 0.01
			end tell
			return a
		on error
			return 0
		end try
	end if
end getFromDom



##############################################
# FILE READING AND WRITING
##############################################

---------------------------------
-- SET FILE PATH
---------------------------------

on setFilePath(fileName)
	tell application "Finder"
		set thePath to (((path to desktop) as string) & fileName)
	end tell
	
	return thePath
end setFilePath

---------------------------------
# FILE SUBROUTINE
---------------------------------

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

---------------------------------
# FILE READ/WRITE
---------------------------------

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

---------------------------------
# OPEN A FILE
---------------------------------

on openFile(theFile, theApp)
	tell application "Finder"
		open file ((path to desktop folder as text) & theFile) using ((path to applications folder as text) & theApp)
	end tell
end openFile


##############################################
# LIST HANDLING
##############################################

---------------------------------
# MAKE A LIST FROM FILE
---------------------------------
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


---------------------------------
-- INSERT ITEM INTO LIST
---------------------------------
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

###############################################
# PAGE LOADING
###############################################


---------------------------------
# URL COMPARISON
---------------------------------
on page_load_condition(currentUniqueVar)
	set theDelay to 0.5
	repeat
		delay theDelay
		set a to get_unique_node()
		delay theDelay
		log currentUniqueVar
		log "compared to:"
		log a
		
		if a is currentUniqueVar then
			log "loaded!"
			delay theDelay
			exit repeat
		else if a is not currentUniqueVar then
			log "loading..."
		end if
	end repeat
end page_load_condition

###############################################
# DATA PARSING
###############################################

---------------------------------
# LIST AVG
---------------------------------
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

---------------------------------
# LIST SUM
---------------------------------
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

---------------------------------
# ROUND A NUMBER
---------------------------------
on round_number(a)
	set b to round (a)
	return b
end round_number

---------------------------------
# MAKE INTO A STRING
---------------------------------
on make_string(a)
	set a to a as string
	return a
end make_string

---------------------------------
# STRIP NON NUMERIC CHARS
---------------------------------
on strip_non_numeric(theText)
	set newText to (do shell script "echo " & quoted form of theText & " | tr -d '[:alpha:]'")
	return newText
end strip_non_numeric

---------------------------------
# MAKE INTO A NUMBER
---------------------------------
on make_number(a)
	set b to strip_non_numeric(a)
	set b to b as number
	return b
end make_number

---------------------------------
# ROUND THEN CONVERT TO STRING
---------------------------------
on round_to_string(a)
	set a to round (a)
	set b to make_string(a)
	return b
end round_to_string

##############################################################################################
##############################################################################################

# START UNIQUE HANDLERS

##############################################################################################
##############################################################################################

###############################################
# SEARCH RESULTS HANDLERS
###############################################

---------------------------------
# GET TAG NAME
---------------------------------
on get_tag_name()
	set a to getFromDom(selector_tag_name, "", 0, "innerText", 1)
	return a
end get_tag_name

---------------------------------
# GET RESULTS
---------------------------------
on get_results()
	set a to getFromDom(selector_results, "", 0, "innerText." & stripNonDigits & "", 1)
	return a
end get_results

---------------------------------
# GET REVIEWS
---------------------------------
on get_reviews(instance)
	set a to getFromDom(selector_reviews, "", instance, "innerText." & stripNonDigits & "", 1)
	
	if a is false then
		return "0"
	else if a is not false then
		return a
	end if
end get_reviews

---------------------------------
# GET PRICE
---------------------------------
on get_price(instance)
	set a to getFromDom(selector_price, "", instance, "innerText." & stripNonDigits & "", 1)
	return a
end get_price

---------------------------------
# GET BADGE
---------------------------------
on get_badge(instance, option)
	set a to getFromDom(selector_badge, selector_badge_secondary, instance, "innerText", 2)
	set condition1 to "Bestseller"
	set condition2 to "Free shipping"
	
	if option is 1 then
		if a contains condition1 then
			return 1
		else if a does not contain condition1 then
			return 0
		end if
	end if
	
	if option is 2 then
		if a contains condition2 then
			return 1
		else if a does not contain condition2 then
			return 0
		end if
	end if
end get_badge

---------------------------------
# GET BEST SELLER
---------------------------------
on get_best_seller(instance)
	set a to getFromDom(selector_badge, selector_badge_secondary, instance, "innerText", 2)
	if a contains "Bestseller" then
		return 1
	else if a does not contain "Bestseller" then
		return 0
	end if
end get_best_seller

---------------------------------
# COUNT PAGE LISTINGS
---------------------------------
on count_listings()
	set a to getFromDom("#reorderable-listing-results", "", 0, "childElementCount", 1)
	return a
end count_listings

---------------------------------
# GET LISTING LINK
---------------------------------
on get_listing_link(instance)
	set a to getFromDom(selector_listingLink, "", instance, "href", 1)
	return a
end get_listing_link

---------------------------------
# GET RESULTS SHOP NAME
---------------------------------
on get_results_shop_name(instance)
	set a to getFromDom(selector_results_shop_name, "", instance, "innerText", 1)
	return a
end get_results_shop_name


##############################################
# SEARCH RESULTS PAGE DATA LOOPS
##############################################

---------------------------------
# LOOP REVIEWS
---------------------------------
on loop_reviews(theCount)
	set theList to {}
	
	repeat with a from 0 to theCount
		set b to get_reviews(a)
		insertItemInList(b, theList, 1)
	end repeat
	
	return theList
end loop_reviews

---------------------------------
# LOOP PRICE
---------------------------------
on loop_price(theCount)
	set theList to {}
	
	repeat with a from 0 to theCount
		set b to get_price(a)
		insertItemInList(b, theList, 1)
	end repeat
	
	return theList
end loop_price

---------------------------------
# LOOP BEST SELLER
---------------------------------
on loop_best_seller(theCount)
	set theList to {}
	
	repeat with a from 0 to theCount
		set b to get_badge(a, 1)
		insertItemInList(b, theList, 1)
	end repeat
	
	return theList
end loop_best_seller


---------------------------------
# LOOP FREESHIPPING
---------------------------------
on loop_free_shipping(theCount)
	set theList to {}
	
	repeat with a from 0 to theCount
		set b to get_badge(a, 2)
		insertItemInList(b, theList, 1)
	end repeat
	
	return theList
end loop_free_shipping


---------------------------------
# LOOP LISTING LINKS
---------------------------------
on loop_listing_links(theCount)
	set theList to {}
	
	repeat with a from 0 to theCount
		set b to get_listing_link(a)
		insertItemInList(b, theList, 1)
	end repeat
	
	return theList
end loop_listing_links

---------------------------------
# LOOP LISTING SHOP NAME
---------------------------------
on loop_results_shop_names()
	set theCount to count_listings() - 1
	set theList to {}
	
	repeat with a from 0 to theCount
		set b to get_results_shop_name(a)
		
		if theList does not contain b then
			insertItemInList(b, theList, 1)
		else
			log "Shop Name is already in the list. Moving to next word..."
		end if
	end repeat
	
	return theList
end loop_results_shop_names

---------------------------------
# LOOP FULL URLS
---------------------------------
on loop_full_urls()
	set urls to {}
	set shopNames to loop_results_shop_names()
	
	repeat with a from 1 to length of shopNames
		set queuedShopName to item a of shopNames
		set theURL to "https://www.etsy.com/shop/" & queuedShopName & ""
		log theURL
		insertItemInList(theURL, urls, a)
	end repeat
	
	return urls
end loop_full_urls


###############################################
# SHOP PAGE HANDLERS
###############################################

---------------------------------
# GET SHOP SALES
---------------------------------
on get_shop_sales()
	set a to getFromDom(selector_sales, "", 0, "innerText." & stripNonDigits & "", 1)
	if a is false then
		return 0
	else if a is not false then
		return a
	end if
end get_shop_sales

---------------------------------
# GET SHOP AGE
---------------------------------
on get_shop_age()
	set a to getFromDom(selector_age, "", 0, "innerText." & stripNonDigits & "", 1)
	if a is false then
		return 2019
	end if
	
	set b to 2019 - a
	return b
end get_shop_age

---------------------------------
# GET SHOP FAVORITES
---------------------------------
on get_shop_favorites()
	set a to getFromDom(selector_favorites, "", 0, "innerText." & stripNonDigits & "", 1)
	if a is false then
		return 0
	else if a is not false then
		return a
	end if
end get_shop_favorites

---------------------------------
# GET SHOP ITEMS
---------------------------------
on get_shop_items()
	set a to getFromDom(selector_items, "", 0, "innerText." & stripNonDigits & "", 1)
	if a is false then
		return 0
	else if a is not false then
		return a
	end if
end get_shop_items

---------------------------------
# WRITE HEADERS
---------------------------------
on writeHeaders()
	set headers to "Tag, Results, Reviews, Price, % Best Sellers, % Free Shipping, Sales, Shop Age, Favorites,  Items"
	
	writeFile(headers & newLine, false, "results", "csv")
end writeHeaders

---------------------------------
# MAKE FULL URLS
---------------------------------
on make_full_urls()
	set newList to {}
	set keywords to makeListFromFile("base-keywords.txt")
	repeat with a from 1 to length of keywords
		set queuedKeyword to item a of keywords
		set queuedURL to "https://www.etsy.com/search?q=" & queuedKeyword & ""
		
		insertItemInList(queuedURL, newList, 1)
	end repeat
	return newList
end make_full_urls





###############################################
# SEARCH RESULTS LOOPS
###############################################

on get_search_results_loops()
	set theCount to count_listings()
	set theList to {}
	set tagName to get_tag_name()
	set results to get_results()
	
	set reviewsTotal to loop_reviews(theCount)
	set priceTotal to loop_price(theCount)
	set bestSellerTotal to loop_best_seller(theCount)
	set freeShippingTotal to loop_free_shipping(theCount)
	
	# Calculate averages and percentages
	set avgReviews to listAvg(reviewsTotal)
	set avgPrice to listAvg(priceTotal)
	set bestSellerPercentage to listSum(bestSellerTotal) / theCount
	set freeShippingPercentage to listSum(freeShippingTotal) / theCount
	
	set avgReviews to round_to_string(avgReviews)
	set avgPrice to round_to_string(avgPrice)
	set bestSellerPercentage to make_string(bestSellerPercentage)
	set freeShippingPercentage to make_string(freeShippingPercentage)
	
	insertItemInList(tagName, theList, 1)
	insertItemInList(results, theList, 2)
	insertItemInList(avgReviews, theList, 3)
	insertItemInList(avgPrice, theList, 4)
	insertItemInList(bestSellerPercentage, theList, 5)
	insertItemInList(freeShippingPercentage, theList, 6)
	
	return theList
end get_search_results_loops


###############################################
# GET SHOP DATA
###############################################

---------------------------------
# GET SHOP DATA OF CURRENT PAGE
---------------------------------
on get_shop_page_content()
	set theList to {}
	set sales to get_shop_sales()
	set age to get_shop_age()
	set favorites to get_shop_favorites()
	set shopItems to get_shop_items()
	
	insertItemInList(sales, theList, 1)
	insertItemInList(age, theList, 2)
	insertItemInList(favorites, theList, 3)
	insertItemInList(shopItems, theList, 4)
	
	return theList
end get_shop_page_content

---------------------------------
# CALCULATE ALL SHOP DATA
---------------------------------
on get_shop_data()
	set masterList to {}
	
	set listSales to {}
	set listAge to {}
	set listFavorites to {}
	set listItems to {}
	
	
	set urls to loop_full_urls()
	set listCount to the length of urls
	
	set updatedSalesCount to 0
	set updatedAgeCount to 0
	set updatedFavoritesCount to 0
	set updatedShopItemsCount to 0
	
	repeat with a from 1 to listCount
		set queuedURL to item a of urls
		
		# Go to new URL
		setFullURL(queuedURL)
		
		# Page Load
		delay 6	
		
		set shop_page_content to get_shop_page_content()
		
		set sales to item 1 of shop_page_content
		set age to item 2 of shop_page_content
		set favorites to item 3 of shop_page_content
		set shopItems to item 4 of shop_page_content
		
		set updatedSalesCount to updatedSalesCount + sales
		set updatedAgeCount to updatedAgeCount + age
		set updatedFavoritesCount to updatedFavoritesCount + favorites
		set updatedShopItemsCount to updatedShopItemsCount + shopItems
	end repeat
	
	delay default_delay
	
	set avgSales to updatedSalesCount / listCount
	set avgAge to updatedAgeCount / listCount
	set avgFavorites to updatedFavoritesCount / listCount
	set avgListItems to updatedShopItemsCount / listCount
	
	set avgSales to round_to_string(avgSales)
	set avgAge to round_to_string(avgAge)
	set avgFavorites to round_to_string(avgFavorites)
	set avgListItems to round_to_string(avgListItems)
	
	delay default_delay
	
	#########
	
	insertItemInList(avgSales, masterList, 1)
	insertItemInList(avgAge, masterList, 2)
	insertItemInList(avgFavorites, masterList, 3)
	insertItemInList(avgListItems, masterList, 4)
	
	#########
	
	return masterList
end get_shop_data

###############################################
# MAIN PROCESS
###############################################

#writeHeaders()
on main()
	writeHeaders()
	
	set urlList to make_full_urls()
	
	repeat with a from 1 to length of urlList
		set queuedURL to item a of urlList
				
		setFullURL(queuedURL)
		
		delay 6
		
		set searchResults to get_search_results_loops()
		set shopData to get_shop_data()
		
		set searchResults to searchResults as string
		set shopData to shopData as string
		
		
		writeFile(searchResults & "," & shopData & newLine, false, "results", "csv")
	end repeat
end main

main()

#get_unique_node()







