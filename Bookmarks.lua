local Nav = Navigator

--- @class Bookmark
local Bookmark = {}

function Bookmark:New(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function Bookmark:GetNode()
    if self.nodeIndex then
        local nodeIndex = self.nodeIndex
        if nodeIndex and Nav.Locations:IsHarborage(nodeIndex) then
            nodeIndex = Nav.Locations:GetHarborage()
        end
        local node = Nav.Locations:GetNode(nodeIndex)
        return node
    elseif self.poi then
        local node = Nav.Locations:GetPOI(self.poi.zoneId, self.poi.poiIndex, true)
        --Nav.log("Bookmarks:getBookmarks(%d): zone %d poi %d -> %s", i, self.poi.zoneId or -1, self.poi.poiIndex or -1, node and "found" or "missing")
        return node
    elseif self.zoneId then
        local zone = Nav.Locations:getZone(self.zoneId)
        if zone then
            local node = Nav.Utils.shallowCopy(zone)
            node.mapId = self.mapId
            return node
        end
    elseif self.playerHouse then -- Travel to primary residence
        local node = Nav.PlayerHouseNode:New({
            name = self.playerHouse,
            userID = self.playerHouse,
            suffix = self.nickname and zo_strformat(GetString(SI_TOOLTIP_COLLECTIBLE_NICKNAME), self.nickname)
                    or GetString(SI_HOUSING_PRIMARY_RESIDENCE_HEADER),
            known = true
        })
        return node
    end

    Nav.log("Bookmark:GetNode: failed to create node")
    return nil
end


--- @class Bookmarks
local Bookmarks = Nav.Bookmarks or {
}

function Bookmarks:init()
    Nav.saved.bookmarks = Nav.saved.bookmarks or {}
    Bookmarks.hasRunFixup = false
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
    elseif entry.playerHouse then
        local userID = entry.playerHouse
        for i = 1, #list do
            if userID == list[i].playerHouse then
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
    if not self.hasRunFixup then
        self:FixUp()
        self.hasRunFixup = true
    end

    local list = Nav.saved.bookmarks
    local results = {}

    for i = 1, #list do
        local entry = list[i]
        local bookmark = Bookmark:New(entry)
        bookmark.bookmarkIndex = i
        table.insert(results, bookmark)
        --[[
        if entry.nodeIndex then
            local nodeIndex = entry.nodeIndex
            if nodeIndex and Nav.Locations:IsHarborage(nodeIndex) then
                nodeIndex = Nav.Locations:GetHarborage()
            end
            local node = Nav.Locations:GetNode(nodeIndex)
            table.insert(results, node)
        elseif entry.poi then
            local node = Nav.Locations:GetPOI(entry.poi.zoneId, entry.poi.poiIndex, true)
            --Nav.log("Bookmarks:getBookmarks(%d): zone %d poi %d -> %s", i, entry.poi.zoneId or -1, entry.poi.poiIndex or -1, node and "found" or "missing")
            table.insert(results, node)
        elseif entry.zoneId then
            local zone = Nav.Locations:getZone(entry.zoneId)
            if zone then
                local node = Nav.Utils.shallowCopy(zone)
                node.mapId = entry.mapId
                table.insert(results, node)
            end
        elseif entry.playerHouse then -- Travel to primary residence
            local node = Nav.PlayerHouseNode:New({
                name = entry.playerHouse,
                userID = entry.playerHouse,
                suffix = entry.nickname and zo_strformat(GetString(SI_TOOLTIP_COLLECTIBLE_NICKNAME), entry.nickname)
                                         or GetString(SI_HOUSING_PRIMARY_RESIDENCE_HEADER),
                known = true
            })
            table.insert(results, node)
        end
        --]]
    end

    return results
end

function Bookmarks:GetAlias(node)
    local i = self:getIndex(node)
    if i then
        return Nav.saved.bookmarks[i].alias
    end
    return nil
end

function Bookmarks:SetAlias(bookmark, text)
    local i = self:getIndex(bookmark)
    if i then
        if text == "" then
            Nav.saved.bookmarks[i].alias = nil
        else
            Nav.saved.bookmarks[i].alias = text
        end
    else
        Nav.log("Bookmarks:SetAlias: Can't find bookmark")
    end
end

--- Update the saved bookmarks table to fix key names and remove unrecognisable entries
function Bookmarks:FixUp()
    local i = 1
    while i <= #Nav.saved.bookmarks do
        local entry = Nav.saved.bookmarks[i]

        if entry.userID and entry.action == "house" then
            -- Other player's house - recreate
            Nav.saved.bookmarks[i] = { playerHouse = entry.userID }
        elseif entry.zoneId and entry.poiIndex then
            -- POI - recreate
            Nav.saved.bookmarks[i] = { poi = { zoneId = entry.zoneId, poiIndex = entry.poiIndex } }
        elseif entry.zoneId or entry.nodeIndex or entry.keepId or entry.playerHouse or entry.poi then
            -- Existing recognised node
        else
            -- Unrecognised entry - remove!
            Nav.saved.bookmarks[i] = nil
        end

        local bookmark = Nav.saved.bookmarks[i] and Bookmark:New(Nav.saved.bookmarks[i])
        if bookmark and bookmark:GetNode() then
            i = i + 1
        else
            Nav.log("Bookmarks:FixUp(%d): unknown!", i)
            table.remove(Nav.saved.bookmarks, i)
        end
    end
end

Nav.Bookmarks = Bookmarks