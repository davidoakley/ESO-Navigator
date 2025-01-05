local Locs = MapSearch.Locations or {
    locations = nil,
    zones = nil,
    knownNodes = {}
}
local Utils = MapSearch.Utils
local logger = MapSearch.logger -- LibDebugLogger("MapSearch")

function Locs:initialise()
    self.nodes = {}
    self.zones = {}

    -- for i = 1, GetNumMaps() do
    --     local _, _, _, zoneIndex, _ = GetMapInfoByIndex(i)
    --     local zoneID = GetZoneId(zoneIndex)
    --     -- Include parent zones, plus Apocrypha, Arteum and the Brass Fortress;
    --     -- remove "Clean Test", Cyrodiil and Imperial City
    --     if (zoneID == GetParentZoneId(zoneID) or zoneID==981 or zoneID==1413 or zoneID==1027) and
    --         GetNumSkyshardsInZone(zoneID)>=minSkyshards and
    --         zoneID~=181 and zoneID~=584 and zoneID~=2 and CanJumpToPlayerInZone(zoneID) then
    --       table.insert(self.zones, zoneID)
    --       self.locations[zoneID] = {}
    --     end
    --   end
    local totalNodes = GetNumFastTravelNodes()

    for i = 1, totalNodes do
        local known, name, Xcord, Ycord, icon, glowIcon, typePOI, onMap, isLocked = GetFastTravelNodeInfo(i)

        local zoneIndex, _ =  GetFastTravelNodePOIIndicies(i)
        local nodeZoneId = GetZoneId(zoneIndex)

        if typePOI == 1 and not isLocked then -- and known then
            if self.zones[nodeZoneId] == nil then
                -- d('FastTravelNodes: ' .. nodeZoneId .. ': ' .. name)
                self.zones[nodeZoneId] = {
                    name = name,
                    index = zoneIndex,
                    nodes = {}
                }
            end

            local nodeInfo = {
                nodeIndex = i,
                name = name,
                type = typePOI
            }

            if nodeInfo.name:find("Dungeon: ") then
                nodeInfo.poiType = POI_TYPE_GROUP_DUNGEON
                nodeInfo.name = string.sub(nodeInfo.name, 10, #nodeInfo.name)
                nodeInfo.icon = "esoui/art/icons/poi/poi_groupinstance_complete.dds"
            elseif nodeInfo.name:find("Trial: ") then
                nodeInfo.poiType = POI_TYPE_TRIAL
                nodeInfo.name = string.sub(nodeInfo.name, 8, #nodeInfo.name)
                nodeInfo.icon = "esoui/art/tutorial/poi_raiddungeon_complete.dds"
            elseif nodeInfo.name:find(" Arena") then
                nodeInfo.poiType = POI_TYPE_ARENA
                nodeInfo.name = string.sub(nodeInfo.name, 1, #nodeInfo.name - 6)
                nodeInfo.icon = "esoui/art/tutorial/poi_raiddungeon_complete.dds"
            elseif nodeInfo.name:find(" Wayshrine") then
                nodeInfo.poiType = POI_TYPE_WAYSHRINE
                nodeInfo.name = string.sub(nodeInfo.name, 1, #nodeInfo.name - 10)
                nodeInfo.icon = "esoui/art/icons/poi/poi_wayshrine_complete.dds"
            elseif nodeInfo.textureName == "/esoui/art/icons/poi/poi_group_house_glow.dds" then
                nodeInfo.poiType = POI_TYPE_HOUSE
                nodeInfo.icon = "esoui/art/icons/poi/poi_group_house_owned.dds"
            end
    
            nodeInfo.barename = Utils.bareName(nodeInfo.name)

            table.insert(self.zones[nodeZoneId].nodes, nodeInfo)
            table.insert(self.nodes, nodeInfo)
            self.knownNodes[i] = known
        end
    end

    MapSearch.saved.zones = self.zones
    MapSearch.saved.nodes = self.nodes
end

function Locs:clearKnownNodes()
    self.knownNodes = {}
end

function Locs:isKnownNode(nodeIndex)
    if self.knownNodes[nodeIndex] ~= nil then
        return self.knownNodes[nodeIndex]
    else
        local known, name, Xcord, Ycord, icon, glowIcon, typePOI, onMap, isLocked = GetFastTravelNodeInfo(nodeIndex)
        self.knownNodes[nodeIndex] = known
        return known
    end
end

function Locs:getNodes()
    if self.nodes == nil then
        self:initialise()
    end
    return self.nodes
end

function Locs:getKnownNodes()
    if self.nodes == nil then
        self:initialise()
    end

    local nodes = {}
    for i = 1, #self.nodes do
        if self.isKnownNode(i) then
            table.insert(nodes, self.nodes[i])
        end
    end
    return nodes
end

MapSearch.Locations = Locs