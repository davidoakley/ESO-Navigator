local mkstr = Navigator.mkstr

-- Controls menu entry (opens the Navigator tab on the World Map)
-- mkstr("SI_BINDING_NAME_NAVIGATOR_SEARCH", "Open on World Map")
--mkstr("SI_BINDING_NAME_NAVIGATOR_FOCUSSEARCH", "Search (on World Map)")







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
--mkstr("NAVIGATOR_TOOLTIP_GUILDTRADERS", "<<1[/1 Guild Trader nearby/$d Guild Traders nearby]>>")
mkstr("NAVIGATOR_TOOLTIP_VIEWMENU", "Passer à des Vues alternatives")
mkstr("NAVIGATOR_TOOLTIP_CLEARVIEW", "Passer à des Vues alternatives\nCliquer avec le bouton droit pour effacer l'affichage")

-- Actions items
mkstr("NAVIGATOR_TRAVEL_TO_ZONE", "Se rendre à <<1>>") -- 1:Zone
--mkstr("NAVIGATOR_MENU_ADDBOOKMARK", "Add Bookmark")
--mkstr("NAVIGATOR_MENU_ADDHOUSEBOOKMARK", "Add Primary Residence Bookmark")
--mkstr("NAVIGATOR_MENU_REMOVEBOOKMARK", "Remove Bookmark")
--mkstr("NAVIGATOR_MENU_MOVEBOOKMARKUP", "Move Bookmark up")
--mkstr("NAVIGATOR_MENU_MOVEBOOKMARKDOWN", "Move Bookmark down")
mkstr("NAVIGATOR_MENU_PLAYERS", "Joueurs")
mkstr("NAVIGATOR_MENU_GUILDTRADERS", "Marchands de guilde")
mkstr("NAVIGATOR_MENU_TREASUREMAPS_SURVEYS", "Carte au trésor & Repérages")
--mkstr("NAVIGATOR_MENU_CLEARVIEW", "Clear view")



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

-- Add-on Settings
--mkstr("NAVIGATOR_SETTINGS_DEFAULT_TAB_NAME",                "Auto-select Navigator tab")
--mkstr("NAVIGATOR_SETTINGS_DEFAULT_TAB_TOOLTIP",             "Automatically selects the Navigator tab when the Maps screen is opened.")
--mkstr("NAVIGATOR_SETTINGS_DEFAULT_TAB_WARNING",             "Navigator cannot auto-select its tab when the |c99FFFFFaster Travel|r addon is also enabled")

--mkstr("NAVIGATOR_SETTINGS_RECENT_COUNT_NAME",               "Entries in Recent list")
--mkstr("NAVIGATOR_SETTINGS_RECENT_COUNT_TOOLTIP",            "Setting this to 0 will disable the Recent list")

--mkstr("NAVIGATOR_SETTINGS_CONFIRM_FAST_TRAVEL_NAME",        "Confirm fast travel")
--mkstr("NAVIGATOR_SETTINGS_CONFIRM_FAST_TRAVEL_TOOLTIP",     "Whether/when to show the standard alert prompt when jumping to a wayshrine. Only affects Navigator, not the World Map")
mkstr("NAVIGATOR_SETTINGS_CONFIRM_FAST_TRAVEL_CHOICE_1",    "Toujours")
--mkstr("NAVIGATOR_SETTINGS_CONFIRM_FAST_TRAVEL_CHOICE_2",    "When costs <<1>>") --  1:goldicon
mkstr("NAVIGATOR_SETTINGS_CONFIRM_FAST_TRAVEL_CHOICE_3",    "Jamais")

--mkstr("NAVIGATOR_SETTINGS_LIST_POI_NAME",                   "Show Points Of Interest on the zone list")
--mkstr("NAVIGATOR_SETTINGS_LIST_POI_TOOLTIP",                "If this is disabled, only \"destinations\" such as wayshrines, dungeons, houses or players will be listed")

--mkstr("NAVIGATOR_SETTINGS_INCLUDE_UNDISCOVERED_NAME",       "Show and search undiscovered locations")
--mkstr("NAVIGATOR_SETTINGS_INCLUDE_UNDISCOVERED_TOOLTIP",    "List undiscovered locations and show them in search results")

