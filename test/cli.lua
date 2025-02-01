Navigator = {}
Navigator.Wayshrine = {}
Navigator.Location = {}
Navigator.Options = {}
Navigator.Utils = {}
Navigator.Search = {}
Navigator.logger = {}

Navigator.logger.Info = function(obj, text)
    print(" # "..text)
end
SLASH_COMMANDS = {}

function GetCVar(lang) return "en"  end

require("fzy")
Navigator.ansicolors = require('ansicolors')
require("test.SV.Navigator")
require("WayshrineData")
require("LocationData")
require("Utils")
require("Search")
require("Wayshrine")


Navigator.isCLI = true

local inspect = require('test.inspect')
local Search = Navigator.Search

POI_TYPE_WAYSHRINE = 1
POI_TYPE_GROUP_DUNGEON = 6
POI_TYPE_HOUSE = 7

Navigator.Search.categories = Navigator_SavedVariables.Default["@SirNightstorm"]["$AccountWide"].categories
Navigator.Search.locations = Navigator_SavedVariables.Default["@SirNightstorm"]["$AccountWide"].locations
Navigator.Search.zones = Navigator_SavedVariables.Default["@SirNightstorm"]["$AccountWide"].zones

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
		results = Search:Run(searchString)
	else
		results = {} --Navigator.categories
	end

	Navigator.results = results
	Navigator.targetNode = 0
	-- Navigator.saved.categories = categories

	--buildScrollList(control, results)
    dumpResults(results)
end

local searchTerm = arg[1]
executeSearch(searchTerm)