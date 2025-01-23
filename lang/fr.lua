local mkstr = function(id, str)
    SafeAddString(_G[id], str, 1)
end

-- Shown on the bottom keybind bar
mkstr("NAVIGATOR_KEYBIND_SEARCH", "Rechercher")

-- Edit box hint text (<<1>> is replaced by 'Tab')
mkstr("NAVIGATOR_SEARCH","Rechercher des lieux / zones / @joueurs")
mkstr("NAVIGATOR_SEARCH_KEYPRESS", "Rechercher (<<1>>)")

-- Category Headings
mkstr("NAVIGATOR_CATEGORY_RESULTS", "Résultats")
mkstr("NAVIGATOR_CATEGORY_BOOKMARKS", "Signets")
mkstr("NAVIGATOR_CATEGORY_RECENT", "Récents")
mkstr("NAVIGATOR_CATEGORY_ZONES", "Zones")

-- Enter key label (keep it short!)
mkstr("NAVIGATOR_KEY_ENTER", "Entrée")

-- Result types
mkstr("NAVIGATOR_DUNGEON", "Donjon")
mkstr("NAVIGATOR_TRIAL", "Épreuve")
mkstr("NAVIGATOR_ARENA", "Arène")

-- Tooltips
-- mkstr("NAVIGATOR_NOT_KNOWN", "Not known by this character")

-- Actions
-- mkstr("NAVIGATOR_NO_TRAVEL_PLAYER", "No players to travel to")
mkstr("NAVIGATOR_TRAVEL_TO_ZONE", "Se rendre à <<1>>")

-- Chat box output
-- mkstr("NAVIGATOR_NO_PLAYER_IN_ZONE", "Failed to find a player to travel to in <<1>>")
-- mkstr("NAVIGATOR_PLAYER_NOT_IN_ZONE", "<<1>> is no longer in <<2>>")
-- mkstr("NAVIGATOR_TRAVELING_TO_ZONE_VIA_PLAYER", "Traveling to <<1>> via <<2>>")

-- Chat slash command
-- mkstr("NAVIGATOR_SLASH_DESCRIPTION", "Navigator: Teleports to the given zone, wayshrine, house or player")