local mkstr = function(id, str)
    SafeAddString(_G[id], str, 1)
end

mkstr("NAVIGATOR_SEARCH","Rechercher des lieux / zones / @joueurs")
mkstr("NAVIGATOR_SEARCH_KEYPRESS", "Rechercher (<<1>>)")

mkstr("NAVIGATOR_KEYBIND_SEARCH", "Rechercher")

mkstr("NAVIGATOR_CATEGORY_RESULTS", "Résultats")
mkstr("NAVIGATOR_CATEGORY_BOOKMARKS", "Signets")
mkstr("NAVIGATOR_CATEGORY_RECENT", "Récents")
mkstr("NAVIGATOR_CATEGORY_ZONES", "Zones")

mkstr("NAVIGATOR_DUNGEON", "Donjon")
mkstr("NAVIGATOR_TRIAL", "Épreuve")
mkstr("NAVIGATOR_ARENA", "Arène")
