local MS = MapSearch
local Bookmarks = MS.Bookmarks or {
    list = {},
}
local logger = MS.logger

function Bookmarks:init()
    self.list = MS.saved.bookmarks or {}
end

--[[ function Bookmarks:importOldBookmarks()
    local nodes = MS.saved.bookmarkNodes
    local list = {}

    for i = 1, #nodes do
        table.insert(list, { nodeIndex = nodes[i] })
    end

    MS.saved.bookmarks = list
end -- ]]

function Bookmarks:add(entry)
    if nodeIndex == 211 or nodeIndex == 212 then
        -- Always store The Harborage as index 210
        nodeIndex = 210
    end

    table.insert(self.list, entry)
    -- logger:Debug("Bookmarks:add("..nodeIndex..")")
    self:save()
end

function Bookmarks:removeNodeIndex(nodeIndex)
    for i = 1, #self.list do
        if self.list[i].nodeIndex == nodeIndex then
            table.remove(self.list, i)
            logger:Debug("Bookmarks:removeNodeIndex("..nodeIndex..")")
            self:save()
            return
        end
    end
end

function Bookmarks:containsNodeIndex(nodeIndex)
    if nodeIndex == 211 or nodeIndex == 212 then
        -- The Harborage is always stored as index 210
        nodeIndex = 210
    end

    for i = 1, #self.list do
        if self.list[i].nodeIndex == nodeIndex then return true end
    end
    return false
end

function Bookmarks:save()
    MS.saved.bookmarks = self.list
end

function Bookmarks:getBookmarks()
    local results = {}
    local nodeMap = MS.Locations:getNodeMap()

    if nodeMap ~= nil then
        for i = 1, #self.list do
            local entry = self.list[i]
            if entry.nodeIndex then
                local node = MS.Utils.shallowCopy(nodeMap[entry.nodeIndex])
                node.known = MS.Locations:isKnownNode(entry.nodeIndex)
                local traders = MS.Data.traderCounts[entry.nodeIndex]
                if traders and traders > 0 then
                    node.traders = traders
                end
                table.insert(results, node)
            end
        end
    end

    return results
end

MS.Bookmarks = Bookmarks