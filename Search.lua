local Search = MapSearch.Search or {}
local MS = MapSearch
local Utils = MS.Utils
local Locations = MS.Locations
local logger = MS.logger -- LibDebugLogger("MapSearch")
local colors = MS.ansicolors
local fzy = MS.fzy

Search.categories = nil

POI_TYPE_TRIAL = 100
POI_TYPE_ARENA = 101

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

local function runCombined(searchTerm)
    searchTerm = searchTerm:lower()
    searchTerm = searchTerm:gsub("[^%w ]", "")

    -- logger:Info("Search.run("..searchTerm..")")

    local result = {}
    local nodes = Locations:getKnownNodes()

    for i = 1, #nodes do
        local node = nodes[i]
        local matchLevel, matchChars = match(node, searchTerm)
        if matchLevel > 0 then
            local resultNode = Utils.shallowCopy(node)
            resultNode.match = matchLevel
            resultNode.matchChars = matchChars

            if MS.isDeveloper then
                -- resultNode.name = resultNode.name .. " |c808080[" .. resultNode.match .. "]|"
                resultNode.tooltip = "nodeIndex " .. resultNode.nodeIndex
            end

            table.insert(result, resultNode)
        end
    end

    table.sort(result, matchComparison)

    Search.result = result
    return result
end
  
local function highlightResult(result, matchChars)
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

Search.run = runCombined
Search.highlightResult = highlightResult

MapSearch.Search = Search