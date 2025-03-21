local mkstr = Navigator.mkstr

-- Controls menu entry (opens the Navigator tab on the World Map)
-- mkstr("SI_BINDING_NAME_NAVIGATOR_SEARCH", "Open on World Map")







-- Edit box hint text (<<1>> is replaced by 'Tab')
mkstr("NAVIGATOR_SEARCH_KEYPRESS", "Rechercher (<<1>>)") -- 1:Keyname
mkstr("NAVIGATOR_SEARCH","Rechercher des lieux / zones / @joueurs")

-- Category Headings
mkstr("NAVIGATOR_CATEGORY_BOOKMARKS", "Signets")
mkstr("NAVIGATOR_CATEGORY_RECENT", "Récente")
mkstr("NAVIGATOR_CATEGORY_ZONES", "Zones")




-- Result hints
--mkstr("NAVIGATOR_HINT_NORESULTS", "No results found")
--mkstr("NAVIGATOR_HINT_NORECENTS", "Destinations that you travel to will automatically appear here")
--mkstr("NAVIGATOR_HINT_NOBOOKMARKS", "Right click a destination to create (or delete) a bookmark for it")
--mkstr("NAVIGATOR_HINT_SHOWUNDISCOVERED", "Click to show undiscovered locations")

-- Enter key label (keep it short!)
mkstr("NAVIGATOR_KEY_ENTER", "Entrée")






-- Tooltips
mkstr("NAVIGATOR_NOT_KNOWN", "Non découvert par ce personnage") -- Location not known
mkstr("NAVIGATOR_TIP_CLICK_TO_TRAVEL", "Double-cliquez pour voyager à <<1>>") -- 1:zone
mkstr("NAVIGATOR_TIP_DOUBLECLICK_TO_TRAVEL", "Cliquez pour voyager à <<1>>") -- 1:zone
mkstr("NAVIGATOR_TOOLTIP_ACTION_RESULT", "<<1>> : <<2>>") -- e.g. 1:"Single-click" 2:"Show On Map"

-- Actions items
mkstr("NAVIGATOR_TRAVEL_TO_ZONE", "Se rendre à <<1>>") -- 1:Zone
--mkstr("NAVIGATOR_MENU_ADDBOOKMARK", "Add Bookmark")
--mkstr("NAVIGATOR_MENU_ADDHOUSEBOOKMARK", "Add Primary Residence Bookmark")
--mkstr("NAVIGATOR_MENU_REMOVEBOOKMARK", "Remove Bookmark")
--mkstr("NAVIGATOR_MENU_MOVEBOOKMARKUP", "Move Bookmark up")
--mkstr("NAVIGATOR_MENU_MOVEBOOKMARKDOWN", "Move Bookmark down")



-- Status / error messages
--mkstr("NAVIGATOR_NO_TRAVEL_PLAYER", "No players to travel to")
--mkstr("NAVIGATOR_CANNOT_TRAVEL_TO_PLAYER", "Unable to travel to player <<1>>") -- 1:player
--mkstr("NAVIGATOR_NO_PLAYER_IN_ZONE", "Failed to find a player to travel to in <<1>>") -- 1:zone
--mkstr("NAVIGATOR_PLAYER_NOT_IN_ZONE", "<<1>> is no longer in <<2>>") -- 1:player 2:zone
--mkstr("NAVIGATOR_TRAVELING_TO_LOCATION", "Traveling to <<1>>") -- 1:location
--mkstr("NAVIGATOR_RECALLING_TO_LOCATION_COST", "Recalling to <<1>> for <<2>>") -- 1:location 2:cost
--mkstr("NAVIGATOR_TRAVELING_TO_ZONE_VIA_PLAYER", "Traveling to <<1>> via <<2>>") -- 1:zone 2:player
--mkstr("NAVIGATOR_TRAVELING_TO_PLAYER_IN_ZONE", "Traveling to <<1>> in <<2>>") -- 1:player 2:zone
--mkstr("NAVIGATOR_TRAVELING_TO_HOUSE_INSIDE", "Traveling to <<1>> (inside)") -- 1:house
--mkstr("NAVIGATOR_TRAVELING_TO_HOUSE_OUTSIDE", "Traveling to <<1>> (outside)") -- 1:house
--mkstr("NAVIGATOR_TRAVELING_TO_PLAYER_HOUSE", "Traveling to <<gu:1>> house") -- 1:house

-- Chat slash command
-- mkstr("NAVIGATOR_SLASH_DESCRIPTION", "Navigator: Teleports to the given zone, wayshrine, house or player")

-- Custom location names
--mkstr("NAVIGATOR_LOCATION_OBLIVIONPORTAL", "Oblivion Portal")


-- Notes: "^Thing" matches "Thing" at the start of a name
--        "Thing$" matches "Thing" at the end of a name
function Navigator.DisplayName(name)
    name = name:gsub("^Donjon : ", "") -- note non-breaking space before colon!
    name = name:gsub("^Épreuve : ", "") -- note non-breaking space before colon!
    name = name:gsub("^Oratoire de la ", "La ")
    name = name:gsub("^Oratoire des ", "Les ")
    name = name:gsub("^Oratoire du ", "Le ")
    name = name:gsub("^Oratoire de l'", "L'")
    name = name:gsub("^Oratoire de ", "")
    name = name:gsub("^Oratoire d'", "")
    return name
end
function Navigator.SearchName(name)
    name = Navigator.Utils.SimplifyAccents(name) -- The search string is also "simplified"
    name = name:gsub("^Donjon : ", "") -- note non-breaking space before colon!
    name = name:gsub("^Épreuve : ", "") -- note non-breaking space before colon!
    name = name:gsub("^Oratoire de la ", "")
    name = name:gsub("^Oratoire des ", "")
    name = name:gsub("^Oratoire du ", "")
    name = name:gsub("^Oratoire de ", "")
    name = name:gsub("^Oratoire d'", "")
    name = name:gsub(" II$", " II 2", 1):gsub(" I$", " I 1", 1) -- Allows searches like COA2
    return name
end
