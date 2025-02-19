local Nav = Navigator

--- @class Locations
local Locs = Nav.Locations or {
    nodes = nil,
    nodeMap = nil,
    zones = nil,
    mapIndices = nil,
    harborageIndex = nil
}
local Utils = Nav.Utils

function Locs:initialise()
end

function Locs:IsZone(zoneId)
    if (zoneId == GetParentZoneId(zoneId)
       or zoneId==267 -- Eyevea
       or zoneId==981 -- The Brass Fortress
       or zoneId==1027 -- Artaeum
       or zoneId==1413 -- Apocrypha
       or zoneId==1463 -- The Scholarium
       or zoneId==1272 -- Atoll of Immolation
       )
       then
        return true
    end
    return false
end

local function uniqueName(index, name, x, z)
    return (index == 0) and string.format("%s:%.4f,%.4f", Utils.bareName(name), x, z)
                         or string.format("%.4f,%.4f", x, z)
end

local function createNode(self, i, name, typePOI, icon, glowIcon, known, zone, poiIndex)
    if i >= 210 and i <= 212 then
        -- Save this character's alliance's Harborage
        self.harborageIndex = i
    end

    name = Utils.FormatSimpleName(name)

    local nodeInfo = {
        nodeIndex = i,
        name = Utils.DisplayName(name),
        originalName = name,
        type = typePOI,
        icon = icon,
        originalIcon = icon,
        known = known,
        zoneId = zone.zoneId,
        zoneIndex = zone.zoneIndex,
        poiIndex = poiIndex
    }

    local isHouse = false
    if typePOI == 6 then
        nodeInfo.poiType = Nav.POI_GROUP_DUNGEON
    elseif typePOI == 3 then
        nodeInfo.poiType = Nav.POI_TRIAL
        nodeInfo.icon = "esoui/art/tutorial/poi_raiddungeon_complete.dds"
    elseif typePOI == 7 then
        nodeInfo.owned = (icon:find("poi_group_house_owned") ~= nil)
        nodeInfo.freeRecall = true
        isHouse = true
        if Nav.saved.useHouseNicknames then
            nodeInfo.houseId = GetFastTravelNodeHouseId(i)
            local collectibleId = GetCollectibleIdForHouse(nodeInfo.houseId)
            nodeInfo.nickname = GetCollectibleNickname(collectibleId)
            nodeInfo.suffix = zo_strformat(GetString(SI_TOOLTIP_COLLECTIBLE_NICKNAME), nodeInfo.nickname)
        end
    elseif typePOI == 1 then
        nodeInfo.poiType = Nav.POI_WAYSHRINE
        if icon:find("poi_wayshrine_complete") then nodeInfo.icon = "Navigator/media/wayshrine.dds" end
    elseif glowIcon == "/esoui/art/icons/poi/poi_soloinstance_glow.dds" or
            glowIcon == "/esoui/art/icons/poi/poi_groupinstance_glow.dds" then
        nodeInfo.poiType = Nav.POI_ARENA
    else
        Nav.logWarning("Unknown POI " .. i .. " '" .. name .. "' type " .. typePOI .. " " .. (glowIcon or "-"))
    end

    nodeInfo.barename = Utils.bareName(nodeInfo.name)

    if icon == "/esoui/art/icons/icon_missing.dds" then
        nodeInfo.icon = "/esoui/art/crafting/crafting_smithing_notrait.dds"
    end

    if nodeInfo.zoneId == Nav.ZONE_CYRODIIL and nodeInfo.poiType == Nav.POI_WAYSHRINE then
        nodeInfo.icon = "/esoui/art/crafting/crafting_smithing_notrait.dds"
        nodeInfo.disabled = true
    end

    local traders = Nav.Data.traderCounts[i]
    if traders and traders > 0 then
        nodeInfo.traders = traders
    end

    local node = isHouse and Nav.HouseNode:New(nodeInfo) or Nav.FastTravelNode:New(nodeInfo)
    return node
end

