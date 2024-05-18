MapSearch = {}
MapSearch.Wayshrine = {}
MapSearch.Location = {}
MapSearch.Options = {}
MapSearch.Utils = {}

function GetCVar(lang) return "en"  end

require("SV.MapSearch")
require("WayshrineData")
require("LocationData")
require("Utils")

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

local locations = MapSearch.Location.Data.GetList()

-- for i, map in ipairs(locations) do
--     if map.zoneId ~= nil then
--         print(" - "..map.zoneId.." - "..map.name)
--     end
-- end

local categories = MapSearch_SavedVariables.Default["@SirNightstorm"]["$AccountWide"].categories
local searchTerm = arg[1]

local filteredCats = filter(categories, searchTerm)

dump(filteredCats)
