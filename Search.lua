local Search = MapSearch.Search or {}
local MS = MapSearch
local Utils = MS.Utils
local Locations = MS.Locations
local logger = MS.logger -- LibDebugLogger("MapSearch")
local colors = MS.ansicolors
local fzy = MS.fzy

Search.categories = nil

local function match(object, searchTerm)
    local name = object.barename or object.name

    local result = fzy.filter(searchTerm, {name})

    if #result >= 1 then
        return result[1][3], result[1][2]
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
        local matchLevel, _ = match(node, searchTerm)
        if matchLevel > 0 or searchTerm == "" then
            local resultNode = Utils.shallowCopy(node)
            resultNode.match = matchLevel
            -- resultNode.matchChars = matchChars

            if MS.isDeveloper then
                -- resultNode.name = resultNode.name .. " |c808080[" .. resultNode.match .. "]|r"
                resultNode.tooltip = "nodeIndex " .. (resultNode.nodeIndex or "-") .. "; bareName '" .. (node.barename or '-')
            end

            table.insert(result, resultNode)
        end
    end
end


function Search.run(searchTerm)
    local searchType = 'loc'
    if searchTerm:sub(1, 1) == "@" then
        searchType = 'pla'
        searchTerm = searchTerm:sub(2)
    end
    searchTerm = searchTerm:lower()
    searchTerm = searchTerm:gsub("[^%w ]", "")

    -- logger:Info("Search.run("..searchTerm..")")

    local result = {}

    if searchType == 'pla' then
        logger:Info("Search.run: player '"..searchTerm.."'")
        addSearchResults(result, searchTerm, Locations:getPlayerList())
    else
        logger:Info("Search.run: location '"..string.sub(searchTerm, 1, 1).."'")
        addSearchResults(result, searchTerm, Locations:getKnownNodes())
        addSearchResults(result, searchTerm, Locations:getPlayerZoneList())
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