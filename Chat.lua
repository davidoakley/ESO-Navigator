local Nav = Navigator
local Chat = Nav.Chat or {
    lsc = nil,
    AutoCompleteProvider = nil,
    result = nil
}

function Chat:Init()
    self.lsc = LibSlashCommander
    if not self.lsc then
        return
    end

    local command = self.lsc:Register()
    command:AddAlias(Nav.saved.tpCommand)
    command:SetCallback(function(input) self:TP(input) end)
    command:SetDescription(GetString(NAVIGATOR_SLASH_DESCRIPTION))

    ---@class Chat.AutoCompleteProvider
    Chat.AutoCompleteProvider = LibSlashCommander.AutoCompleteProvider:Subclass()

    function Chat.AutoCompleteProvider:New()
        return Chat.lsc.AutoCompleteProvider.New(self)
    end

    function Chat.AutoCompleteProvider:GetResultList()
        local zoneList = Nav.Locations:getZoneList()
        local list = {}
        for i = 1, #zoneList do
            list[zoneList[i].name] = zoneList[i].name
        end
        Nav.log("Chat.AutoCompleteProvider:GetResultList: "..#list)
        return list
    end

    command:SetAutoComplete(self.AutoCompleteProvider:New())

    command.GetAutoCompleteResults = function(_, text)
        if text:sub(1, 1) == "*" then
            Chat.result = nil
            return {}
        end

        local result = Chat:Search(text)

        local results = result and { [result.name] = result.name } or {}

        return results
    end

    self.command = command
end

function Chat:Search(text)
    local searchResult
    self.search = text

    if text:sub(1, 1) == "@" then
        if #text >= 2 then
            searchResult = Nav.Search:Run(text:sub(2), Nav.FILTER_PLAYERS)
        else
            searchResult = {}
        end
    else
        searchResult = Nav.Search:Run(text, Nav.FILTER_NONE)
    end

    if #searchResult >= 1 then
        self.result = searchResult[1]
    end

    return self.result
end

function Chat:TP(text)
    if text == "*logon" then
        Nav.saved.loggingEnabled = true
        CHAT_SYSTEM:AddMessage("Logging enabled")
        return
    elseif text == "*logoff" then
        Nav.saved.loggingEnabled = false
        CHAT_SYSTEM:AddMessage("Logging disabled")
        return
    elseif text == "*mapinfo" then
        local mapId = GetCurrentMapId()
        local _, mapType, _, zoneIndex, _ = GetMapInfoById(mapId)
        local zoneId = GetZoneId(zoneIndex)
        CHAT_SYSTEM:AddMessage(string.format("Current Map: mapId %d, zoneIndex %d, zoneId %d type %d", mapId, zoneIndex, zoneId, mapType))
        return
    end

    local result = self.result or self:Search(text)

    if not result then
        CHAT_SYSTEM:AddMessage(GetString(NAVIGATOR_HINT_NORESULTS))
        return
    end

    if self.search and self.search:sub(1, 1) == "@" then
        if result.poiType == Nav.POI_FRIEND then
            JumpToFriend(result.userID)
        elseif result.poiType == Nav.POI_GUILDMATE then
            JumpToGuildMember(result.userID)
        else
            CHAT_SYSTEM:AddMessage(zo_strformat(GetString(NAVIGATOR_CANNOT_TRAVEL_TO_PLAYER), result.userID))
        end
        return
    end

    if result.JumpToNode then
        result:JumpToNode()
        return
    elseif result.zoneId then
        local node = Nav.Players:GetPlayerInZone(result.zoneId)
        if not node then
            CHAT_SYSTEM:AddMessage(zo_strformat(GetString(NAVIGATOR_NO_PLAYER_IN_ZONE), result.zoneName))
            return
        end

        -- local userID, poiType, zoneId, zoneName = node.userID, node.poiType, node.zoneId, node.zoneName

        CHAT_SYSTEM:AddMessage(zo_strformat(GetString(NAVIGATOR_TRAVELING_TO_ZONE_VIA_PLAYER), node.zoneName, node.userID))
        SCENE_MANAGER:Hide("worldMap")

        if node.poiType == Nav.POI_FRIEND then
            JumpToFriend(node.userID)
        elseif node.poiType == Nav.POI_GUILDMATE then
            JumpToGuildMember(node.userID)
        end
    else
        -- CHAT_SYSTEM:AddMessage("Sorry, I wasn't able to process that result")
    end
end

Nav.Chat = Chat