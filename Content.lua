---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by david.
--- DateTime: 24/02/2025 07:29
---

local Nav = Navigator


local function nameComparison(x, y)
    return Nav.SortName(x.name) < Nav.SortName(y.name)
end


---@class Category
local Category = {}

function Category:New(o)
    o = o or {
        id = "",
        title = "",
        list = {},
        emptyHint = nil,
        maxEntries = nil,
        sort = nil
    }
    setmetatable(o, self)
    self.__index = self
    return o
end


--- @class Content
local Content = {}

function Content:New()
    local o = {
        categories = {}
    }
    setmetatable(o, self)
    self.__index = self
    return o
end

function Content:AddGroupCategory()
    local group = Nav.Players:GetGroupList()
    if #group > 0 then
        table.insert(self.categories, {
            id = "group",
            title = SI_MAIN_MENU_GROUP,
            list = group,
            sort = Nav.Players.GroupComparison
        })
    end
end

function Content:AddBookmarksCategory()
    table.insert(self.categories, {
        id = "bookmarks",
        title = NAVIGATOR_CATEGORY_BOOKMARKS,
        list = Nav.Bookmarks:getBookmarks(),
        emptyHint = NAVIGATOR_HINT_NOBOOKMARKS
    })
end

function Content:AddRecentsCategory()
    local recentCount = Nav.saved.recentsCount
    if recentCount > 0 then
        table.insert(self.categories, {
            id = "recents",
            title = NAVIGATOR_CATEGORY_RECENT,
            list = Nav.Recents:getRecents(),
            emptyHint = NAVIGATOR_HINT_NORECENTS,
            maxEntries = recentCount
        })
    end
end

function Content:AddZoneCategory(zone)
    local list = Nav.Locations:GetNodeList(zone.zoneId, false, Nav.saved.listPOIs)
    table.sort(list, Nav.Node.WeightComparison)

    if Nav.jumpState == Nav.JUMPSTATE_WORLD and zone.zoneId ~= Nav.ZONE_CYRODIIL and
       zone.zoneId ~= Nav.ZONE_IMPERIALCITY and zone.zoneId ~= Nav.ZONE_IMPERIALSEWERS then
        local node = Nav.JumpToZoneNode:New(Nav.Utils.shallowCopy(zone))
        local playerInfo = Nav.Players:GetPlayerInZone(zone.zoneId)
        node.known = playerInfo ~= nil
        table.insert(list, 1, node)
    end

    local title = zone.name
    local tagString = zone:CreateTagListString(false, false)
    if tagString then
        title = title .. "  " .. tagString
    end

    table.insert(self.categories, {
        id = "zone",
        title = title,
        list = list
    })
end

function Content:AddCyrodiilCategories()
    local list = Nav.Locations:GetNodeList(Nav.ZONE_CYRODIIL, false, Nav.saved.listPOIs)
    local zone = Nav.Locations.zones[Nav.ZONE_CYRODIIL]

    local allianceNodes = {}
    allianceNodes[ALLIANCE_ALDMERI_DOMINION] = {}
    allianceNodes[ALLIANCE_DAGGERFALL_COVENANT] = {}
    allianceNodes[ALLIANCE_EBONHEART_PACT] = {}
    local poiNodes = {}

    for i = 1, #list do
        local node = list[i]
        if node.alliance and allianceNodes[node.alliance] and
           (not node.icon:find("borderKeep") or node.alliance == Nav.currentAlliance) then
            table.insert(allianceNodes[node.alliance], node)
        elseif node.alliance and not node.icon:find("borderKeep") then
            table.insert(poiNodes, node)
        end
    end

    for _, poiNode in pairs(zone.pois) do
        table.insert(poiNodes, poiNode)
    end

    local pa = Nav.currentAlliance
    local allianceList =
            (pa == ALLIANCE_ALDMERI_DOMINION and { ALLIANCE_ALDMERI_DOMINION, ALLIANCE_DAGGERFALL_COVENANT, ALLIANCE_EBONHEART_PACT }) or
            (pa == ALLIANCE_DAGGERFALL_COVENANT and { ALLIANCE_DAGGERFALL_COVENANT, ALLIANCE_EBONHEART_PACT, ALLIANCE_ALDMERI_DOMINION }) or
            (pa == ALLIANCE_EBONHEART_PACT and { ALLIANCE_EBONHEART_PACT, ALLIANCE_ALDMERI_DOMINION, ALLIANCE_DAGGERFALL_COVENANT })

    for i = 1, #allianceList do
        local alliance = allianceList[i]
        table.sort(allianceNodes[alliance], Nav.Node.WeightComparison)
        table.insert(self.categories, {
            id = string.format("alliance_%d", alliance),
            title = Nav.Utils.FormatSimpleName(GetAllianceName(alliance)),
            list = allianceNodes[alliance]
        })
    end

    table.sort(poiNodes, Nav.Node.WeightComparison)
    table.insert(self.categories, {
        id = "pois",
        title = NAVIGATOR_CATEGORY_POI,
        list = poiNodes
    })
