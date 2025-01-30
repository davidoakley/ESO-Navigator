local Nav = Navigator
local Chat = Nav.Chat or {
    lsc = nil,
    AutoCompleteProvider = nil
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
        local results = {}

        local searchResult

        if text:sub(1, 1) == "*" then
            return {}
        end
        if text:sub(1, 1) == "@" then
            if #text >= 2 then
                searchResult = Nav.Search.run(text:sub(2), Nav.FILTER_PLAYERS)
            else
                searchResult = {}
            end
        else
            searchResult = Nav.Search.run(text, Nav.FILTER_NONE)
        end

        local count = (#searchResult <= 1) and #searchResult or 1
        for i = 1, count do
            local listEntry = searchResult[i]
            results[listEntry.name] = listEntry.name
        end

        return results
    end

    self.command = command
end

function Chat:TP(text)
    local Locs = Nav.Locations

    if text == "*logon" then
        Nav.saved.loggingEnabled = true
        CHAT_SYSTEM:AddMessage("Logging enabled")
        return
    elseif text == "*logoff" then
        Nav.saved.loggingEnabled = false
        CHAT_SYSTEM:AddMessage("Logging disabled")
        return
    end

    local searchResult = Nav.Search.run(text, Nav.FILTER_NONE)
    if #searchResult == 0 then
        CHAT_SYSTEM:AddMessage(GetString(SI_JUMPRESULT20))
        return
    end

    local data = searchResult[1]

    if data.nodeIndex then
        Nav.MapTab:jumpToNode(data)
        return
    end

    local zoneId = data.zoneId
    if zoneId then
        local node = Locs:getPlayerInZone(zoneId)
        if not node then
            CHAT_SYSTEM:AddMessage(zo_strformat(GetString(NAVIGATOR_NO_PLAYER_IN_ZONE), data.zoneName))
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