local mkstr = function(id, str)
    ZO_CreateStringId(id, str)
    SafeAddVersion(id, 1)
end

-- is this needed? mkstr("NAVIGATOR_OPENTAB","Open Navigator tab (on Map screen)")

-- Name of the tab on the World Map
mkstr("NAVIGATOR_TAB_SEARCH","Navigator")

-- Shown on the bottom keybind bar
mkstr("NAVIGATOR_KEYBIND_SEARCH", "Search")

-- Edit box hint text (<<1>> is replaced by 'Tab')
mkstr("NAVIGATOR_SEARCH_KEYPRESS","Search (<<1>>)")
mkstr("NAVIGATOR_SEARCH","Search locations, zones or @players")

-- Category Headings
mkstr("NAVIGATOR_CATEGORY_RESULTS", "Results")
mkstr("NAVIGATOR_CATEGORY_BOOKMARKS", "Bookmarks")
mkstr("NAVIGATOR_CATEGORY_RECENT", "Recent")
mkstr("NAVIGATOR_CATEGORY_ZONES", "Zones")
mkstr("NAVIGATOR_CATEGORY_GROUP", "Group")

-- Result hints
mkstr("NAVIGATOR_HINT_NORESULTS", "No results found")
mkstr("NAVIGATOR_HINT_NORECENTS", "Destinations that you travel to will automatically appear here")
mkstr("NAVIGATOR_HINT_NOBOOKMARKS", "Right click a destination to create (or delete) a bookmark for it")

-- Enter key label (keep it short!)
mkstr("NAVIGATOR_KEY_ENTER", "Enter")

-- Result types
mkstr("NAVIGATOR_DUNGEON", "Dungeon")
mkstr("NAVIGATOR_TRIAL", "Trial")
mkstr("NAVIGATOR_ARENA", "Arena")

-- Tooltips
mkstr("NAVIGATOR_NOT_KNOWN", "Not known by this character")

-- Actions
mkstr("NAVIGATOR_NO_TRAVEL_PLAYER", "No players to travel to")
mkstr("NAVIGATOR_TRAVEL_TO_ZONE", "Travel to <<1>>")
mkstr("NAVIGATOR_CANNOT_TRAVEL_TO_PLAYER", "Unable to travel to player <<1>>")

-- Chat box output
mkstr("NAVIGATOR_NO_PLAYER_IN_ZONE", "Failed to find a player to travel to in <<1>>")
mkstr("NAVIGATOR_PLAYER_NOT_IN_ZONE", "<<1>> is no longer in <<2>>")
mkstr("NAVIGATOR_TRAVELING_TO_ZONE_VIA_PLAYER", "Traveling to <<1>> via <<2>>")

-- Chat slash command
mkstr("NAVIGATOR_SLASH_DESCRIPTION", "Navigator: Teleports to the given zone, wayshrine, house or player")

-- Menu items
mkstr("NAVIGATOR_MENU_ADDBOOKMARK", "Add Bookmark")
mkstr("NAVIGATOR_MENU_ADDHOUSEBOOKMARK", "Add Primary Residence Bookmark")
mkstr("NAVIGATOR_MENU_REMOVEBOOKMARK", "Remove Bookmark")
mkstr("NAVIGATOR_MENU_SHOWONMAP", "Show on map")
mkstr("NAVIGATOR_MENU_SETDESTINATION", "Set Destination")

-- Location names
mkstr("NAVIGATOR_LOCATION_OBLIVIONPORTAL", "Oblivion Portal")
