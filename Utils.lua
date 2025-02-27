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

local accents

if _lang == "ru" then
	accents = {
		-- Russian - see https://github.com/anyascii/anyascii/blob/master/input/tables/cyrillic.tsv
		["А"] = "A",
		["Б"] = "B",
		["В"] = "V",
		["Г"] = "G",
		["Д"] = "D",
		["д"] = "d",
		["Е"] = "E",
		["Ё"] = "E",
		["Ж"] = "Zh",
		["З"] = "Z",
		["И"] = "I",
		["Й"] = "Y",
		["К"] = "K",
		["Л"] = "L",
		["М"] = "M",
		["Н"] = "N",
		["О"] = "O",
		["П"] = "P",
		["Р"] = "R",
		["С"] = "S",
		["Т"] = "T",
		["У"] = "U",
		["Ф"] = "F",
		["Х"] = "Kh",
		["Ц"] = "Ts",
		["Ч"] = "Ch",
		["Ш"] = "Sh",
		["Щ"] = "Shch",
		["Ъ"] = "'",
		["Ы"] = "Y",
		["Ь"] = "'",
		["Э"] = "E",
		["Ю"] = "Yu",
		["Я"] = "Ya",
	}
else
	accents = {
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
end

function Utils.SimplifyAccents(str)
	if (not str) or (str == "") then return str end
	-- str = zo_strgsub(str, "[%z\1-\127\194-\244][\128-\191]*", tableAccents)
	for k, v in pairs(accents) do
		str = string.gsub(str, k, v)
	end
	return str
end

function Utils.trim(s)
	s = string.gsub(s, "^%s*(.-)%s*$", "%1")
	return s
end

function Utils.tableConcat(t1, t2)
	for i=1,#t2 do
		t1[#t1+1] = t2[i]
	end
	return t1
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

function Utils.shallowCopy(t)
	if type(t) == "table" then
		local t2 = {}
		for k,v in pairs(t) do
			t2[k] = v
		end
		setmetatable(t2, Utils.shallowCopy(getmetatable(t)))
		return t2
	else
		return t
	end
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

function Utils.logChars(s)
	--local s = "Épreuve" -- "Дорожное святилище"
	local chars = {}
	for c in string.gmatch(s, ".") do
		table.insert(chars, c:byte())
	end
	--for c in s:gmatch("[\0-\x7F\xC2-\xF4][\x80-\xBF]*") do
	--	table.insert(chars, c)
	--end
	Nav.log("UNICODE: '%s' -> '%s'", s, table.concat(chars, '|'))
end

Nav.Utils = Utils