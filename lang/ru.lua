local mkstr = Navigator.mkstr

-- Controls menu entry (opens the Navigator tab on the World Map)
mkstr("SI_BINDING_NAME_NAVIGATOR_SEARCH", "Открыть карту мира")

-- Name of the tab on the World Map
mkstr("NAVIGATOR_TAB_SEARCH","Навигатор")




-- Edit box hint text (<<1>> is replaced by 'Tab')
mkstr("NAVIGATOR_SEARCH_KEYPRESS","Поиск (<<1>>)")
mkstr("NAVIGATOR_SEARCH","Название места, локации или @игрока")

-- Category Headings
mkstr("NAVIGATOR_CATEGORY_BOOKMARKS", "Закладки")
mkstr("NAVIGATOR_CATEGORY_RECENT", "Недавние")
mkstr("NAVIGATOR_CATEGORY_ZONES", "Локации")




-- Result hints
mkstr("NAVIGATOR_HINT_NORESULTS", "Результаты не найдены")
mkstr("NAVIGATOR_HINT_NORECENTS", "Здесь будут автоматически отображаться места, которые вы посещали недавно")
mkstr("NAVIGATOR_HINT_NOBOOKMARKS", "Нажмите правой кнопкой мыши по месту, чтобы создать (или удалить) закладку для него")
mkstr("NAVIGATOR_HINT_SHOWUNDISCOVERED", "Нажмите, чтобы отобразить неисследованные места")

-- Enter key label (keep it short!)
mkstr("NAVIGATOR_KEY_ENTER", "Enter")






-- Tooltips
mkstr("NAVIGATOR_NOT_KNOWN", "Не открыто этим персонажем") -- Location not known
mkstr("NAVIGATOR_TIP_DOUBLECLICK_TO_TRAVEL", "Щелкните дважды, чтобы переместиться в <<1>>") -- 1:zone

-- Action and menu items
mkstr("NAVIGATOR_TRAVEL_TO_ZONE", "Переместиться в <<1>>")
mkstr("NAVIGATOR_MENU_ADDBOOKMARK", "Добавить закладку")
mkstr("NAVIGATOR_MENU_ADDHOUSEBOOKMARK", "Добавить закладку основного дома")
mkstr("NAVIGATOR_MENU_REMOVEBOOKMARK", "Удалить закладку")
mkstr("NAVIGATOR_MENU_MOVEBOOKMARKUP", "Переместить закладку вверх")
mkstr("NAVIGATOR_MENU_MOVEBOOKMARKDOWN", "Переместить закладку вниз")



-- Status / error messages
mkstr("NAVIGATOR_NO_TRAVEL_PLAYER", "Нет игроков для перемещения")
mkstr("NAVIGATOR_CANNOT_TRAVEL_TO_PLAYER", "Невозможно переместиться к игроку <<1>>") -- 1:player
mkstr("NAVIGATOR_NO_PLAYER_IN_ZONE", "Не удалось найти игрока, к которому можно переместиться в локации <<1>>") -- 1:zone
mkstr("NAVIGATOR_PLAYER_NOT_IN_ZONE", "<<1>> больше не находится в <<2>>") -- 1:player 2:zone
mkstr("NAVIGATOR_TRAVELING_TO_LOCATION", "Перемещение в <<1>>") -- 1:location
mkstr("NAVIGATOR_RECALLING_TO_LOCATION_COST", "Перемещение в <<1>> за <<2>>") -- 1:location 2:cost
mkstr("NAVIGATOR_TRAVELING_TO_ZONE_VIA_PLAYER", "Перемещение в <<1>> к <<2>>") -- 1:zone 2:player
mkstr("NAVIGATOR_TRAVELING_TO_PLAYER_IN_ZONE", "Перемещение к <<1>> в <<2>>") -- 1:player 2:zone
mkstr("NAVIGATOR_TRAVELING_TO_HOUSE_INSIDE", "Перемещение в <<1>> (внутри)") -- 1:house
mkstr("NAVIGATOR_TRAVELING_TO_HOUSE_OUTSIDE", "Перемещение в <<1>> (снаружи)") -- 1:house
mkstr("NAVIGATOR_TRAVELING_TO_PLAYER_HOUSE", "Перемещение в дом <<gu:1>>") -- 1:house

-- Chat slash command
mkstr("NAVIGATOR_SLASH_DESCRIPTION", "Навигатор: Перемещение к указанной локации, дорожному святилищу, дому или игроку")

-- Custom location names
mkstr("NAVIGATOR_LOCATION_OBLIVIONPORTAL", "Портал Обливиона")

-- Notes: gsub uses Lua patterns - https://www.lua.org/pil/20.2.html
--        "^Thing" matches "Thing" at the start of a name
--        "Thing$" matches "Thing" at the end of a name
function Navigator.DisplayName(name)
    name = name:gsub("^Подземелье: ", "") -- Dungeon
    name = name:gsub("^Испытание: ", "") -- Trial
    name = name:gsub("^Дорожное святилище ", "") -- Wayshrine
    return name
end
function Navigator.SearchName(name)
    name = name:gsub("^Подземелье: ", "") -- Dungeon
    name = name:gsub("^Испытание: ", "") -- Trial
    name = name:gsub("^Дорожное святилище ", "") -- Wayshrine
    return name
end
