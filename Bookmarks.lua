local MS = MapSearch
local Bookmarks = MS.Bookmarks or {
    nodes = {},
}
local logger = MS.logger

function Bookmarks:init()
    self.nodes = MS.saved.bookmarkNodes or {}
end

function Bookmarks:add(nodeIndex)
    table.insert(self.nodes, nodeIndex)
    logger:Debug("Bookmarks:add("..nodeIndex..")")
    self:save()
end

function Bookmarks:remove(nodeIndex)
    for i = 1, #self.nodes do
        if self.nodes[i] == nodeIndex then
            table.remove(self.nodes, i)
            logger:Debug("Bookmarks:remove("..nodeIndex..")")
            self:save()
            return
        end
    end
end

function Bookmarks:contains(nodeIndex)
    for i = 1, #self.nodes do
        if self.nodes[i] == nodeIndex then return true end
    end
    return false
end

function Bookmarks:save()
    MS.saved.bookmarkNodes = self.nodes
end

function Bookmarks:getBookmarks()
    local results = {}
    local nodeMap = MS.Locations:getNodeMap()

    if nodeMap ~= nil then
        for i = 1, #self.nodes do
            local node = nodeMap[self.nodes[i]]
            local traders = MS.Data.traderCounts[self.nodes[i]]
            if traders and traders > 0 then
                node.traders = traders
            end
            table.insert(results, node)
        end
    end

    return results
end

MS.Bookmarks = Bookmarks