--mkstr("NAVIGATOR_SETTINGS_USE_HOUSE_NICKNAME_NAME",         "Show and search house nicknames")

--mkstr("NAVIGATOR_SETTINGS_AUTO_FOCUS_NAME",                 "Auto-focus Search box")
--mkstr("NAVIGATOR_SETTINGS_AUTO_FOCUS_TOOLTIP",              "Automatically puts the cursor in the search box when the tab is selected. This means that the 'M' key can't be used to exit the map; use 'Escape' instead.")
--mkstr("NAVIGATOR_SETTINGS_AUTO_FOCUS_WARNING",              "When active, the 'M' key can't be used to immediately exit the map; use 'Escape' instead.")

--mkstr("NAVIGATOR_SETTINGS_CHAT_COMMAND_NAME",               "Chat command")
--mkstr("NAVIGATOR_SETTINGS_CHAT_COMMAND_TOOLTIP",            "Select what name to give the chat slash command")
--mkstr("NAVIGATOR_SETTINGS_CHAT_COMMAND_CHOICE_1",           "None") -- Chat command is disabled
--mkstr("NAVIGATOR_SETTINGS_CHAT_COMMAND_WARNING",            "|c8080FFPithka's Achievement Tracker|r has its teleport command enabled, which also uses '/tp'")
--mkstr("NAVIGATOR_SETTINGS_CHAT_COMMAND_UNAVAILABLE",        "|cFFFF00|t24:24:/esoui/art/miscellaneous/eso_icon_warning.dds:inheritcolor|t|r Navigator's chat command is only available if the |c99FFFFLibSlashCommander|r add-on is installed and enabled")

--mkstr("NAVIGATOR_SETTINGS_ACTIONS_NAME",                    "Mouse click and Enter button actions")
--mkstr("NAVIGATOR_SETTINGS_ACTIONS_SINGLE_CLICK",             "Single-click")
--mkstr("NAVIGATOR_SETTINGS_ACTIONS_DOUBLE_CLICK",            "Double-click")
--mkstr("NAVIGATOR_SETTINGS_ACTIONS_ENTER_KEY",               "[Enter] key")

mkstr("NAVIGATOR_SETTINGS_ACTIONS_CHOICE_SET_DESTINATION",  "Marquer destination")


--mkstr("NAVIGATOR_SETTINGS_DESTINATION_ACTIONS_NAME",        "Travel Destinations")
--mkstr("NAVIGATOR_SETTINGS_DESTINATION_ACTIONS_TOOLTIP",     "Mouse and key actions for Wayshrines, Dungeons, Trials, Arenas and Keeps")
--mkstr("NAVIGATOR_SETTINGS_DESTINATION_ACTIONS_WARNING",     "If a single-click is set to Travel, the double-click action will not run")

mkstr("NAVIGATOR_SETTINGS_ZONE_ACTIONS_NAME",               "Zones")
--mkstr("NAVIGATOR_SETTINGS_ZONE_ACTIONS_TOOLTIP",            "Mouse and key actions for zones")


--mkstr("NAVIGATOR_SETTINGS_HOUSE_ACTIONS_TOOLTIP",           "Mouse and key actions for your houses")


--mkstr("NAVIGATOR_SETTINGS_POI_ACTIONS_TOOLTIP",             "Mouse and key actions for map locations such as towns, quest locations and striking locales")

--mkstr("NAVIGATOR_SETTINGS_JOIN_GUILD_NAME",                 "Join our guild!")
--mkstr("NAVIGATOR_SETTINGS_JOIN_GUILD_DESCRIPTION",          "|cC5C29E|H1:guild:767808|hMora's Whispers|h is a vibrant social lair with a free trader, loads of events, weekly raffles, fully equipped guild base, active Discord and so forth! Hit the link above to find out more!|r")


-- -----------------------------------------------------------------------------
-- Notes: gsub uses Lua patterns - https://www.lua.org/pil/20.2.html
--        "^Thing" matches "Thing" at the start of a name
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
