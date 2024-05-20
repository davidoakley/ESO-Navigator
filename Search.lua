local Search = MapSearch.Search or {}
local Utils = MapSearch.Utils
local logger = LibDebugLogger("MapSearch")

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

	--logger:Info("zoneIndex "..zoneIndex)
	local iter = MapSearch.Wayshrine.GetKnownWayshrinesByZoneIndex(zoneIndex,-1)
	-- iter = Utils.map(iter,function(item)
	-- 	if item.traders_cnt then
	-- 		item.name = string.format("|ce000e0%1d|r %s", -- magenta
	-- 			item.traders_cnt, Utils.ShortName(item.name))
	-- 	else
	-- 		item.name = empty_prefix .. Utils.ShortName(item.name)
	-- 	end
	-- 	return AttachWayshrineDataHandlers(args,item)
	-- end)

	data = {}
	for i in iter do
        local node = deepCopy(i)
        if node.name:find("Dungeon: ") then
            node.poiType = POI_TYPE_GROUP_DUNGEON
            node.name = string.sub(node.name, 10, #node.name)
        elseif node.name:find("Trial: ") then
            node.poiType = POI_TYPE_TRIAL
            node.name = string.sub(node.name, 8, #node.name)
        elseif node.name:find(" Arena") then
            node.poiType = POI_TYPE_ARENA
            node.name = string.sub(node.name, 1, #node.name - 6)
        elseif node.name:find(" Wayshrine") then
            node.poiType = POI_TYPE_WAYSHRINE
            node.name = string.sub(node.name, 1, #node.name - 10)
        elseif node.textureName == "/esoui/art/icons/poi/poi_group_house_glow.dds" then
            node.poiType = POI_TYPE_HOUSE
        end

        node.barename = Utils.BareName(node.name)

		table.insert(data, node)
	end

	return data
end

local function getCategories()
	local categories = {}
	local locations = MapSearch.Location.Data.GetList()

	for i, map in ipairs(locations) do
		if map.zoneId ~= nil then
			print(" - "..map.zoneId.." - "..map.name)

			local nodes = getZoneWayshrines(map.zoneIndex)
			table.sort(nodes, Utils.SortByBareName)
			map.nodes = nodes
	
			--categories[map.zoneIndex] = map
			table.insert(categories, map)
		end
	end

	return categories
end

local function nocase (s)
    s = string.gsub(s, "%a", function (c)
          return string.format("[%s%s]", string.lower(c),
                                         string.upper(c))
        end)
    return s
end

local function buildCategories()
	local categories = getCategories()
	table.sort(categories, Utils.SortByBareName)

	Search.categories = categories
end

local function match(object, searchTerm)
    local matchLevel = 0
    local name = object.barename or object.name

    if string.find(name, searchTerm) then
        matchLevel = 10
    end

    return matchLevel
end

local function matchComparison(x,y)
	return (x.barename or x.name) < (y.barename or y.name)
end

local function run(searchTerm)
    if Search.categories == nil then
        logger:Info("Search.run: building categories")
		buildCategories()
	end

    searchTerm = searchTerm:lower()
    searchTerm = searchTerm:gsub("[^%w ]", "")

    logger:Info("Search.run("..searchTerm..")")

    local categories = deepCopy(Search.categories)

    local wayshrines = {}
    local dungeons = {}
    local trials = {}
    local arenas = {}
    local houses = {}
    local zones = {}

    for i, category in ipairs(categories) do
        if match(category, searchTerm) > 0 then
            table.insert(zones, category) --category.show = true
        end
        for j, node in ipairs(category.nodes) do
            if match(node, searchTerm) > 0 then
                if node.poiType == POI_TYPE_GROUP_DUNGEON then --or item.name:find("Trial: ") or item.poiIndex == 0 or item.nodeIndex == 270 then
                    table.insert(dungeons, node)
                elseif node.poiType == POI_TYPE_TRIAL then
                    table.insert(trials, node)
                elseif node.poiType == POI_TYPE_ARENA then
                    table.insert(arenas, node)
                elseif node.poiType == POI_TYPE_HOUSE then
                    table.insert(houses, node)
                else
                    table.insert(wayshrines, node)
                end
            end
        end
    end

    local result = {}

    if #wayshrines > 0 then
        table.sort(wayshrines, matchComparison)
        table.insert(result, {
            ["name"] = "Wayshrines",
            ["nodes"] = wayshrines,
            ["icon"] = "esoui/art/icons/poi/poi_wayshrine_complete.dds"
        })
    end

    if #dungeons > 0 then
        table.sort(dungeons, matchComparison)
        table.insert(result, {
            ["name"] = "Dungeons",
            ["nodes"] = dungeons,
            ["icon"] = "esoui/art/icons/poi/poi_dungeon_complete.dds"
        })
    end

    if #trials > 0 then
        table.sort(trials, matchComparison)
        table.insert(result, {
            ["name"] = "Trials",
            ["nodes"] = trials,
            ["icon"] = "esoui/art/tutorial/poi_raiddungeon_complete.dds"
        })
    end

    if #arenas > 0 then
        table.sort(arenas, matchComparison)
        table.insert(result, {
            ["name"] = "Arenas",
            ["nodes"] = arenas,
            ["icon"] = "esoui/art/tutorial/poi_raiddungeon_complete.dds"
        })
    end

    if #houses > 0 then
        table.sort(houses, matchComparison)
        table.insert(result, {
            ["name"] = "Houses",
            ["nodes"] = houses,
            ["icon"] = "esoui/art/icons/poi/poi_group_house_owned.dds"
        })
    end

    if #zones > 0 then
        table.sort(zones, matchComparison)
        for k,v in ipairs(zones) do
            v.icon = "esoui/art/tutorial/zonestoryquest_icon_assisted.dds"
            table.insert(result, v)
        end
    end

    Search.result = result

    return result
end

Search.buildCategories = buildCategories
Search.run = run

SLASH_COMMANDS["/mapsearchsave"] = function (extra)
    buildCategories()
    MapSearch.saved.categories = deepCopy(Search.categories)
    MapSearch.saved.result = deepCopy(Search.result)
    d("Written MapSearch data to Saved Preferences")
  end
