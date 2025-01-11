local MS = MapSearch
local Locs = MS.Locations or {
    nodes = nil,
    nodeMap = nil,
    zones = nil,
    players = nil,
    playerZones = nil,
    knownNodes = {}
}
local Utils = MS.Utils
local logger = MS.logger -- LibDebugLogger("MapSearch")

POI_TYPE_NONE = -1
POI_TYPE_TRIAL = 100
POI_TYPE_ARENA = 101
POI_TYPE_FRIEND = 102
POI_TYPE_GUILDMATE = 103
POI_TYPE_ZONE = 104

function Locs:initialise()
    logger:Debug("Locs:initialise() starts")
    self:setupNodes()
    logger:Debug("Locs:initialise() setupPlayerZones")
    self:setupPlayerZones()
    logger:Debug("Locs:initialise() ends")
end

function Locs:setupNodes()
    if self.nodes then
        self:clearKnownNodes()
        return
    end

    self.nodes = {}
    self.nodeMap = {}
    self.zones = {}

    local totalNodes = GetNumFastTravelNodes()
    for i = 1, totalNodes do
        local known, name, Xcord, Ycord, icon, glowIcon, typePOI, onMap, isLocked = GetFastTravelNodeInfo(i)

        local zoneIndex, _ = GetFastTravelNodePOIIndicies(i)
        local nodeZoneId = GetZoneId(zoneIndex)

        if name:find('Harborage') then
            logger:Info("POI " .. i .. " '" .. name .. "' type " .. typePOI .. " " .. (glowIcon or "-"))
        end

        if not isLocked and name ~= "" and (typePOI == 1 or glowIcon ~= nil) then
            if self.zones[nodeZoneId] == nil then
                local zoneName = GetZoneNameById(nodeZoneId)
                self.zones[nodeZoneId] = {
                    name = zoneName,
                    index = zoneIndex,
                    nodes = {}
                }
            end

            local nodeInfo = {
                nodeIndex = i,
                name = name,
                originalName = name,
                type = typePOI,
                zoneId = nodeZoneId,
                glowIcon = glowIcon,
                icon = icon,
                originalIcon = icon
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
                -- nodeInfo.icon = icon
                nodeInfo.owned = (icon:find("poi_group_house_owned") ~= nil) --(icon == "/esoui/art/icons/poi/poi_group_house_owned.dds")
                -- elseif name:find(" Arena") then
                --     nodeInfo.poiType = POI_TYPE_ARENA
                --     -- nodeInfo.name = string.sub(nodeInfo.name, 1, #nodeInfo.name - 6)
                --     nodeInfo.icon = "esoui/art/tutorial/poi_raiddungeon_complete.dds"
            elseif typePOI == 1 then
                nodeInfo.poiType = POI_TYPE_WAYSHRINE
                -- nodeInfo.icon = "esoui/art/icons/poi/poi_wayshrine_complete.dds"
                if name:find(" Wayshrine") then
                    nodeInfo.name = string.sub(nodeInfo.name, 1, #nodeInfo.name - 10)
                end
            elseif glowIcon == "/esoui/art/icons/poi/poi_soloinstance_glow.dds" then
                nodeInfo.poiType = POI_TYPE_ARENA
                -- nodeInfo.icon = "esoui/art/icons/poi/poi_soloinstance_complete.dds"
                nodeInfo.suffix = "Arena"
                -- if name:find(" Arena") then
                --     nodeInfo.name = string.sub(nodeInfo.name, 1, #nodeInfo.name - 6)
                -- end
            elseif glowIcon == "/esoui/art/icons/poi/poi_groupinstance_glow.dds" then
                nodeInfo.poiType = POI_TYPE_ARENA
                -- nodeInfo.icon = "esoui/art/icons/poi/poi_groupinstance_complete.dds"
                nodeInfo.suffix = "Arena"
            else
                logger:Warn("Unknown POI " .. i .. " '" .. name .. "' type " .. typePOI .. " " .. (glowIcon or "-"))
                -- if glowIcon ~= nil and glowIcon:find("/esoui/art/icons/poi/poi_") and glowIcon:find("_glow.dds") then
                --     nodeInfo.icon = glowIcon:gsub("_glow.dds", "_complete.dds")
                -- end
            end

            nodeInfo.barename = Utils.bareName(nodeInfo.name)

            if icon == "/esoui/art/icons/icon_missing.dds" then
                nodeInfo.icon = "/esoui/art/crafting/crafting_smithing_notrait.dds"
            end

            local traders = MS.Data.traderCounts[i]
            if traders and traders > 0 then
                nodeInfo.traders = traders
            end

            table.insert(self.zones[nodeZoneId].nodes, nodeInfo)
            table.insert(self.nodes, nodeInfo)
            self.nodeMap[i] = nodeInfo
            self.knownNodes[i] = known
        end
    end
end

function Locs:addPlayerZone(zoneId, zoneName, userID, icon, poiType)
    if self.zones[zoneId] and CanJumpToPlayerInZone(zoneId) then
        local zoneInfo = {
            zoneId = zoneId,
            zoneName = zoneName,
            userID = userID,
            icon = icon,
            poiType = poiType
        }

        self.players[userID] = zoneInfo
        self.playerZones[zoneId] = zoneInfo
    end
end

function Locs:setupPlayerZones()
    local myID = GetDisplayName()
    self.playerZones = {}
    self.players = {}

    local guildCount = GetNumGuilds()
    for guild = 1, guildCount do
        local guildID = GetGuildId(guild)
        local guildMembers = GetNumGuildMembers(guildID)

        for i=1, guildMembers do
            local userID, _, _, playerStatus = GetGuildMemberInfo(guildID, i)

            if playerStatus ~= PLAYER_STATUS_OFFLINE and userID~=myID then
                local _, _, zoneName, _, _, _, _, zoneId = GetGuildMemberCharacterInfo(guildID, i)
                self:addPlayerZone(zoneId, zoneName, userID, "/esoui/art/menubar/gamepad/gp_playermenu_icon_character.dds", POI_TYPE_GUILDMATE)
            end
        end
    end

    local friendCount = GetNumFriends()
    for i = 1, friendCount do
		local userID, _, playerStatus, secsSinceLogoff = GetFriendInfo(i)

		if playerStatus ~= PLAYER_STATUS_OFFLINE and secsSinceLogoff == 0 then
            local hasChar, _, zoneName, _, _, _, _, zoneId = GetFriendCharacterInfo(i)
            if hasChar then
                self:addPlayerZone(zoneId, zoneName, userID, "/esoui/art/menubar/gamepad/gp_playermenu_icon_character.dds", POI_TYPE_FRIEND)
            end
        end
    end
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

function Locs:getKnownNodes(zoneId)
    if self.nodes == nil then
        self:initialise()
    end

    local nodes = {}
    for i = 1, #self.nodes do
        local index = self.nodes[i].nodeIndex
        if self:isKnownNode(index) and (not zoneId or self.nodes[i].zoneId == zoneId) then
            local node = Utils.shallowCopy(self.nodes[i])
            local bookmarked = MS.Bookmarks:contains(index)
            node.known = true
            node.weight = 1.0
            if node.poiType == POI_TYPE_WAYSHRINE and MS.isRecall then
                node.weight = bookmarked and 0.9 or 0.8
            elseif node.poiType == POI_TYPE_HOUSE and not node.owned then
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
        self:initialise()
    end

    local nodes = {}
    for i = 1, #self.nodes do
        local index = self.nodes[i].nodeIndex
        if self:isKnownNode(index) and self.nodes[i].poiType == POI_TYPE_HOUSE then
            local node = Utils.shallowCopy(self.nodes[i])
            if MS.Bookmarks:contains(index) then
                node.bookmarked = true
            end
            if not node.owned then
                node.weight = 0.7
            elseif node.bookmarked then
                node.weight = 1.2
            end
            table.insert(nodes, node)
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
                suffix = info.zoneName,
                poiType = info.poiType,
                userID = userID
            })
        end
    end

    return nodes
end

function Locs:getPlayerZoneList()
    local nodes = {}

    if self.playerZones == nil then
        self:setupPlayerZones()
    end

    for zoneID, info in pairs(self.playerZones) do
        table.insert(nodes, {
            name = info.zoneName,
            barename = Utils.bareName(info.zoneName),
            zoneId = zoneID,
            zoneName = info.zoneName,
            icon = "MapSearch/media/zone.dds",
            suffix = info.userID,
            poiType = info.poiType,
            userID = info.userID
        })
    end

    return nodes
end

function Locs:getPlayerInZone(zoneId)
    if self.playerZones == nil then
        self:setupPlayerZones()
    end

    local info = self.playerZones[zoneId]
    return {
        name = info.zoneName,
        barename = Utils.bareName(info.zoneName),
        zoneId = zoneId,
        zoneName = info.zoneName,
        icon = info.icon,
        suffix = info.userID,
        poiType = info.poiType,
        userID = info.userID
    }
end

function Locs:getZoneList()
    local nodes = {}

    if self.zones ~= nil then
        for zoneID, info in pairs(self.zones) do
            table.insert(nodes, {
                name = info.name,
                barename = Utils.bareName(info.name),
                zoneId = zoneID,
                zoneName = info.name,
                icon = "MapSearch/media/zone.dds",
                poiType = POI_TYPE_ZONE
            })
        end
    end

    return nodes
end

MapSearch.Locations = Locs
