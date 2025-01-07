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

-- Trader Locations, copied from Faster Travel by SimonIllyan, XanDDemoX, upyachka, Valandil
local trader_counts = { -- nodeIndex -> traders_count
    [  1] = 1, -- Wyrd Tree Wayshrine
    [  6] = 1, -- Lion Guard Redoubt Wayshrine
    [  9] = 1, -- Oldgate Wayshrine
    [ 14] = 1, -- Koeglin Village Wayshrine
    [ 16] = 1, -- Firebrand Keep Wayshrine
    [ 25] = 1, -- Muth Gnaar Hills Wayshrine
    [ 28] = 7, -- Mournhold Wayshrine
    [ 29] = 1, -- Tal'Deic Grounds Wayshrine
    [ 33] = 5, -- Evermore Wayshrine
    [ 36] = 1, -- Bangkorai Pass Wayshrine
    [ 38] = 1, -- Hallin's Stand Wayshrine
    [ 42] = 1, -- Morwha's Bounty Wayshrine
    [ 43] = 5, -- Sentinel Wayshrine
    [ 44] = 1, -- Bergama Wayshrine
    [ 48] = 5, -- Stormhold Wayshrine
    [ 52] = 1, -- Hissmir Wayshrine
    [ 55] = 5, -- Shornhelm Wayshrine
    [ 56] = 7, -- Wayrest Wayshrine
    [ 62] = 5, -- Daggerfall Wayshrine
    [ 65] = 1, -- Davon's Watch Wayshrine
    [ 67] = 5, -- Ebonheart Wayshrine
    [ 76] = 1, -- Kragenmoor Wayshrine
    [ 78] = 1, -- Venomous Fens Wayshrine
    [ 84] = 1, -- Hoarfrost Downs Wayshrine
    [ 87] = 5, -- Windhelm Wayshrine
    [ 90] = 1, -- Voljar Meadery Wayshrine
    [ 92] = 1, -- Fort Amol Wayshrine
    [101] = 1, -- Dra'bul Wayshrine
    [106] = 5, -- Baandari Post Wayshrine
    [107] = 1, -- Valeguard Wayshrine
    [110] = 5, -- Skald's Retreat Wayshrine
    [114] = 1, -- Fallowstone Hall Wayshrine
    [118] = 1, -- Nimalten Wayshrine
    [121] = 5, -- Skywatch Wayshrine
    [131] = 4, -- Hollow City Wayshrine
    [135] = 1, -- Haj Uxith Wayshrine
    [138] = 1, -- Port Hunding Wayshrine
    [142] = 2, -- Mistral Wayshrine
    [143] = 5, -- Marbruk Wayshrine
    [144] = 1, -- Vinedusk Wayshrine
    [146] = 1, -- Court of Contempt Wayshrine
    [147] = 1, -- Greenheart Wayshrine
    [151] = 1, -- Verrant Morass Wayshrine
    [159] = 1, -- Dune Wayshrine
    [162] = 5, -- Rawl'kha Wayshrine
    [167] = 1, -- Southpoint Wayshrine
    [168] = 1, -- Cormount Wayshrine
    [172] = 1, -- Bleakrock Wayshrine
    [173] = 1, -- Dhalmora Wayshrine
    [175] = 1, -- Firsthold Wayshrine
    [177] = 1, -- Vulkhel Guard Wayshrine
    [181] = 1, -- Stonetooth Wayshrine
    [214] = 7, -- Elden Root Wayshrine
    [220] = 7, -- Belkarth Wayshrine
    [240] = 4, -- Morkul Plain Wayshrine
    [244] = 6, -- Orsinium Wayshrine
    [251] = 3, -- Anvil Wayshrine
    [252] = 3, -- Kvatch Wayshrine
    [255] = 7, -- Abah's Landing Wayshrine
    [275] = 3, -- Balmora Wayshrine
    [281] = 3, -- Sadrith Mora Wayshrine
    [284] = 6, -- Vivec City Wayshrine
    [337] = 6, -- Brass Fortress Wayshrine
    [350] = 3, -- Shimmerene Wayshrine
    [355] = 6, -- Alinor Wayshrine
    [356] = 3, -- Lillandril Wayshrine
    [374] = 6, -- Lilmoth Wayshrine
    [382] = 6, -- Rimmen Wayshrine
    [402] = 6, -- Senchal Wayshrine
    [421] = 6, -- Solitude Wayshrine
    [449] = 6, -- Markarth Wayshrine 
    [458] = 6, -- Leyawiin Wayshrine
	[493] = 6, -- Fargrave Wayshrine
    [513] = 6, -- Gonfalon Square Wayshrine
    [529] = 6, -- Vastyr Wayshrine
	[536] = 6, -- Necrom Wayshrine
	[558] = 6, -- Skingrad City Wayshrine
}

function Locs:addTraderCounts()
    for i = 1, #self.nodes do
        local traders = trader_counts[self.nodes[i].nodeIndex]
        self.nodes[i].traders = traders
        if traders ~= nil and traders > 0 then
            self.nodes[i].suffix = "|t23:23:/esoui/art/icons/servicemappins/servicepin_guildkiosk.dds:inheritcolor|t"
        end
    end
end

MapSearch.Locations = Locs
