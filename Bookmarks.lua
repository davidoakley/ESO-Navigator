local Nav = Navigator
local Bookmarks = Nav.Bookmarks or {
    list = {},
}

function Bookmarks:init()
    self.list = Nav.saved.bookmarks or {}
end

--[[ function Bookmarks:importOldBookmarks()
    local nodes = Nav.saved.bookmarkNodes
    local list = {}

    for i = 1, #nodes do
        table.insert(list, { nodeIndex = nodes[i] })
    end

    Nav.saved.bookmarks = list
end -- ]]

function Bookmarks:getIndex(entry)
    if entry.nodeIndex then
        local nodeIndex = entry.nodeIndex
        if nodeIndex == 211 or nodeIndex == 212 then
            -- Always refer to The Harborage as index 210
            nodeIndex = 210
        end
        for i = 1, #self.list do
            if nodeIndex == self.list[i].nodeIndex then
                return i
            end
        end
    elseif entry.zoneId then
        local zoneId = entry.zoneId
        for i = 1, #self.list do
            if zoneId == self.list[i].zoneId then
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

    table.insert(self.list, entry)
    -- Nav.log("Bookmarks:add("..nodeIndex..")")
    self:save()
end

function Bookmarks:remove(entry)
    local i = self:getIndex(entry)
    if i then
        table.remove(self.list, i)
        Nav.log("Bookmarks:remove("..i..")")
        self:save()    
    end
end


function Bookmarks:contains(entry)
    return self:getIndex(entry) ~= nil
end

function Bookmarks:save()
    Nav.saved.bookmarks = self.list
end

function Bookmarks:getBookmarks()
    local results = {}
    local nodeMap = Nav.Locations:getNodeMap()

    for i = 1, #self.list do
        local entry = self.list[i]
        if entry.nodeIndex and nodeMap then
            local nodeIndex = entry.nodeIndex
            if Nav.Locations:IsHarborage(nodeIndex) then
                nodeIndex = Nav.Locations:GetHarborage()
            end
            local node = Nav.Utils.shallowCopy(nodeMap[nodeIndex])
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
                local node = Nav.Utils.shallowCopy(zone)
                node.isBookmark = true
                table.insert(results, node)
            end
        elseif entry.userID then -- Travel to primary residence
            local node = {
                name = entry.userID,
                userID = entry.userID,
                poiType = Nav.POI_PLAYERHOUSE,
                icon = "esoui/art/lfg/gamepad/lfg_menuicon_housetours.dds",
                suffix = entry.nickname and zo_strformat(GetString(SI_TOOLTIP_COLLECTIBLE_NICKNAME), entry.nickname)
                                         or GetString(SI_HOUSING_PRIMARY_RESIDENCE_HEADER),
                known = true,
                isBookmark = true
            }
            table.insert(results, node)
        end
    end

    return results
end

Nav.Bookmarks = Bookmarks