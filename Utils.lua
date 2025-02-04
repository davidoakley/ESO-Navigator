local Nav = Navigator
local Utils = Nav.Utils or {}

local _lang

local function CurrentLanguage()
	if _lang == nil then 
		_lang = GetCVar("language.2")
		_lang = string.lower(_lang)
	end 
	return _lang
end

CurrentLanguage()

local accents = {
	["à"] = "a",
	["á"] = "a",
	["â"] = "a",
	["ã"] = "a",
	["ä"] = "a",
	["å"] = "a",
	["ą"] = "a",

	["ß"] = "ss",

	["ĥ"] = "h",

	["ç"] = "c",
	["æ"] = "ae",

	["è"] = "e",
	["é"] = "e",
	["ê"] = "e",
	["ë"] = "e",
	["ę"] = "e",

	["ì"] = "i",
	["í"] = "i",
	["î"] = "i",
	["ï"] = "i",
	["ı"] = "i",
	["į"] = "i",

	["ł"] = "l",

	["ñ"] = "n",

	-- ["ð"] = "d",
	["š"] = "s",

	["þ"] = "p",

	["ò"] = "o",
	["ó"] = "o",
	["ô"] = "o",
	["õ"] = "o",
	["ö"] = "o",
	["ō"] = "o",
	["ð"] = "o",
	["ø"] = "o",
	["ǫ"] = "o",

	["ẅ"] = "w",

	["ş"] = "s",
	-- ["š"] = "s",

	["ù"] = "u",
	["ú"] = "u",
	["û"] = "u",
	["ü"] = "u",
	["ų"] = "u",

	["ý"] = "y",
	["ÿ"] = "y",
	["ŷ"] = "y",


	["À"] = "A",
	["Á"] = "A",
	["Â"] = "A",
	["Ã"] = "A",
	["Ä"] = "A",
	["Å"] = "A",
	["Ą"] = "A",

	["ẞ"] = "B",

	["Ĥ"] = "H",

	["Ç"] = "C",
	["Æ"] = "Ae",

	["È"] = "E",
	["É"] = "E",
	["Ê"] = "E",
	["Ë"] = "E",
	["Ę"] = "E",

	["Ì"] = "I",
	["Í"] = "I",
	["Î"] = "I",
	["Ï"] = "I",
	["Į"] = "I",

	["Ł"] = "L",

	["Ñ"] = "N",

	["Ð"] = "D",
	["Š"] = "S",
	["Ş"] = "S",

	["Þ"] = "P",

	["Ò"] = "O",
	["Ó"] = "O",
	["Ô"] = "O",
	["Õ"] = "O",
	["Ö"] = "O",
	["Ø"] = "O",
	["Ǫ"] = "O",

	["Ẅ"] = "W",

	["Ù"] = "U",
	["Ú"] = "U",
	["Û"] = "U",
	["Ü"] = "U",
	["Ų"] = "U",

	["Ý"] = "Y",
	["Ÿ"] = "Y",
	["Ŷ"] = "Y",
}

function Utils.removeAccents(str)
	if (not str) or (str == "") then return str end
	-- str = zo_strgsub(str, "[%z\1-\127\194-\244][\128-\191]*", tableAccents)
	for k, v in pairs(accents) do
		str = zo_strgsub(str, k, v)
	end
	return str
end

function Utils.trim(s)
	s = string.gsub(s, "^%s*(.-)%s*$", "%1")
	return s
end

function Utils.FormatSimpleName(str)
	if str == nil or str == "" then return str end
	local lang = string.lower(CurrentLanguage())
	if lang == "en" then
		return str
	else
		return zo_strformat("<<!AC:1>>", str)
	end 
end 

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

