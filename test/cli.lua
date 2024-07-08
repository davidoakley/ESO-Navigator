MapSearch = {}
MapSearch.Wayshrine = {}
MapSearch.Location = {}
MapSearch.Options = {}
MapSearch.Utils = {}
MapSearch.Search = {}
MapSearch.logger = {}

MapSearch.logger.Info = function(obj, text)
    print(" # "..text)
end
SLASH_COMMANDS = {}

function GetCVar(lang) return "en"  end

require("fzy")
MapSearch.ansicolors = require('ansicolors')
require("test.SV.MapSearch")
require("WayshrineData")
require("LocationData")
require("Utils")
require("Search")
require("Wayshrine")


MapSearch.isCLI = true

local inspect = require('test.inspect')
local Search = MapSearch.Search

POI_TYPE_WAYSHRINE = 1
POI_TYPE_GROUP_DUNGEON = 6
POI_TYPE_HOUSE = 7

MapSearch.Search.categories = MapSearch_SavedVariables.Default["@SirNightstorm"]["$AccountWide"].categories
MapSearch.Search.locations = MapSearch_SavedVariables.Default["@SirNightstorm"]["$AccountWide"].locations
MapSearch.Search.zones = MapSearch_SavedVariables.Default["@SirNightstorm"]["$AccountWide"].zones

local typeLabels = {
    [POI_TYPE_WAYSHRINE] = 'W',
    [POI_TYPE_GROUP_DUNGEON] = 'D',
    [POI_TYPE_HOUSE] = 'H',
    [POI_TYPE_TRIAL] = 'T',
    [POI_TYPE_ARENA] = 'A'
}

local function dumpCategorisedResults(results)
    for index, map in ipairs(results) do
        local nodes = map.nodes
        if #nodes >= 1 then
            print("@ "..map.name)
            for nodeIndex, nodeMap in ipairs(nodes) do
                print("  > "..nodeMap.name)
            end
        end
    end
end

local function dumpResults(results)
    for nodeIndex, nodeMap in ipairs(results) do
        -- print(inspect(nodeMap))
        local name = Search.highlightResult(nodeMap.name, nodeMap.matchChars)
        print("  ["..typeLabels[nodeMap.poiType].."] "..name.." ("..nodeMap.match..")")
    end
end

local function executeSearch(searchString)
	local results

	if searchString ~= nil and #searchString > 0 then
		results = Search.run(searchString)
	else
		results = {} --MapSearch.categories
	end

	MapSearch.results = results
	MapSearch.targetNode = 0
	-- MapSearch.saved.categories = categories

	--buildScrollList(control, results)
    dumpResults(results)
end

local searchTerm = arg[1]
executeSearch(searchTerm)