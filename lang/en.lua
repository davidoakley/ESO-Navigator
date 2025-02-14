local mkstr = function(id, str)
    ZO_CreateStringId(id, str)
    SafeAddVersion(id, 1)
end

-- Controls menu entry (opens the Navigator tab on the World Map)
mkstr("SI_BINDING_NAME_NAVIGATOR_SEARCH", "Open on World Map")

-- Name of the tab on the World Map
mkstr("NAVIGATOR_TAB_SEARCH","Navigator")

-- Shown on the bottom keybind bar
NAVIGATOR_KEYBIND_SEARCH = SI_GAMEPAD_HELP_SEARCH

-- Edit box hint text (<<1>> is replaced by 'Tab')
mkstr("NAVIGATOR_SEARCH_KEYPRESS","Search (<<1>>)")
mkstr("NAVIGATOR_SEARCH","Search locations, zones or @players")

-- Category Headings
mkstr("NAVIGATOR_CATEGORY_BOOKMARKS", "Bookmarks")
mkstr("NAVIGATOR_CATEGORY_RECENT", "Recent")
mkstr("NAVIGATOR_CATEGORY_ZONES", "Zones")
NAVIGATOR_CATEGORY_RESULTS = SI_GAMEPAD_TRADING_HOUSE_BROWSE_RESULTS_TITLE
NAVIGATOR_CATEGORY_GROUP = SI_MAIN_MENU_GROUP

-- Result hints
mkstr("NAVIGATOR_HINT_NORESULTS", "No results found")
mkstr("NAVIGATOR_HINT_NORECENTS", "Destinations that you travel to will automatically appear here")
mkstr("NAVIGATOR_HINT_NOBOOKMARKS", "Right click a destination to create (or delete) a bookmark for it")

-- Enter key label (keep it short!)
mkstr("NAVIGATOR_KEY_ENTER", "Enter")

-- Result types
NAVIGATOR_DUNGEON = SI_GROUPFINDERCATEGORY0
NAVIGATOR_ARENA = SI_GROUPFINDERCATEGORY1
NAVIGATOR_TRIAL = SI_GROUPFINDERCATEGORY2

-- Tooltips
mkstr("NAVIGATOR_NOT_KNOWN", "Not known by this character") -- Location not known
mkstr("NAVIGATOR_TIP_DOUBLECLICK_TO_TRAVEL", "Double-click to travel to <<1>>") -- 1:zone

-- Action and menu items
mkstr("NAVIGATOR_TRAVEL_TO_ZONE", "Travel to <<1>>")
mkstr("NAVIGATOR_MENU_ADDBOOKMARK", "Add Bookmark")
mkstr("NAVIGATOR_MENU_ADDHOUSEBOOKMARK", "Add Primary Residence Bookmark")
mkstr("NAVIGATOR_MENU_REMOVEBOOKMARK", "Remove Bookmark")
mkstr("NAVIGATOR_MENU_MOVEBOOKMARKUP", "Move Bookmark up")
mkstr("NAVIGATOR_MENU_MOVEBOOKMARKDOWN", "Move Bookmark down")
NAVIGATOR_MENU_SHOWONMAP = SI_QUEST_JOURNAL_SHOW_ON_MAP
NAVIGATOR_MENU_SETDESTINATION = SI_WORLD_MAP_ACTION_SET_PLAYER_WAYPOINT

-- Status / error messages
mkstr("NAVIGATOR_NO_TRAVEL_PLAYER", "No players to travel to")
mkstr("NAVIGATOR_CANNOT_TRAVEL_TO_PLAYER", "Unable to travel to player <<1>>") -- 1:player
mkstr("NAVIGATOR_NO_PLAYER_IN_ZONE", "Failed to find a player to travel to in <<1>>") -- 1:zone
mkstr("NAVIGATOR_PLAYER_NOT_IN_ZONE", "<<1>> is no longer in <<2>>") -- 1:player 2:zone
mkstr("NAVIGATOR_TRAVELING_TO_LOCATION", "Traveling to <<1>>") -- 1:location
mkstr("NAVIGATOR_RECALLING_TO_LOCATION_COST", "Recalling to <<1>> for <<2>>") -- 1:location 2:cost
mkstr("NAVIGATOR_TRAVELING_TO_ZONE_VIA_PLAYER", "Traveling to <<1>> via <<2>>") -- 1:zone 2:player
mkstr("NAVIGATOR_TRAVELING_TO_PLAYER_IN_ZONE", "Traveling to <<1>> in <<2>>") -- 1:player 2:zone
mkstr("NAVIGATOR_TRAVELING_TO_HOUSE_INSIDE", "Traveling to <<1>> (inside)") -- 1:house
mkstr("NAVIGATOR_TRAVELING_TO_HOUSE_OUTSIDE", "Traveling to <<1>> (outside)") -- 1:house
mkstr("NAVIGATOR_TRAVELING_TO_PLAYER_HOUSE", "Traveling to <<gu:1>> house") -- 1:house

-- Chat slash command
mkstr("NAVIGATOR_SLASH_DESCRIPTION", "Navigator: Teleports to the given zone, wayshrine, house or player")

-- Custom location names
mkstr("NAVIGATOR_LOCATION_OBLIVIONPORTAL", "Oblivion Portal")
