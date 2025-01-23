local mkstr = function(id, str)
    ZO_CreateStringId(id, str)
    SafeAddVersion(id, 1)
end

mkstr("NAVIGATOR_SEARCH","Search locations, zones or @players")
mkstr("NAVIGATOR_SEARCH_KEYPRESS","Search (<<1>>)")
mkstr("NAVIGATOR_OPENTAB","Open Navigator tab (on Map screen)")
-- mkstr("SI_BINDING_NAME_NAVIGATOR_SEARCH", "Open Map Navigator")

mkstr("NAVIGATOR_TAB_SEARCH","Navigator") -- Name of the tab on the World Map

mkstr("NAVIGATOR_KEYBIND_SEARCH", "Search")

mkstr("NAVIGATOR_CATEGORY_RESULTS", "Results")
mkstr("NAVIGATOR_CATEGORY_BOOKMARKS", "Bookmarks")
mkstr("NAVIGATOR_CATEGORY_RECENT", "Recent")
mkstr("NAVIGATOR_CATEGORY_ZONES", "Zones")

mkstr("NAVIGATOR_DUNGEON", "Dungeon")
mkstr("NAVIGATOR_TRIAL", "Trial")
mkstr("NAVIGATOR_ARENA", "Arena")

mkstr("NAVIGATOR_NOT_KNOWN", "Not known by this character")
mkstr("NAVIGATOR_NO_RECALL", "No players to recall to")
mkstr("NAVIGATOR_JUMP_TO_ZONE", "Jump to <<1>>")