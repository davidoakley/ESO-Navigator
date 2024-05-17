MapSearch = {}
MapSearch.Wayshrine = {}
MapSearch.Location = {}
MapSearch.Options = {}
MapSearch.Utils = {}

function GetCVar(lang) return "en"  end

require("WayshrineData")
require("LocationData")
require("Utils")

--print("Hello World")

local locations = MapSearch.Location.Data.GetList()

for i, map in ipairs(locations) do
    if map.zoneId ~= nil then
        print(" - "..map.zoneId.." - "..map.name)
    end
end
