local Nav = Navigator
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

local function uniqueName(name, x, z)
    return string.format("%s:%.4f,%.4f", Utils.bareName(name), x, z)
end

local function createNode(self, i, name, typePOI, icon, glowIcon, known)
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
        glowIcon = glowIcon,
        icon = icon,
        originalIcon = icon,
        known = known
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

local function getOrCreateZone(self, zoneId, zoneName, zoneIndex)
    if not self.zones[zoneId] then
        if self:IsZone(zoneId) then
            self.zones[zoneId] = Nav.ZoneNode:New({
                name = zoneName,
                zoneName = zoneName,
                zoneId = zoneId,
                index = zoneIndex,
                nodes = {},
                canJumpToPlayer = CanJumpToPlayerInZone(zoneId) or zoneId == Nav.ZONE_ATOLLOFIMMOLATION,
                known = true
            })
            if zoneId == 642 then
                self.zones[zoneId].hidden = true
            end
        else
            Nav.log("setupNodes: not zone: zoneId %d name %s", zoneId, zoneName)
        end
    end
    return self.zones[zoneId]
end

local function addExtraZone(self, zoneId, mapId, canJumpToPlayer)
    local name, _, _, zoneIndex, _ = GetMapInfoById(mapId)
    self.zones[zoneId] = Nav.ZoneNode:New({
        name = name,
        zoneName = name,
        zoneId = zoneId,
        index = zoneIndex,
        mapId = mapId,
        canJumpToPlayer = canJumpToPlayer,
        known = true,
        nodes = {}
    })
end

function Locs:setupNodes()
    local beginTime  = GetGameTimeMilliseconds()
    self.nodes = {}
    self.nodeMap = {}
    self.zones = {}
    self.locMap = {}

    local totalNodes = GetNumFastTravelNodes()
    local namelocMap = {} -- Match on barename and location
    local locMap = {} -- Match on location
    for i = 1, totalNodes do
        local known, name, x, z, icon, glowIcon, typePOI, _, isLocked = GetFastTravelNodeInfo(i)

        if not isLocked and name ~= "" and (typePOI == 1 or glowIcon ~= nil) then
            local node = createNode(self, i, name, typePOI, icon, glowIcon, known)

            table.insert(self.nodes, node)
            self.nodeMap[i] = node
            local uid = uniqueName(name, x, z)
            if not namelocMap[uid] then
                namelocMap[uid] = node
                locMap[string.format("%.4f,%.4f", x, z)] = node
            end
        end
    end
    --self.namelocMap = namelocMap

    Nav.log("Locations:setupNodes: FTNodes took %d ms", GetGameTimeMilliseconds() - beginTime)
    beginTime = GetGameTimeMilliseconds()

    -- Iterate through zones to find correct zones for nodes
    local zoneIdLimit = 1446 -- The Scholarium
    for zoneId = 1, zoneIdLimit do
		local zoneName = GetZoneNameById(zoneId)
		if zoneName ~= nil and zoneName ~= ""
           and zoneId ~= 643 -- Imperial Sewers
           --and zoneId ~= 1283 -- The Shambles
           then
            zoneIdLimit = zoneId + 50
            zoneName = Utils.FormatSimpleName(zoneName)
			local zoneIndex = GetZoneIndex(zoneId)
			local numPOIs = GetNumPOIs(zoneIndex)
			for poiIndex = 1, numPOIs do
				local poiName = GetPOIInfo(zoneIndex, poiIndex) -- might be wrong - "X" instead of "Dungeon: X"!
                local x, z = GetPOIMapInfo(zoneIndex, poiIndex)
                local node = namelocMap[uniqueName(poiName, x, z)]  -- that's why we use BareName to strip prefix
                -- fix "Darkshade Caverns I" being returned for both DC1 and DC2
                if zoneId == 57 and poiIndex == 60 then -- zone Deshaan, POI 60 is DC2!
                    node = self.nodeMap[264]
                elseif not node then
                    node = locMap[string.format("%.4f,%.4f", x, z)]
                end
                if poiName ~= "" and node ~= nil  then -- teleportable POI
                    node.poiIndex = poiIndex

                    if zoneId==1146 then -- the Dragonguard Sanctuary wayshrine in Tideholm
                        zoneId = 1133 -- should appear in Southern Elsweyr
                    elseif zoneId==1283 then
                        zoneId = Nav.ZONE_FARGRAVE -- The Shambles -> Fargrave
                        node.mapId = 2082
					end

                    local zone = getOrCreateZone(self, zoneId, zoneName, zoneIndex)
                    if zone then
                        node.zoneId = zoneId
                        table.insert(zone.nodes, node)
                    -- else
                    --     Nav.log("Locs:setupNodes: node "..i.." '"..nodeInfo.name.."' in non-parent zoneId "..nodeZoneId)
                    end
				end
			end
		end
	end

    addExtraZone(self, Nav.ZONE_TAMRIEL, 27) -- Sort of true, but called 'Clean Test'
    addExtraZone(self, 1, 439) -- Fake!
    addExtraZone(self, Nav.ZONE_ATOLLOFIMMOLATION, 2000, true)
    addExtraZone(self, Nav.ZONE_BLACKREACH, 1782, false)

    Nav.log("Locations:setupNodes: POIs took %d ms (zoneIdLimit %d)", GetGameTimeMilliseconds() - beginTime, zoneIdLimit)

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


function Locs:getNodes()
    if self.nodes == nil then
        self:setupNodes()
    end
    return self.nodes
end

function Locs:getNodeMap()
    if self.nodeMap == nil then
        self:setupNodes()
    end
    return self.nodeMap
end

function Locs:GetNode(nodeIndex, includeUnknown)
    local node = self.nodeMap[nodeIndex]
    if not includeUnknown and not node:IsKnown() then
        return nil
    end

    return self.nodeMap[nodeIndex]
end

local function createHouseAlias(node)
    local alias = Nav.HouseNode:New(Utils.shallowCopy(node))
    alias.name = node.nickname
    alias.suffix = node.name
    alias.originalName = nil
    alias.isAlias = true
    return alias
end

function Locs:getKnownNodes(zoneId, includeAliases)
    if self.nodes == nil then
        self:setupNodes()
    end

    if zoneId == Nav.ZONE_BLACKREACH then
        local nodes1 = self:getKnownNodes(Nav.ZONE_BLACKREACH_ARKTHZANDCAVERN)
        local nodes2 = self:getKnownNodes(Nav.ZONE_BLACKREACH_GREYMOORCAVERNS)
        return Utils.tableConcat(nodes1, nodes2)
    end

    local nodes = {}
    for i = 1, #self.nodes do
        local node = self.nodes[i]
        if node:IsKnown() and (not zoneId or node.zoneId == zoneId) then
            table.insert(nodes, node)

            if includeAliases and node:IsHouse() and Nav.saved.useHouseNicknames then
                table.insert(nodes, createHouseAlias(node))
            end
        end
    end
    return nodes
end

function Locs:getHouseList(includeAliases)
    if self.nodes == nil then
        self:setupNodes()
    end

    local nodes = {}
    for i = 1, #self.nodes do
        local index = self.nodes[i].nodeIndex
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
        self:setupNodes()
    end
    return self.zones
end

function Locs:getZoneList(includeAliases)
    local nodes = {}

    if not self.zones then
        self:setupNodes()
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
        self:setupNodes()
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
        self:setupNodes()
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
        if self:isKnownNode(i) then
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
