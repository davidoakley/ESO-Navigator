local Utils = MapSearch.Utils or {}

local _lang

local function CurrentLanguage()
	if _lang == nil then 
		_lang = GetCVar("language.2")
		_lang = string.lower(_lang)
	end 
	return _lang
end

CurrentLanguage()

function Utils.shortName(name)
	local r = name
	if _lang == "fr" then
		r = r:gsub("^Oratoire ", "O. ", 1)
	elseif _lang == "de" then
		r = r:gsub("Wegschrein ", "WS ", 1)
	elseif _lang == "ru" then
		r = r:gsub("^Дорожное святилище ", "ДС ", 1)
	end
	return r
end

function Utils.bareName(name)
	local r = Utils.shortName(name)
	if _lang == "en" then
		r = r:gsub("^Dungeon: ", "", 1):gsub("^Trial: ", "", 1):gsub("^The ", "", 1)
	elseif _lang == "fr" then
		r = r:gsub("^O. ", "", 1):gsub("^Donjon.-:.", "", 1):gsub("^Épreuve.-:.", "", 1)
		r = r:gsub("^d'", "", 1):gsub("^des ", "", 1):gsub("^de ", "", 1):gsub("^du ", "", 1)
		r = r:gsub("^la ", "", 1):gsub("^l' ", "", 1)
	elseif _lang == "de" then
		r = r:gsub("WS ", "", 1):gsub("^am ", "", 1):gsub("^bei ", "", 1)
		r = r:gsub("^von ", "", 1):gsub("^der ", "", 1):gsub("^des ", "", 1)
	elseif _lang == "ru" then
		r = r:gsub("ДС ", "", 1):gsub("^Подземелье: ", "", 1):gsub("^Испытание: ", "", 1)
	end

	r = r:lower()

	r = r:gsub("-", " ")
	r = r:gsub("[^%w ]", "")
	return r
end

function Utils.SearchName(name)
	local r = name --Utils.shortName(name)
	if _lang == "en" then
		r = r:gsub("^Dungeon: ", "", 1):gsub("^Trial: ", "", 1)
		-- r = r:gsub("^The ", "", 1)
	elseif _lang == "fr" then
		r = r:gsub("^Oratoire. ", "", 1):gsub("^Donjon.-:.", "", 1):gsub("^Épreuve.-:.", "", 1)
		-- r = r:gsub("^d'", "", 1):gsub("^des ", "", 1):gsub("^de ", "", 1):gsub("^du ", "", 1)
		-- r = r:gsub("^la ", "", 1):gsub("^l' ", "", 1)
	elseif _lang == "de" then
		r = r:gsub("Wegschrein ", "", 1)
		-- r = r:gsub("^am ", "", 1):gsub("^bei ", "", 1)
		-- r = r:gsub("^von ", "", 1):gsub("^der ", "", 1):gsub("^des ", "", 1)
	elseif _lang == "ru" then
		r = r:gsub("Дорожное святилище ", "", 1):gsub("^Подземелье: ", "", 1):gsub("^Испытание: ", "", 1)
	end

	r = r:gsub(" II$", " II 2", 1):gsub(" I$", " I 1", 1)

	-- r = r:lower()

	-- r = r:gsub("-", " ")
	-- r = r:gsub("[^%w ]", "")
	return r
end

function Utils.shallowCopy(t)
    local t2 = {}
    for k,v in pairs(t) do
      t2[k] = v
    end
    return t2
end

function Utils.deepCopy(obj)
    if type(obj) ~= 'table' then return obj end
    local res = {}
    for k, v in pairs(obj) do res[Utils.deepCopy(k)] = Utils.deepCopy(v) end
    return res
end

function Utils.tableContains(table, element)
    for _, value in pairs(table) do
      if value == element then
        return true
      end
    end
    return false
end

MapSearch.Utils = Utils