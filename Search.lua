local Search = MapSearch.Search or {}
local MS = MapSearch
local Utils = MS.Utils
local Locations = MS.Locations
local logger = MS.logger -- LibDebugLogger("MapSearch")
local colors = MS.ansicolors
local fzy = MS.fzy

Search.categories = nil

FILTER_TYPE_NONE = 0    -- filter = { FILTER_TYPE_NONE }
FILTER_TYPE_PLAYERS = 1 -- filter = { FILTER_TYPE_PLAYERS }
FILTER_TYPE_ZONES = 2   -- filter = { FILTER_TYPE_ZONES }
FILTER_TYPE_ZONE = 3    -- filter = { FILTER_TYPE_ZONE, 'Grahtwood' }
FILTER_TYPE_HOUSES = 4   -- filter = { FILTER_TYPE_HOUSES }

local function match(object, searchTerm)
    local name = object.barename or object.name

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

            if MS.isDeveloper then
                -- resultNode.name = resultNode.name .. " |c808080[" .. resultNode.match .. "]|r"
                resultNode.tooltip = "nodeIndex " .. (resultNode.nodeIndex or "-") .. "; bareName '" .. (node.barename or '-')
            end

            table.insert(result, resultNode)
        end
    end
end


function Search.run(searchTerm, filter)
    local filterType = filter[1]
    searchTerm = searchTerm and searchTerm:lower() or ""
    searchTerm = searchTerm:gsub("[^%w ]", "")

    logger:Debug(string.format("Search.run('%s', %d)", searchTerm, filterType))

    if filterType == FILTER_TYPE_NONE and searchTerm == "" then
        return {}
    end

    local result = {}

    if filterType == FILTER_TYPE_PLAYERS then
        addSearchResults(result, searchTerm, Locations:getPlayerList())
    elseif filterType == FILTER_TYPE_ZONES then
        addSearchResults(result, searchTerm, Locations:getZoneList())
    elseif filterType == FILTER_TYPE_HOUSES then
        addSearchResults(result, searchTerm, Locations:getHouseList())
    elseif filterType == FILTER_TYPE_ZONE then
        local zoneId = filter[2]
        addSearchResults(result, searchTerm, Locations:getKnownNodes(zoneId))
        if MS.isRecall then
            local playerInfo = Locations:getPlayerInZone(zoneId)
            if playerInfo then
                playerInfo.name = "Jump to player"
            else
                playerInfo = {
                    name = "No players to recall to",
                    barename = "",
                    zoneId = zoneId,
                    zoneName = GetZoneNameById(zoneId),
                    icon = "/esoui/art/crafting/crafting_smithing_notrait.dds",
                    poiType = POI_TYPE_NONE,
                    known = true
                }
                end
            playerInfo.weight = 10.0 -- list this first!
            addSearchResults(result, searchTerm, { playerInfo })
        end
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