local function getOrCreateZone(self, zoneId, zoneName, zoneIndex, mapId, canJumpToPlayer)
    if not self.zones[zoneId] then
        if mapId and zoneIndex == nil then
            local n, _, _, i, _ = GetMapInfoById(mapId)
            zoneName = n
            zoneIndex = i
        end
        if self:IsZone(zoneId) or mapId then
            if canJumpToPlayer == nil then
                canJumpToPlayer = CanJumpToPlayerInZone(zoneId) or zoneId == Nav.ZONE_ATOLLOFIMMOLATION
            end
            self.zones[zoneId] = Nav.ZoneNode:New({
                name = zoneName,
                zoneName = zoneName,
                zoneId = zoneId,
                zoneIndex = zoneIndex,
                index = zoneIndex,
                mapId = mapId,
                pois = {},
                canJumpToPlayer = canJumpToPlayer,
                known = true
            })
            if zoneId == 642 then
                self.zones[zoneId].hidden = true
            end
        else
            Nav.log("SetupNodes: not zone: zoneId %d name %s", zoneId, zoneName)
        end
    end
    return self.zones[zoneId]
end

local function loadFastTravelNode(self, nodeIndex, nodeLookup, zoneLookup)
    local known, name, x, z, icon, glowIcon, typePOI, _, isLocked = GetFastTravelNodeInfo(nodeIndex)

    if not isLocked and name ~= "" and (typePOI == 1 or glowIcon ~= nil) then
        local zoneIndex, poiIndex = GetFastTravelNodePOIIndicies(nodeIndex)
        local zoneId = GetZoneId(zoneIndex)
        if not zoneLookup[zoneId] then
            zoneId = GetParentZoneId(zoneId)
        end
        if zoneLookup[zoneId] then
            local _, _, _, zone = unpack(zoneLookup[zoneId])
            local node = createNode(self, nodeIndex, name, typePOI, icon, glowIcon, known, zone, poiIndex)

            self.nodeMap[nodeIndex] = node

            local uid = string.format("%d:%d", zoneIndex, poiIndex) --uniqueName(0, name, x, z)
            if not nodeLookup[uid] then --nodeLookup[uid] then
                nodeLookup[uid] = node
                table.insert(self.nodes, node)
                zone.pois[poiIndex] = node

                node.nodeZoneIndex = zoneIndex
                node.nodePOIIndex = poiIndex
            else
                Nav.log("loadFastTravelNode: duplicate %d/%d/%s vs %d/%d/%s", zoneIndex, poiIndex, name, zone.pois[poiIndex].zoneIndex or -1, zone.pois[poiIndex].poiIndex or -1, zone.pois[poiIndex].name or "?")
            end
        else
            Nav.log("loadFastTravelNode: nodeIndex %d '%s': no zone for zoneIndex %d zoneId %d", nodeIndex, name, zoneIndex or -1, zoneId or -1)
        end
    end
end

local function loadPopulatedZones(self, zoneLookup)
    -- Iterate through zones to find correct zones for nodes
    local zoneIdLimit = 1446 -- The Scholarium
    local zoneId = 1
    while zoneId <= zoneIdLimit do --for zoneId = 1, zoneIdLimit do
        if self:IsZone(zoneId) then
            local zoneName = GetZoneNameById(zoneId)
            if zoneName ~= nil and zoneName ~= ""
                    and zoneId ~= 643 -- Imperial Sewers
            then
                zoneIdLimit = math.max(zoneIdLimit, zoneId + 50)
                zoneName = Utils.FormatSimpleName(zoneName)
                local zoneIndex = GetZoneIndex(zoneId)
                local numPOIs = GetNumPOIs(zoneIndex)
                if numPOIs > 0 then
                    local zone = getOrCreateZone(self, zoneId, zoneName, zoneIndex)
                    zoneLookup[zoneId] = { zoneName, zoneIndex, numPOIs, zone }
                end
            end
        end
        zoneId = zoneId + 1
    end

    getOrCreateZone(self, Nav.ZONE_TAMRIEL, nil, nil, 27, false) -- Sort of true, but called 'Clean Test'
    getOrCreateZone(self, 1, nil, nil, 439, false) -- Fake!
    getOrCreateZone(self, Nav.ZONE_ATOLLOFIMMOLATION, nil, nil, 2000, true)
    getOrCreateZone(self, Nav.ZONE_BLACKREACH, nil, nil, 1782, false)
end