function Utils.DisplayName(name)
	local r = name
	-- if _lang == "fr" then
	-- 	r = r:gsub("^Oratoire ", "O. ", 1)
	-- elseif _lang == "de" then
	-- 	r = r:gsub("Wegschrein ", "WS ", 1)
	-- elseif _lang == "ru" then
	-- 	r = r:gsub("^Дорожное святилище ", "ДС ", 1)
	-- end
	-- return r

	-- local r = name
	if _lang == "en" then
		r = r:gsub("^Dungeon: ", "", 1):gsub("^Trial: ", "", 1) --:gsub("^The ", "", 1)
		     :gsub(" Wayshrine$", "", 1)
	elseif _lang == "fr" then
		-- r = r:gsub("^oratoire de ", "", 1):gsub("^oratoire d'", "", 1)
		r = r:gsub("^Donjon.-:.", "", 1):gsub("^Épreuve.-:.", "", 1)
		-- r = r:gsub("^Oratoire ", "O. ", 1)
		r = r:gsub("^Oratoire de la ", "La ", 1):gsub("^Oratoire des ", "Les ", 1):gsub("^Oratoire du ", "Le ", 1)
		     :gsub("^Oratoire de ", "", 1):gsub("^Oratoire d'", "", 1)
	elseif _lang == "de" then
		r = r:gsub("Wegschrein ", "WS ", 1):gsub(" .Verlies.", "", 1):gsub(" .Prüfung.", "", 1)
	elseif _lang == "ru" then
		r = r:gsub("^Дорожное святилище ", "ДС ", 1)
	end
	return r
end

function Utils.bareName(name)
	local r = Utils.shortName(name)
	r = Utils.removeAccents(r)
	if _lang == "en" then
		r = r:gsub("^Dungeon: ", "", 1):gsub("^Trial: ", "", 1):gsub("^Arena: ", "", 1):gsub("^The ", "", 1)
		     :gsub(" Wayshrine$", "", 1):gsub(" Arena$", "", 1)
	elseif _lang == "fr" then
		r = r:gsub("\\^.*$", "", 1)
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
	local r = Utils.removeAccents(name) --Utils.shortName(name)
	if _lang == "en" then
		r = r:gsub("^Dungeon: ", "", 1):gsub("^Trial: ", "", 1)
		-- r = r:gsub("^The ", "", 1)
	elseif _lang == "fr" then
		r = r:gsub("^Oratoire du ", "", 1):gsub("^Oratoire de la ", "", 1):gsub("^Oratoire des ", "", 1)
		r = r:gsub("^Oratoire de ", "", 1):gsub("^Donjon.-:.", "", 1):gsub("^Épreuve.-:.", "", 1):gsub("^Epreuve.-:.", "", 1)
		-- r = r:gsub("^d'", "", 1):gsub("^des ", "", 1):gsub("^de ", "", 1):gsub("^du ", "", 1)
		-- r = r:gsub("^la ", "", 1):gsub("^l' ", "", 1)
	elseif _lang == "de" then
		r = r:gsub("Wegschrein ", "", 1):gsub(" \\(Verlies\\)", "", 1):gsub(" \\(Prüfung\\)", "", 1)
		r = r:gsub("^am ", "", 1):gsub("^bei ", "", 1)
		r = r:gsub("^von ", "", 1):gsub("^der ", "", 1):gsub("^des ", "", 1)
	elseif _lang == "ru" then
		r = r:gsub("Дорожное святилище ", "", 1):gsub("^Подземелье: ", "", 1):gsub("^Испытание: ", "", 1)
	end

	r = r:gsub(" II$", " II 2", 1):gsub(" I$", " I 1", 1)

	-- r = r:lower()

	-- r = r:gsub("-", " ")
	-- r = r:gsub("[^%w ]", "")
	return r
end

function Utils.SortName(obj)
	local name = type(obj) == "table" and obj.name or obj
	name = string.lower(Utils.DisplayName(name))
	name = Utils.removeAccents(name)

	if Nav.saved.ignoreDefiniteArticlesInSort then
		if _lang == "en" then
			name = name:gsub("^The ", "", 1)
		elseif _lang == "fr" then
			name = name:gsub("^le ", "", 1):gsub("^la ", "", 1):gsub("^l'", "", 1):gsub("^les ", "", 1)
		end
	end

	return Utils.trim(name)
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

Nav.Utils = Utils