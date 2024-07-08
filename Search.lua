local Search = MapSearch.Search or {}
local Utils = MapSearch.Utils
local logger = MapSearch.logger -- LibDebugLogger("MapSearch")
local colors = MapSearch.ansicolors

-- https://github.com/swarn/fzy-lua/blob/main/docs/fzy.md
local fzy = MapSearch.fzy

Search.categories = nil

POI_TYPE_TRIAL = 100
POI_TYPE_ARENA = 101

local function deepCopy(obj)
    if type(obj) ~= 'table' then return obj end
    local res = {}
    for k, v in pairs(obj) do res[deepCopy(k)] = deepCopy(v) end
    return res
end

local function getZoneWayshrines(zoneIndex)
	local data = {}

	local iter = MapSearch.Wayshrine.GetKnownWayshrinesByZoneIndex(zoneIndex,-1)

	data = {}
	for i in iter do
        local node = deepCopy(i)
        if node.name:find("Dungeon: ") then
            node.poiType = POI_TYPE_GROUP_DUNGEON
            node.name = string.sub(node.name, 10, #node.name)
            node.icon = "esoui/art/icons/poi/poi_groupinstance_complete.dds"
        elseif node.name:find("Trial: ") then
            node.poiType = POI_TYPE_TRIAL
            node.name = string.sub(node.name, 8, #node.name)
            node.icon = "esoui/art/tutorial/poi_raiddungeon_complete.dds"
        elseif node.name:find(" Arena") then
            node.poiType = POI_TYPE_ARENA
            node.name = string.sub(node.name, 1, #node.name - 6)
            node.icon = "esoui/art/tutorial/poi_raiddungeon_complete.dds"
        elseif node.name:find(" Wayshrine") then
            node.poiType = POI_TYPE_WAYSHRINE
            node.name = string.sub(node.name, 1, #node.name - 10)
            node.icon = "esoui/art/icons/poi/poi_wayshrine_complete.dds"
        elseif node.textureName == "/esoui/art/icons/poi/poi_group_house_glow.dds" then
            node.poiType = POI_TYPE_HOUSE
            node.icon = "esoui/art/icons/poi/poi_group_house_owned.dds"
        end

        node.barename = Utils.BareName(node.name)

		table.insert(data, node)
	end

	return data
end

local function buildLocations()
    local locs = {}
    local zones = {}

	local locations = MapSearch.Location.Data.GetList()

	for i, map in ipairs(locations) do
		if map.zoneId ~= nil then
			-- print(" - "..map.zoneId.." - "..map.name)

            zones[map.zoneIndex] = deepCopy(map)
            zones[map.zoneIndex].nodes = nil
			-- table.sort(nodes, Utils.SortByBareName)
			-- map.nodes = nodes

			--categories[map.zoneIndex] = map
			-- table.insert(categories, map)
			local nodes = getZoneWayshrines(map.zoneIndex)
            for j, node in ipairs(nodes) do
                local l = node
                table.insert(locs, l)
            end
		end
	end

    Search.locations = locs
    Search.zones = zones

	return locations
end

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
    if Search.locations == nil then
        logger:Info("Search.run: building locations")
		buildLocations()
	end

    searchTerm = searchTerm:lower()
    searchTerm = searchTerm:gsub("[^%w ]", "")

    logger:Info("Search.run("..searchTerm..")")

    local result = {}

    for i, node in ipairs(Search.locations) do
        local matchLevel, matchChars = match(node, searchTerm)
        if matchLevel > 0 then
            local resultNode = deepCopy(node)
            resultNode.match = matchLevel
            resultNode.matchChars = matchChars
            table.insert(result, resultNode)
        end
    end

    table.sort(result, matchComparison)

    Search.result = result
    return result
end

function table.contains(table, element)
    for _, value in pairs(table) do
      if value == element then
        return true
      end
    end
    return false
end
  
local function highlightResult(result, matchChars)
    local out = ""
    for i = 1, #result do
        local c = result:sub(i,i)
        if table.contains(matchChars, i) then
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

SLASH_COMMANDS["/mapsearch"] = function (extra)
    if extra == 'save' then
        buildLocations()
        MapSearch.saved.locations = deepCopy(Search.locations)
        MapSearch.saved.zones = deepCopy(Search.zones)
        MapSearch.saved.result = deepCopy(Search.result)
        d("Written MapSearch data to Saved Preferences")
    elseif extra == 'clear' then
        MapSearch.saved.categories = nil
        MapSearch.saved.locations = nil
        MapSearch.saved.zones = nil
        MapSearch.saved.result = nil
        d("Cleared MapSearch data from Saved Preferences")
    end
end
