local Nav = Navigator
local Search = Nav.Search or {}
local Utils = Nav.Utils
local Locations = Nav.Locations
local colors = Nav.ansicolors
local fzy = Nav.fzy

Search.categories = nil

Nav.FILTER_NONE = 0
Nav.FILTER_PLAYERS = 1
Nav.FILTER_HOUSES = 4

local function match(object, searchTerm)
    local name = Utils.SearchName(object.originalName or object.name) -- object.barename or object.name
    searchTerm = Utils.removeAccents(searchTerm)

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

    -- Nav.log("Search.run('%s', %d)", searchTerm, filter)

    if filter == Nav.FILTER_NONE and searchTerm == "" then
        return {}
    end

    local result = {}

    if filter == Nav.FILTER_PLAYERS then
        addSearchResults(result, searchTerm, Nav.Players:GetPlayerList())
    elseif filter == Nav.FILTER_HOUSES then
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
            if Nav.isCLI then
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

Nav.Search = Search