local MS = MapSearch
local Locs = MS.Locations or {
    nodes = nil,
    nodeMap = nil,
    zones = nil,
    knownNodes = {}
}
local Utils = MS.Utils
local logger = MS.logger -- LibDebugLogger("MapSearch")

function Locs:initialise()
    self.nodes = {}
    self.nodeMap = {}
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

        local zoneIndex, _ = GetFastTravelNodePOIIndicies(i)
        local nodeZoneId = GetZoneId(zoneIndex)

        if not isLocked and name ~= "" and glowIcon ~= nil then
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
                originalName = name,
                type = typePOI,
                glowIcon = glowIcon
            }

            if typePOI == 6 then
                nodeInfo.poiType = POI_TYPE_GROUP_DUNGEON
                nodeInfo.icon = "esoui/art/icons/poi/poi_groupinstance_complete.dds"
                if name:find("Dungeon: ") then
                    nodeInfo.name = string.sub(nodeInfo.name, 10, #nodeInfo.name)
                end
                nodeInfo.suffix = "Dungeon"
            elseif typePOI == 3 then
                nodeInfo.poiType = POI_TYPE_TRIAL
                nodeInfo.icon = "esoui/art/tutorial/poi_raiddungeon_complete.dds"
                -- nodeInfo.colour = ZO_ColorDef:New(1.0, 0.9, 0.8, 1.0)
                if nodeInfo.name:find("Trial: ") then
                    nodeInfo.name = string.sub(nodeInfo.name, 8, #nodeInfo.name)
                end
                nodeInfo.suffix = "Trial"
            elseif typePOI == 7 then
                nodeInfo.poiType = POI_TYPE_HOUSE
                nodeInfo.icon = "esoui/art/icons/poi/poi_group_house_owned.dds"
                -- elseif name:find(" Arena") then
                --     nodeInfo.poiType = POI_TYPE_ARENA
                --     -- nodeInfo.name = string.sub(nodeInfo.name, 1, #nodeInfo.name - 6)
                --     nodeInfo.icon = "esoui/art/tutorial/poi_raiddungeon_complete.dds"
            elseif typePOI == 1 then
                nodeInfo.poiType = POI_TYPE_WAYSHRINE
                nodeInfo.icon = "esoui/art/icons/poi/poi_wayshrine_complete.dds"
                if name:find(" Wayshrine") then
                    nodeInfo.name = string.sub(nodeInfo.name, 1, #nodeInfo.name - 10)
                end
            elseif glowIcon == "/esoui/art/icons/poi/poi_soloinstance_glow.dds" then
                nodeInfo.poiType = POI_TYPE_ARENA
                nodeInfo.icon = "esoui/art/icons/poi/poi_soloinstance_complete.dds"
                nodeInfo.suffix = "Arena"
                -- if name:find(" Arena") then
                --     nodeInfo.name = string.sub(nodeInfo.name, 1, #nodeInfo.name - 6)
                -- end
            elseif glowIcon == "/esoui/art/icons/poi/poi_groupinstance_glow.dds" then
                nodeInfo.poiType = POI_TYPE_ARENA
                nodeInfo.icon = "esoui/art/icons/poi/poi_groupinstance_complete.dds"
                nodeInfo.suffix = "Arena"
            else
                logger:Info("Unknown POI " .. i .. " '" .. name .. "' type " .. typePOI .. " " ..
                    (glowIcon or "-"))
                -- if glowIcon ~= nil and glowIcon:find("/esoui/art/icons/poi/poi_") and glowIcon:find("_glow.dds") then
                --     nodeInfo.icon = glowIcon:gsub("_glow.dds", "_complete.dds")
                -- end
            end

            nodeInfo.barename = Utils.bareName(nodeInfo.name)

            local traders = MS.Data.traderCounts[i]
            if traders and traders > 0 then
                nodeInfo.traders = traders
                nodeInfo.suffix = "|t23:23:/esoui/art/icons/servicemappins/servicepin_guildkiosk.dds:inheritcolor|t"
            end

            table.insert(self.zones[nodeZoneId].nodes, nodeInfo)
            table.insert(self.nodes, nodeInfo)
            self.nodeMap[i] = nodeInfo
            self.knownNodes[i] = known
        end
    end

    self:addTraderCounts()
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

function Locs:getNodeMap()
    if self.nodeMap == nil then
        self:initialise()
    end
    return self.nodeMap
end

function Locs:getKnownNodes()
    if self.nodes == nil then
        self:initialise()
    end

    local nodes = {}
    for i = 1, #self.nodes do
        local index = self.nodes[i].nodeIndex
        if self:isKnownNode(index) then
            table.insert(nodes, self.nodes[i])
        end
    end
    return nodes
end

function Locs:getPlayerList()
    local nodes = {}

    if self.players ~= nil then
        for userID, info in pairs(self.players) do
            table.insert(nodes, {
                name = userID,
                barename = userID:sub(2), -- remove '@' prefix
                zoneId = info.zoneId,
                zoneName = info.zoneName,
                icon = info.icon,
                suffix = info.suffix
            })
        end
    end

    return nodes
end

MapSearch.Locations = Locs
