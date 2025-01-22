local Search = MapSearch.Search or {}
local MS = MapSearch
local Utils = MS.Utils
local Locations = MS.Locations
local logger = MS.logger -- LibDebugLogger("MapSearch")
local colors = MS.ansicolors
local fzy = MS.fzy

Search.categories = nil

MS.FILTER_NONE = 0
MS.FILTER_PLAYERS = 1
MS.FILTER_HOUSES = 4

local function match(object, searchTerm)
    local name = Utils.SearchName(object.name) -- object.barename or object.name

    local result = fzy.filter(searchTerm, {name})

    if #result >= 1 then
        return result[1][3] -- result[1][3], result[1][2]
    else
        return 0
    end
end

local function matchComparison(x,y)
    if x.match ~= y.match then
        return x.match > y.match
    end
	return (x.barename or x.name) < (y.barename or y.name)
end

local function addSearchResults(result, searchTerm, nodeList)
    for i = 1, #nodeList do
        local node = nodeList[i]
        local matchLevel = searchTerm ~= "" and match(node, searchTerm) or 1.0
        if matchLevel > 0 then
            local resultNode = Utils.shallowCopy(node)
            if node.weight then
                matchLevel = matchLevel * node.weight
            end
            resultNode.match = matchLevel
            -- resultNode.matchChars = matchChars

            table.insert(result, resultNode)
        end
    end
end


function Search.run(searchTerm, filter)
    searchTerm = searchTerm and string.lower(searchTerm) or ""
    searchTerm = searchTerm:gsub("[^%w ]", "")

    -- MS.log("Search.run('%s', %d)", searchTerm, filter)

    if filter == MS.FILTER_NONE and searchTerm == "" then
        return {}
    end

    local result = {}

    if filter == MS.FILTER_PLAYERS then
        addSearchResults(result, searchTerm, Locations:getPlayerList())
    elseif filter == MS.FILTER_HOUSES then
        addSearchResults(result, searchTerm, Locations:getHouseList())
    else
        addSearchResults(result, searchTerm, Locations:getKnownNodes())
        addSearchResults(result, searchTerm, Locations:getZoneList())
    end

    table.sort(result, matchComparison)

    Search.result = result
    return result
end
  
function Search.highlightResult(result, matchChars)
    local out = ""
    for i = 1, #result do
        local c = result:sub(i, i)
        if Utils.tableContains(matchChars, i) then
            if MapSearch.isCLI then
                out = out..'%{underline}'..c..'%{reset}'
            else
                out = out..c
            end
        else
            out = out..c
        end
    end
    return colors(out)
end

MapSearch.Search = Search