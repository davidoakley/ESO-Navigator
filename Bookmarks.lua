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
    elseif entry.poiIndex then
        for i = 1, #list do
            if entry.poiIndex == list[i].poiIndex and entry.zoneId == list[i].zoneId then
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
    elseif entry.keepId then
        local keepId = entry.keepId
        for i = 1, #list do
            if keepId == list[i].keepId then
                return i
            end
        end
    elseif entry.zoneId and not entry.keepId then
        local zoneId = entry.zoneId
        for i = 1, #list do
            if zoneId == list[i].zoneId and not list[i].poiIndex and not list[i].keepId then
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

function Bookmarks:Move(node, offset)
    local index = self:getIndex(node) --node = Nav.saved.bookmarks[index]
    if index then
        table.remove(Nav.saved.bookmarks, index)
        table.insert(Nav.saved.bookmarks, index + offset, node)
    else
        Nav.logWarning("Bookmarks:Move: can't find index for '%s'", node.name)
    end
end

function Bookmarks:getBookmarks()
    local list = Nav.saved.bookmarks
    local results = {}

    for i = 1, #list do
        local entry = list[i]
        if entry.nodeIndex then
            local nodeIndex = entry.nodeIndex
            if nodeIndex and Nav.Locations:IsHarborage(nodeIndex) then
                nodeIndex = Nav.Locations:GetHarborage()
            end
            local node = Nav.Locations:GetNode(nodeIndex)
            table.insert(results, node)
        elseif entry.poiIndex then
            local node = Nav.Locations:GetPOI(entry.zoneId, entry.poiIndex)
            table.insert(results, node)
        elseif entry.zoneId then
            local zone = Nav.Locations:getZone(entry.zoneId)
            if zone then
                local node = Nav.Utils.shallowCopy(zone)
                node.mapId = entry.mapId
                table.insert(results, node)
            end
        elseif entry.userID then -- Travel to primary residence
            local node = Nav.PlayerHouseNode:New({
                name = entry.userID,
                userID = entry.userID,
                action = entry.action,
                suffix = entry.nickname and zo_strformat(GetString(SI_TOOLTIP_COLLECTIBLE_NICKNAME), entry.nickname)
                                         or GetString(SI_HOUSING_PRIMARY_RESIDENCE_HEADER),
                known = true
            })
            table.insert(results, node)
        end
    end

    return results
end

Nav.Bookmarks = Bookmarks