local function loadZonePOIs(self, zoneId, zoneIndex, zoneName, numPOIs)
    for poiIndex = 1, numPOIs do
        local nodeZoneId = zoneId
        local poiName = GetPOIInfo(zoneIndex, poiIndex) -- might be wrong - "X" instead of "Dungeon: X"!
        local zone = getOrCreateZone(self, nodeZoneId, zoneName, zoneIndex)
        if zone and not zone.pois[poiIndex] and poiName ~= nil and poiName ~= "" then
            local _, _, _, icon, _, _, isDiscovered, _ = GetPOIMapInfo(zoneIndex, poiIndex)
            local node = Nav.POINode:New({
                poiIndex = poiIndex,
                name = Utils.DisplayName(poiName),
                originalName = poiName,
                type = Nav.POI_MISC,
                zoneId = nodeZoneId,
                icon = icon,
                originalIcon = icon,
                known = isDiscovered
            })

            table.insert(self.nodes, node)
            zone.pois[poiIndex] = node
        end
    end
end

function Locs:SetupNodes()
    self.nodes = {}
    self.nodeMap = {}
    self.zones = {}
    self.zoneIndices = {}
    self.locMap = {}

    beginTime = GetGameTimeMilliseconds()
    local zoneLookup = {}
    loadPopulatedZones(self, zoneLookup)
    self.zoneLookup = zoneLookup
    Nav.log("Locations:SetupNodes: Zones took %d ms", GetGameTimeMilliseconds() - beginTime)

    local beginTime  = GetGameTimeMilliseconds()
    local nodeLookup = {} -- Match on barename:x,z or x,z
    local totalNodes = GetNumFastTravelNodes()
    for i = 1, totalNodes do
        loadFastTravelNode(self, i, nodeLookup, zoneLookup)
    end
    Nav.log("Locations:SetupNodes: FTNodes took %d ms", GetGameTimeMilliseconds() - beginTime)

    beginTime = GetGameTimeMilliseconds()
    -- Iterate through zones to find correct zones for nodes
    for zoneId, zoneData in pairs(zoneLookup) do
        local zoneName, zoneIndex, numPOIs = unpack(zoneData)
        loadZonePOIs(self, zoneId, zoneIndex, zoneName, numPOIs)
    end
    Nav.log("Locations:SetupNodes: POIs took %d ms", GetGameTimeMilliseconds() - beginTime)

    for i = 1, #self.nodes do
        if not self.nodes[i].poiIndex and self.nodes[i].zoneId ~= Nav.ZONE_CYRODIIL then
            Nav.log(" x %s - nodeIndex %d no poiIndex", self.nodes[i].name, self.nodes[i].nodeIndex)
        end
        if not self.nodes[i].zoneId then
            Nav.log(" x %s - nodeIndex %d no zoneId", self.nodes[i].name, self.nodes[i].nodeIndex)
        end
    end
end

function Locs:clearKnownNodes()
    if self.nodes then
        Nav.log("clearKnownNodes")
        for i = 1, #self.nodes do
            if not self.nodes[i].known then -- unknown nodes may become known, but not vice versa
                self.nodes[i].known = nil
            end
        end
    end
end


function Locs:GetNode(nodeIndex, includeUnknown)
    local node = self.nodeMap[nodeIndex]
    if not includeUnknown and not node:IsKnown() then
        return nil
    end

    return self.nodeMap[nodeIndex]
end

function Locs:GetPOI(zoneId, poiIndex, includeUnknown)
    for i = 1, #self.nodes do
        local node = self.nodes[i]
        if node.zoneId == zoneId and node.poiIndex == poiIndex and (not includeUnknown and not node:IsKnown()) then
            return node
        end
    end
    return nil
end

local function createHouseAlias(node)
    local alias = Nav.HouseNode:New(Utils.shallowCopy(node))
    alias.name = node.nickname
    alias.suffix = node.name
    alias.originalName = nil
    alias.isAlias = true
    return alias
end

---GetNodeList
---@param zoneId number
---@param includeAliases boolean
---@return table Node List
function Locs:GetNodeList(zoneId, includeAliases)
    if self.nodes == nil then
        self:SetupNodes()
    end

    if zoneId == Nav.ZONE_BLACKREACH then
        local nodes1 = self:GetNodeList(Nav.ZONE_BLACKREACH_ARKTHZANDCAVERN, includeAliases)
        local nodes2 = self:GetNodeList(Nav.ZONE_BLACKREACH_GREYMOORCAVERNS, includeAliases)
        return Utils.tableConcat(nodes1, nodes2)
    end

    local nodes = {}
    for i = 1, #self.nodes do
        local node = self.nodes[i]
        if (not zoneId or node.zoneId == zoneId) then --node:IsKnown() and (not zoneId or node.zoneId == zoneId) then
            table.insert(nodes, node)

            if includeAliases and node:IsHouse() and Nav.saved.useHouseNicknames then
                table.insert(nodes, createHouseAlias(node))
            end
        end
    end
    return nodes
