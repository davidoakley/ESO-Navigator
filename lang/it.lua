local mkstr = Navigator.mkstr

-- Controls menu entry (opens the Navigator tab on the World Map)
mkstr("SI_BINDING_NAME_NAVIGATOR_SEARCH", "Apri mappa")

-- Name of the tab on the World Map
mkstr("NAVIGATOR_TAB_SEARCH","Navigator")

-- Shown on the bottom keybind bar


-- Edit box hint text (<<1>> is replaced by 'Tab')
mkstr("NAVIGATOR_SEARCH_KEYPRESS","Cerca (<<1>>)")
mkstr("NAVIGATOR_SEARCH","Cerca luogo, zona or @player")

-- Category Headings
mkstr("NAVIGATOR_CATEGORY_BOOKMARKS", "Preferiti")
mkstr("NAVIGATOR_CATEGORY_RECENT", "Recenti")
mkstr("NAVIGATOR_CATEGORY_ZONES", "Zone")




-- Result hints
mkstr("NAVIGATOR_HINT_NORESULTS", "Nessun risulato")
mkstr("NAVIGATOR_HINT_NORECENTS", "Le destinazioni a cui hai viaggiato appariranno qui")
mkstr("NAVIGATOR_HINT_NOBOOKMARKS", "Pulsante destro del mouse su una destinazione per aggiungrere (o rimuovere) ai preferiti")
mkstr("NAVIGATOR_HINT_SHOWUNDISCOVERED", "Clicca per mostrare posizione sconosciute")

-- Enter key label (keep it short!)
mkstr("NAVIGATOR_KEY_ENTER", "Invio")

-- Result types




-- Tooltips
mkstr("NAVIGATOR_NOT_KNOWN", "Non conosciuto da questo personaggio") -- Location not known
mkstr("NAVIGATOR_TIP_CLICK_TO_TRAVEL", "Premi per viaggiare a <<1>>") -- 1:zone/destination
mkstr("NAVIGATOR_TIP_DOUBLECLICK_TO_TRAVEL", "Doppio-click per viaggiare a <<1>>") -- 1:zone/destination

-- Action and menu items
mkstr("NAVIGATOR_TRAVEL_TO_ZONE", "Viaggia a <<1>>")
mkstr("NAVIGATOR_MENU_ADDBOOKMARK", "Aggiungi preferiti")
mkstr("NAVIGATOR_MENU_ADDHOUSEBOOKMARK", "Aggiungi residenza principale ai preferiti")
mkstr("NAVIGATOR_MENU_REMOVEBOOKMARK", "Rimuovi preferito")
mkstr("NAVIGATOR_MENU_MOVEBOOKMARKUP", "Sposta su")
mkstr("NAVIGATOR_MENU_MOVEBOOKMARKDOWN", "Sposta giù")



-- Status / error messages
mkstr("NAVIGATOR_NO_TRAVEL_PLAYER", "Nessun giocatore disponibile per il viaggio")
mkstr("NAVIGATOR_CANNOT_TRAVEL_TO_PLAYER", "Impossibile viaggiare da <<1>>") -- 1:player
mkstr("NAVIGATOR_NO_PLAYER_IN_ZONE", "Impossibile trovare un giocatore a cui viaggiare in <<1>>") -- 1:zone
mkstr("NAVIGATOR_PLAYER_NOT_IN_ZONE", "<<1>> non è più in <<2>>") -- 1:player 2:zone
mkstr("NAVIGATOR_TRAVELING_TO_LOCATION", "In viaggio verso <<1>>") -- 1:location
mkstr("NAVIGATOR_RECALLING_TO_LOCATION_COST", "Richiamo a <<1>> usando <<2>>") -- 1:location 2:cost
mkstr("NAVIGATOR_TRAVELING_TO_ZONE_VIA_PLAYER", "In viaggio verso <<1>> via <<2>>") -- 1:zone 2:player
mkstr("NAVIGATOR_TRAVELING_TO_PLAYER_IN_ZONE", "In viaggio verso <<1>> in <<2>>") -- 1:player 2:zone
mkstr("NAVIGATOR_TRAVELING_TO_HOUSE_INSIDE", "In viaggio verso <<1>> (interno)") -- 1:house
mkstr("NAVIGATOR_TRAVELING_TO_HOUSE_OUTSIDE", "In viaggio verso <<1>> (esterno)") -- 1:house
mkstr("NAVIGATOR_TRAVELING_TO_PLAYER_HOUSE", "In viaggio verso casa <<gu:1>>") -- 1:house

-- Chat slash command
mkstr("NAVIGATOR_SLASH_DESCRIPTION", "Navigator: Teletrasporto verso la zona, la wayshrine, la casa o il giocatore indicato")

-- Custom location names
mkstr("NAVIGATOR_LOCATION_OBLIVIONPORTAL", "Portale per Oblivion")


-- Notes: "^Thing" matches "Thing" at the start of a name
--        "Thing$" matches "Thing" at the end of a name
function Navigator.DisplayName(name)
    name = name:gsub("^Dungeon: ", "")
    name = name:gsub("^Trial: ", "")
    name = name:gsub("^Prova: ", "")
    name = name:gsub("^Santuario della ", "La ")
    name = name:gsub("^Santuario delle ", "Le ")
    name = name:gsub("^Santuario dell'", "L'")
    name = name:gsub("^Santuario di ", "")
    name = name:gsub("^Santuario del ", "")
    return name
end
function Navigator.SearchName(name)
    name = name:gsub("^Dungeon: ", "")
    name = name:gsub("^Trial: ", "")
    name = name:gsub("^Prova: ", "")
    name = name:gsub("^Santuario della ", "La ")
    name = name:gsub("^Santuario delle ", "Le ")
    name = name:gsub("^Santuario dell'", "L'")
    name = name:gsub("^Santuario di ", "")
    name = name:gsub("^Santuario del ", "")
    name = name:gsub(" II$", " II 2", 1):gsub(" I$", " I 1", 1) -- Allows searches like COA2 (for City of Ash II)
    return name
end
