local Nav = Navigator
local Locs = Nav.Locations or {
    nodes = nil,
    nodeMap = nil,
    zones = nil,
    mapIndices = nil,
    knownNodes = {},
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
       and not (
        zoneId == 642 -- The Earth Forge
    --       zoneId==2 -- Tamriel
    --    or zoneId==Nav.ZONE_CYRODIIL
       )
       then
        return true
    end
    return false
end

local function uniqueName(name, x, z)
    return string.format("%s:%.4f,%.4f", Utils.bareName(name), x, z)
end

function Locs:setupNodes()
    self.nodes = {}
    self.nodeMap = {}
    self.zones = {}
    self.locMap = {}

    local totalNodes = GetNumFastTravelNodes()
    local namelocMap = {} -- Match on barename and location
    local locMap = {} -- Match on location
    for i = 1, totalNodes do
        local known, name, x, z, icon, glowIcon, typePOI, _, isLocked = GetFastTravelNodeInfo(i)

        local zoneIndex, _ = GetFastTravelNodePOIIndicies(i)
        local nodeZoneId = GetParentZoneId(GetZoneId(zoneIndex))

        if not isLocked and name ~= "" and (typePOI == 1 or glowIcon ~= nil) then
            local nodeInfo = self:CreateNodeInfo(i, name, typePOI, nodeZoneId, icon, glowIcon)

            table.insert(self.nodes, nodeInfo)
            self.nodeMap[i] = nodeInfo
            self.knownNodes[i] = known
            local uid = uniqueName(name, x, z)
            if not namelocMap[uid] then
                namelocMap[uid] = nodeInfo
                locMap[string.format("%.4f,%.4f", x, z)] = nodeInfo
            end
        end
    end

    -- Iterate through zones to find correct zones for nodes
    for zoneId = 1, 2000 do
		local zoneName = GetZoneNameById(zoneId)
		if zoneName ~= nil and zoneName ~= ""
           and zoneId ~= 643 -- Imperial Sewers
           --and zoneId ~= 1283 -- The Shambles
           then
            zoneName = Utils.FormatSimpleName(zoneName)
			local zoneIndex = GetZoneIndex(zoneId)
			local numPOIs = GetNumPOIs(zoneIndex)
			for poiIndex = 1, numPOIs do
				local poiName = GetPOIInfo(zoneIndex, poiIndex) -- might be wrong - "X" instead of "Dungeon: X"!
                local x, z = GetPOIMapInfo(zoneIndex, poiIndex)
                local nodeInfo = namelocMap[uniqueName(poiName, x, z)]  -- that's why we use BareName to strip prefix
                -- fix "Darkshade Caverns I" being returned for both DC1 and DC2
                if zoneId == 57 and poiIndex == 60 then -- zone Deshaan, POI 60 is DC2!
                    nodeInfo = self.nodeMap[264]
                elseif not nodeInfo then
                    nodeInfo = locMap[string.format("%.4f,%.4f", x, z)]
                end
                if poiName ~= "" and nodeInfo ~= nil  then -- teleportable POI
                    nodeInfo.poiIndex = poiIndex

                    if zoneId==1146 then -- the Dragonguard Sanctuary wayshrine in Tideholm
                        zoneId = 1133 -- should appear in Southern Elsweyr
                    elseif zoneId==1283 then
                        zoneId = Nav.ZONE_FARGRAVE -- The Shambles -> Fargrave
                        nodeInfo.mapId = 2082
					end

                    if not self.zones[zoneId] then
                        if self:IsZone(zoneId) then
                            self.zones[zoneId] = {
                                name = zoneName,
                                zoneId = zoneId,
                                index = zoneIndex,
                                nodes = {}
                            }
                        else
                            Nav.log("setupNodes: not zone: zoneId %d name %s", zoneId, zoneName)
                        end
                    end

                    if self.zones[zoneId] then
                        nodeInfo.zoneId = zoneId
                        table.insert(self.zones[zoneId].nodes, nodeInfo)
                    -- else
                    --     Nav.log("Locs:setupNodes: node "..i.." '"..nodeInfo.name.."' in non-parent zoneId "..nodeZoneId)
                    end
				end
			end
		end
	end

    for i = 1, #self.nodes do
        if not self.nodes[i].poiIndex and self.nodes[i].zoneId ~= Nav.ZONE_CYRODIIL then
            Nav.log(" x %s - nodeIndex %d", self.nodes[i].name, self.nodes[i].nodeIndex)
        end
    end

    self:AddExtraZone(2, 27) -- Sort of true, but called 'Clean Test'
    self:AddExtraZone(1, 439) -- Fake!
    self:AddExtraZone(1272, 2000) -- Atoll Of Immolation
end

function Locs:AddExtraZone(zoneId, mapId)
    local name, _, _, zoneIndex, _ = GetMapInfoById(mapId)
    self.zones[zoneId] = {
        name = name,
        zoneId = zoneId,
        index = zoneIndex,
        mapId = mapId,
        nodes = {}
    }
end

function Locs:CreateNodeInfo(i, name, typePOI, nodeZoneId, icon, glowIcon)
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
        zoneId = nodeZoneId,
        glowIcon = glowIcon,
        icon = icon,
        originalIcon = icon
    }

    if typePOI == 6 then
        nodeInfo.poiType = Nav.POI_GROUP_DUNGEON
        if i ~= 550 then -- not Infinite Archive
            nodeInfo.suffix = GetString(NAVIGATOR_DUNGEON)
        end
    elseif typePOI == 3 then
        nodeInfo.poiType = Nav.POI_TRIAL
        nodeInfo.icon = "esoui/art/tutorial/poi_raiddungeon_complete.dds"
        nodeInfo.suffix = GetString(NAVIGATOR_TRIAL)
    elseif typePOI == 7 then
        nodeInfo.poiType = Nav.POI_GROUP_HOUSE
        nodeInfo.owned = (icon:find("poi_group_house_owned") ~= nil)
        nodeInfo.freeRecall = true
    elseif typePOI == 1 then
        nodeInfo.poiType = Nav.POI_WAYSHRINE
    elseif glowIcon == "/esoui/art/icons/poi/poi_soloinstance_glow.dds" or
           glowIcon == "/esoui/art/icons/poi/poi_groupinstance_glow.dds" then
        nodeInfo.poiType = Nav.POI_ARENA
        nodeInfo.suffix = GetString(NAVIGATOR_ARENA)
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

    return nodeInfo