end


--- @class BasicContent
local BasicContent = Content:New()

function BasicContent:New()
    local o = {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function BasicContent:Compose()
    self.categories = {}

    self:AddGroupCategory()
    self:AddBookmarksCategory()
    self:AddRecentsCategory()
end


--- @class ZoneContent
local ZoneContent = Content:New()

function ZoneContent:New(zone)
    local o = {
        zone = zone
    }
    setmetatable(o, self)
    self.__index = self
    return o
end

function ZoneContent:Compose()
    self.categories = {}

    self:AddGroupCategory()
    self:AddBookmarksCategory()
    self:AddRecentsCategory()
    self:AddZoneCategory(self.zone)
end


--- @class CyrodiilContent
local CyrodiilContent = Content:New()

function CyrodiilContent:Compose()
    self.categories = {}

    self:AddGroupCategory()

    if Nav.jumpState == Nav.JUMPSTATE_WORLD or Nav.jumpState == Nav.JUMPSTATE_WAYSHRINE then
        self:AddBookmarksCategory()
        self:AddRecentsCategory()
    end

    self:AddCyrodiilCategories()
end


--- @class ZoneListContent
local ZoneListContent = Content:New()

function ZoneListContent:AddZoneListCategory()
    local list = Nav.Locations:GetZoneList()
    table.sort(list, nameComparison)

    table.insert(self.categories, {
        id = "zones",
        title = NAVIGATOR_CATEGORY_ZONES,
        list = list
    })
end

function ZoneListContent:Compose()
    self.categories = {}

    self:AddGroupCategory()
    self:AddBookmarksCategory()
    self:AddRecentsCategory()
    self:AddZoneListCategory()
end


---@class HousesContent
local HousesContent = Content:New()

function HousesContent:Compose(isSearching)
    self.categories = {}

    local list = Nav.Locations:GetHouseList(isSearching)
    local owned = Nav.Utils.GetFilteredArray(list, function(h) return h.owned end)
    local unowned = Nav.Utils.GetFilteredArray(list, function(h) return not h.owned end)

    table.insert(self.categories, {
        id = "houses",
        title = GetString("SI_COLLECTIBLEUNLOCKSTATE", COLLECTIBLE_UNLOCK_STATE_UNLOCKED_OWNED), --NAVIGATOR_SETTINGS_HOUSE_ACTIONS_NAME,
        list = owned,
        sort = Nav.Node.WeightComparison
    })

    table.insert(self.categories, {
        id = "houses",
        title = GetString("SI_COLLECTIBLEUNLOCKSTATE", COLLECTIBLE_UNLOCK_STATE_LOCKED), --NAVIGATOR_SETTINGS_HOUSE_ACTIONS_NAME,
        list = unowned,
        sort = Nav.Node.WeightComparison
    })
end


---@class PlayersContent
local PlayersContent = Content:New()

function PlayersContent:Compose()
    local list = Nav.Players:GetPlayerList(false)

    table.insert(self.categories, {
        id = "players",
        title = NAVIGATOR_MENU_PLAYERS,
        list = list,
        sort = Nav.Node.WeightComparison
    })
end


---@class ZonesContent
local ZonesContent = Content:New()

function ZonesContent:Compose()
    self.categories = {}

    local list = Nav.Locations:GetZoneList()

    table.insert(self.categories, {
        id = "zones",
        title = NAVIGATOR_SETTINGS_ZONE_ACTIONS_NAME,
        list = list,
        sort = Nav.Node.NameComparison
    })
end


---@class GuildTradersContent
local GuildTradersContent = Content:New()

function GuildTradersContent:Compose()
    self.categories = {}

    local list = Nav.Locations:GetTraderNodeList()

    table.insert(self.categories, {
        id = "traders",
        title = NAVIGATOR_MENU_GUILDTRADERS,
        list = list,
        sort = Nav.Node.TradersComparison
    })
end


---@class MapsContent
local MapsContent = Content:New()

function MapsContent:Compose()
    self.categories = {}

    local list = Nav.Locations:GetMapZones()

    table.insert(self.categories, {
        id = "maps",
        title = NAVIGATOR_MENU_TREASUREMAPS_SURVEYS,
        list = list,
        sort = Nav.Node.NameComparison
    })
end


---@class AllContent
local AllContent = Content:New()

function AllContent:New(showHidden)
    local o = { showHidden = showHidden }
    setmetatable(o, self)
    self.__index = self
    return o
end

function AllContent:Compose()
    self.categories = {}

    local list = Nav.Locations:GetNodeList(nil, true)
    Nav.Utils.tableConcat(list, Nav.Locations:GetZoneList(true))

    --table.sort(list, Nav.Node.WeightComparison)

    table.insert(self.categories, {
        id = "results",
        title = NAVIGATOR_CATEGORY_RESULTS,
        list = list
    })
end


---@class ContentBuilder
local ContentBuilder = {}

function ContentBuilder.Build(searchString, view)
    --local results = Nav.Search:Run(searchString or "", view)
    --local isSearching = #results > 0 or (searchString and searchString ~= "") or
    --        (view ~= Nav.VIEW_NONE and view == Nav.VIEW_ALL)
    local isSearching = (searchString and searchString ~= "")

    local content

    if view == Nav.VIEW_HOUSES then
        content = HousesContent:New()
    elseif view == Nav.VIEW_PLAYERS then
        content = PlayersContent:New()
    elseif view == Nav.VIEW_ZONES then
        content = ZonesContent:New()
    elseif view == Nav.VIEW_TRADERS then
        content = GuildTradersContent:New()
    elseif view == Nav.VIEW_TREASURE then
        content = MapsContent:New()
    elseif isSearching then
        content = AllContent:New()
    else
        local zone = Nav.Locations:getCurrentMapZone()
        if zone then
            if zone.zoneId == Nav.ZONE_TAMRIEL then
                content = ZoneListContent:New()
            elseif zone.zoneId == Nav.ZONE_CYRODIIL then
                content = CyrodiilContent:New()
            else
                content = ZoneContent:New(zone)
            end
        else
            content = BasicContent:New()
        end
    end

    if not content then
        content = ZoneListContent:New()
        Nav.logWarning("Content:Build: no content chosen")
    end
    content:Compose(isSearching)

    if isSearching then
        Nav.Search:FilterContent(content, searchString)
    end

    if not isSearching then
        for c = 1, #content.categories do
            if content.categories[c].sort then
                --local comparison = (not isSearching) and content.categories[c].sort or Nav.Utils.WeightComparison
                table.sort(content.categories[c].list, content.categories[c].sort)
            end
        end
    end

    return content
end


Nav.Category = Category
Nav.ContentBuilder = ContentBuilder
Nav.BasicContent = BasicContent
Nav.ZoneContent = ZoneContent
Nav.ZoneListContent = ZoneListContent
Nav.CyrodiilContent = CyrodiilContent
Nav.SearchContent = SearchContent
