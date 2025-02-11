local Nav = Navigator
local Bookmarks = Nav.Bookmarks or {
}

function Bookmarks:init()
    Nav.saved.bookmarks = Nav.saved.bookmarks or {}
end

function Bookmarks:getIndex(entry)
    local list = Nav.saved.bookmarks

    if entry.nodeIndex then
        local nodeIndex = entry.nodeIndex
        if nodeIndex == 211 or nodeIndex == 212 then
            -- Always refer to The Harborage as index 210
            nodeIndex = 210
        end
        for i = 1, #list do
            if nodeIndex == list[i].nodeIndex then
                return i
            end
        end
    elseif entry.userID then
        local userID = entry.userID
        for i = 1, #list do
            if userID == list[i].userID and entry.action == list[i].action then
                return i
            end
        end
    elseif entry.zoneId then
        local zoneId = entry.zoneId
        for i = 1, #list do
            if zoneId == list[i].zoneId then
                return i
            end
        end
    end
    return nil
end

function Bookmarks:add(entry)
    if entry.nodeIndex and (entry.nodeIndex == 211 or entry.nodeIndex == 212) then
        -- Always store The Harborage as index 210
        entry.nodeIndex = 210
    end

    table.insert(Nav.saved.bookmarks, entry)
end

function Bookmarks:remove(entry)
    local i = self:getIndex(entry)
    if i then
        table.remove(Nav.saved.bookmarks, i)
    end
end


function Bookmarks:contains(entry)
    return self:getIndex(entry) ~= nil
end

function Bookmarks:getBookmarks()
    local list = Nav.saved.bookmarks
    local results = {}
    --local nodeMap = Nav.Locations:getNodeMap()

    for i = 1, #list do
        local entry = list[i]
        local nodeIndex = entry.nodeIndex
        if nodeIndex and Nav.Locations:IsHarborage(nodeIndex) then
            nodeIndex = Nav.Locations:GetHarborage()
        end
        local node = nodeIndex and Nav.Locations:GetNode(nodeIndex)
        if node then
            --local node = Nav.Utils.shallowCopy(nodeMap[nodeIndex])
            node.known = Nav.Locations:isKnownNode(nodeIndex)
            local traders = Nav.Data.traderCounts[nodeIndex]
            if traders and traders > 0 then
                node.traders = traders
            end
            node.isBookmark = true
            table.insert(results, node)
        elseif entry.zoneId then
            local zone = Nav.Locations:getZone(entry.zoneId)
            if zone then
                node = Nav.Utils.shallowCopy(zone)
                node.mapId = entry.mapId
                node.isBookmark = true
                table.insert(results, node)
            end
        elseif entry.userID then -- Travel to primary residence
            node = Nav.PlayerHouseNode:New({
                name = entry.userID,
                userID = entry.userID,
                icon = "Navigator/media/house_player.dds",
                suffix = entry.nickname and zo_strformat(GetString(SI_TOOLTIP_COLLECTIBLE_NICKNAME), entry.nickname)
                                         or GetString(SI_HOUSING_PRIMARY_RESIDENCE_HEADER),
                known = true,
                isBookmark = true
            })
            table.insert(results, node)
        end
    end

    return results
end

Nav.Bookmarks = Bookmarks