end

function Locs:clearKnownNodes()
    self.knownNodes = {}
end

function Locs:isKnownNode(nodeIndex)
    if self.nodes == nil then
        self:setupNodes()
    end

    if self.knownNodes[nodeIndex] ~= nil then
        return self.knownNodes[nodeIndex]
    else
        local known, _, _, _, _, _, _, _, _ = GetFastTravelNodeInfo(nodeIndex)
        self.knownNodes[nodeIndex] = known
        return known
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

function Locs:GetNode(nodeIndex)
    if self.nodeMap == nil then
        self:setupNodes()
    end
    return self.nodeMap[nodeIndex]
end

function Locs:getKnownNodes(zoneId)
    if self.nodes == nil then
        self:setupNodes()
    end

    local nodes = {}
    for i = 1, #self.nodes do
        local index = self.nodes[i].nodeIndex
        if self:isKnownNode(index) and (not zoneId or self.nodes[i].zoneId == zoneId) then
            local node = Utils.shallowCopy(self.nodes[i])
            local bookmarked = Nav.Bookmarks:contains(self.nodes[i])
            node.known = true
            node.weight = 1.0
            node.bookmarked = bookmarked
            if not node.freeRecall and Nav.isRecall then
                node.weight = bookmarked and 0.9 or 0.8
            elseif node.poiType == Nav.POI_GROUP_HOUSE and not node.owned then
                node.weight = 0.7
            elseif bookmarked then
                node.weight = 1.2
            end
            if node.traders and node.traders > 0 then
                node.weight = node.weight * (1.0 + 0.02 * node.traders)
            end
            table.insert(nodes, node)
        end
    end
    return nodes
end

function Locs:getHouseList()
    if self.nodes == nil then
        self:setupNodes()
    end

    local nodes = {}
    for i = 1, #self.nodes do
        local index = self.nodes[i].nodeIndex
        if self:isKnownNode(index) and self.nodes[i].poiType == Nav.POI_GROUP_HOUSE then
            local node = Utils.shallowCopy(self.nodes[i])
            if Nav.Bookmarks:contains(node) then
                node.bookmarked = true
            end
            if not node.owned then
                node.weight = 0.7
            elseif node.bookmarked then
                node.weight = 1.2
            end
            node.known = true
            table.insert(nodes, node)
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

local function addZoneToList(nodes, name, zoneId, mapId, bookmarked, suffix)
    table.insert(nodes, {
        name = name,
        barename = Utils.bareName(name),
        zoneId = zoneId,
        zoneName = name,
        mapId = mapId,
        icon = "Navigator/media/zone.dds",
        poiType = Nav.POI_ZONE,
        weight = Nav.isRecall and 1.0 or 0.9,
        known = true,
        bookmarked = bookmarked,
        suffix = suffix
    })

end

function Locs:getZoneList(includeAliases)
    local nodes = {}

    if not self.zones then
        self:setupNodes()
    end

    for zoneId, info in pairs(self.zones) do
        addZoneToList(nodes, info.name, zoneId, info.mapId, Nav.Bookmarks:contains(info))
        if includeAliases and zoneId == Nav.ZONE_ATOLLOFIMMOLATION then
            addZoneToList(nodes, GetString(NAVIGATOR_LOCATION_OBLIVIONPORTAL), zoneId, info.mapId, Nav.Bookmarks:contains(info), info.name)
        end
    end

    return nodes
end

function Locs:getZone(zoneId)
    if not self.zones then
        self:setupNodes()
    end

    local info = self.zones[zoneId]
    return {
        name = info.name,
        barename = Utils.bareName(info.name),
        zoneId = zoneId,
        zoneName = info.name,
        icon = "Navigator/media/zone.dds",
        poiType = Nav.POI_ZONE,
        weight = Nav.isRecall and 1.0 or 0.9,
        known = true
    }
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
    end
    if zoneId == 2 then
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

Nav.Locations = Locs