end

function Locs:GetHouseList(includeAliases)
    if self.nodes == nil then
        self:SetupNodes()
    end

    local nodes = {}
    for i = 1, #self.nodes do
        if self.nodes[i]:IsKnown() and self.nodes[i]:IsHouse() then
            local node = self.nodes[i]
            table.insert(nodes, node)

            if includeAliases and node.owned and Nav.saved.useHouseNicknames then
                table.insert(nodes, createHouseAlias(node))
            end
        end
    end
    return nodes
end

function Locs:GetZones()
    if not self.zones then
        self:SetupNodes()
    end
    return self.zones
end

function Locs:GetZoneList(includeAliases)
    local nodes = {}

    if not self.zones then
        self:SetupNodes()
    end

    for zoneId, zone in pairs(self.zones) do
        if includeAliases or not zone.hidden then
            table.insert(nodes, zone)
            if includeAliases and zoneId == Nav.ZONE_ATOLLOFIMMOLATION then
                table.insert(nodes, Nav.ZoneNode:New({
                    name = GetString(NAVIGATOR_LOCATION_OBLIVIONPORTAL),
                    zoneId = zone.zoneId,
                    canJumpToPlayer = zone.canJumpToPlayer,
                    index = zone.index,
                    mapId = zone.mapId,
                    known = true
                }))
            end
        end
    end

    return nodes
end

function Locs:getZone(zoneId)
    if not self.zones then
        self:SetupNodes()
    end

    return self.zones[zoneId]
end

function Locs:getCurrentMapZoneId()
    local mapId = GetCurrentMapId()
    local _, mapType, _, zoneIndex, _ = GetMapInfoById(mapId)
    local zoneId = GetZoneId(zoneIndex)
    -- Nav.log("Locs:getCurrentMapZone zoneId = "..zoneId.." type "..mapType)
    if mapId == 2119 then
        zoneId = Nav.ZONE_FARGRAVE
    elseif mapType == MAPTYPE_SUBZONE and not self:IsZone(zoneId) then
        zoneId = GetParentZoneId(zoneId)
        -- Nav.log("Locs:getCurrentMapZone parent zoneId = "..zoneId)
    end

    return zoneId
end

function Locs:getCurrentMapZone()
    if self.zones == nil then
        self:SetupNodes()
    end

    local mapId = GetCurrentMapId()
    local _, mapType, _, zoneIndex, _ = GetMapInfoById(mapId)
    local zoneId = GetZoneId(zoneIndex)
    if mapId == 2000 then
        zoneId = Nav.ZONE_ATOLLOFIMMOLATION
    elseif mapId == 2119 then
        zoneId = Nav.ZONE_FARGRAVE
    elseif mapId == 1782 then
        zoneId = Nav.ZONE_BLACKREACH
        mapType = MAPTYPE_ZONE
        --return { zoneId = Nav.ZONE_BLACKREACH, name = GetMapNameById(mapId), mapId = mapId }
    end
    if zoneId == Nav.ZONE_TAMRIEL then
        return {
            zoneId = 2
        }
    elseif mapType == MAPTYPE_SUBZONE and not self:IsZone(zoneId) then
        zoneId = GetParentZoneId(zoneId)
        -- Nav.log("Locs:getCurrentMapZone parent zoneId = "..zoneId)
    end
    if not self.zones[zoneId] then
        Nav.log("Locs:getCurrentMapZone no info on zoneId "..zoneId)
    end
    return self.zones[zoneId]
end

function Locs:IsHarborage(nodeIndex)
	return nodeIndex >= 210 and nodeIndex <= 212
end

function Locs:GetHarborage()
    for i = 210, 212 do
        if self:GetNode(i) then
            return i
        end
    end
    Nav.log("Locs:GetHarborage failed to find harborage")
    return 210
end

function Locs.GetMapIdByZoneId(zoneId)
    if zoneId == Nav.ZONE_TAMRIEL then
        return 27
    elseif zoneId == 981 then -- Brass Fortress
        return 1348
    elseif zoneId == 1463 then -- The Scholarium
        return 2515
    else
        return GetMapIdByZoneId(zoneId)
    end
end

Nav.Locations = Locs
