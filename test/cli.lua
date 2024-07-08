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

require("test.SV.MapSearch")
require("WayshrineData")
require("LocationData")
require("Utils")
require("Search")
require("Wayshrine")

local inspect = require('test.inspect')
local Search = MapSearch.Search

MapSearch.Search.categories = MapSearch_SavedVariables.Default["@SirNightstorm"]["$AccountWide"].categories

local function deepCopy(obj)
    if type(obj) ~= 'table' then return obj end
    local res = {}
    for k, v in pairs(obj) do res[deepCopy(k)] = deepCopy(v) end
    return res
end

local function nocase (s)
    s = string.gsub(s, "%a", function (c)
          return string.format("[%s%s]", string.lower(c),
                                         string.upper(c))
        end)
    return s
end
  

local function filter(categoriesRef, searchTerm)
    local categories = deepCopy(categoriesRef)
    searchTerm = nocase(searchTerm)

    for i, category in ipairs(categories) do
        if string.find(category.name, searchTerm) then
            category.show = true
        end
        for j, node in ipairs(category.nodes) do
            if string.find(node.name, searchTerm) then
                node.show = true
                category.showNodes = true
            end
        end
    end

    local result = {}
    for i, category in ipairs(categories) do
        if category.show then
            table.insert(result, category)
        elseif category.showNodes then
            local resultNodes = {}
            for j, node in ipairs(category.nodes) do
                if node.show then
                    table.insert(resultNodes, node)
                end
            end
            category.nodes = resultNodes
            table.insert(result, category)
        end
    end

    return result
end

local function dump(categories)
    for i, category in ipairs(categories) do
        if category.zoneId ~= nil then
            print(" - "..category.name)
            for j, node in ipairs(category.nodes) do
                print("   . "..node.name)
            end
        end
    end
end

local function dumpResults(results)
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