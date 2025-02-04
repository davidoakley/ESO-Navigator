local MT = Navigator_MapTab -- from XML
local Nav = Navigator
local Search = Nav.Search
local Utils = Nav.Utils

MT.filter = Nav.FILTER_NONE
MT.needsRefresh = false
MT.collapsedCategories = {}

function MT:queueRefresh()
    if not self.needsRefresh then
        self.needsRefresh = true
        if self.visible and not self.menuOpen then
            zo_callLater(function()
                if self.needsRefresh and self.visible and not self.menuOpen then
                    self:ImmediateRefresh()
                else
                    -- Nav.log("MT:queueRefresh: skipped")
                end
            end, 50)
            -- Nav.log("MT:queueRefresh: queued")
        else
            -- Nav.log("MT:queueRefresh: not queued")
        end
    end
end

function MT:ImmediateRefresh()
    -- Nav.log("MT:ImmediateRefresh")
    self:executeSearch(self.searchString, true)
    self.needsRefresh = false
end

function MT:layoutRow(rowControl, data, _)
	local name = data.name
    local tooltipText = data.tooltip
    local icon = data.icon
    local iconColour = data.colour and { data.colour:UnpackRGBA() } or
                       ((data.known and not data.disabled) and { 1.0, 1.0, 1.0, 1.0 } or { 0.51, 0.51, 0.44, 1.0 })

    if data.suffix ~= nil then
        name = name .. " |c82826F" .. data.suffix .. "|r"
    end

	if data.icon ~= nil then
        rowControl.icon:SetColor(unpack(iconColour))
		rowControl.icon:SetTexture(icon)
		rowControl.icon:SetHidden(false)
    else
		rowControl.icon:SetHidden(true)
	end

    rowControl.cost:SetHidden(data.isFree)

    rowControl.keybind:SetHidden(not data.isSelected)
    rowControl.bg:SetHidden(not data.isSelected)
    if data.isSelected then
        rowControl.label:SetAnchor(TOPRIGHT, rowControl.keybind, TOPLEFT, -4, -1)
    else
        rowControl.label:SetAnchor(TOPRIGHT, rowControl, TOPRIGHT, -4, 0)
    end

	rowControl.label:SetText(name)

	if data.isSelected and data.known and not data.disabled then
		rowControl.label:SetColor(ZO_SELECTED_TEXT:UnpackRGBA())
    elseif data.colour ~= nil and not data.disabled then
        Nav.colour = data.colour
		rowControl.label:SetColor(data.colour:UnpackRGBA())
    elseif data.known and not data.disabled then
		rowControl.label:SetColor(ZO_NORMAL_TEXT:UnpackRGBA())
    else
		rowControl.label:SetColor(0.51, 0.51, 0.44, 1.0)
	end

    rowControl:SetHandler("OnMouseEnter", function(rc)
        if tooltipText then
            ZO_Tooltips_ShowTextTooltip(rc, LEFT, tooltipText)
        end
    end)
    rowControl:SetHandler("OnMouseExit", function(_)
        ZO_Tooltips_HideTextTooltip()
        if data.isSelected and data.known and not data.disabled then
            rowControl.label:SetColor(ZO_SELECTED_TEXT:UnpackRGBA())
        end
    end )
end

function MT:showFilterControl(text)
    self.filterControl:SetHidden(false)
    self.filterControl:SetText("|u6:6::"..text.."|u")
    self.editControl:SetAnchor(TOPLEFT, self.filterControl, TOPRIGHT, 2, -1)
end

function MT:hideFilterControl()
    self.filterControl:SetHidden(true)
    self.editControl:SetAnchor(TOPLEFT, self.searchControl, TOPLEFT, 4, -1)
end

function MT:updateFilterControl()
    if self.filter == Nav.FILTER_NONE then
        self:hideFilterControl()
        return
    elseif self.filter == Nav.FILTER_PLAYERS then
        self:showFilterControl('Players')
    elseif self.filter == Nav.FILTER_HOUSES then
        self:showFilterControl('Houses')
    end
end

function MT:layoutCategoryRow(rowControl, data, _)
	rowControl.label:SetText(data.name)
end

function MT:layoutHintRow(rowControl, data, _)
	rowControl.label:SetText(data.hint or "-")
end

local function jumpToPlayer(node)
    local userID, poiType, zoneId, zoneName = node.userID, node.poiType, node.zoneId, node.zoneName

    Nav.Players:SetupPlayers()

    if not Nav.Players.players[userID] or Nav.Players.players[userID].zoneId ~= zoneId then
        -- Player has disappeared or moved!
        CHAT_SYSTEM:AddMessage(zo_strformat(GetString(NAVIGATOR_PLAYER_NOT_IN_ZONE), userID, zoneName))

        if Nav.Players.playerZones[zoneId] then
            node = Nav.Players.playerZones[zoneId]
            userID, poiType, zoneId, zoneName = node.userID, node.poiType, node.zoneId, node.zoneName
        else
            -- Eeek! Refresh the search results and finish
            MT:buildScrollList()
            return
        end
    end

    CHAT_SYSTEM:AddMessage(zo_strformat(GetString(NAVIGATOR_TRAVELING_TO_ZONE_VIA_PLAYER), zoneName, userID))
    SCENE_MANAGER:Hide("worldMap")

    if poiType == Nav.POI_FRIEND then
        JumpToFriend(userID)
    elseif poiType == Nav.POI_GUILDMATE then
        JumpToGuildMember(userID)
    end
end

function MT:jumpToNode(node)
    if not node.known or node.disabled then
        return
    end

    local isRecall = Nav.isRecall
	local nodeIndex,name = node.nodeIndex,node.originalName

    ZO_Dialogs_ReleaseDialog("FAST_TRAVEL_CONFIRM")
	ZO_Dialogs_ReleaseDialog("RECALL_CONFIRM")

    if node.poiType == Nav.POI_FRIEND or node.poiType == Nav.POI_GUILDMATE then
        jumpToPlayer(node)
        return
    end

	name = name or select(2, Nav.Wayshrine.Data.GetNodeInfo(nodeIndex)) -- just in case
	local id = (isRecall == true and "RECALL_CONFIRM") or "FAST_TRAVEL_CONFIRM"
	if isRecall == true then
		local _, timeLeft = GetRecallCooldown()
		if timeLeft ~= 0 then
			local text = zo_strformat(SI_FAST_TRAVEL_RECALL_COOLDOWN, name, ZO_FormatTimeMilliseconds(timeLeft, TIME_FORMAT_STYLE_DESCRIPTIVE, TIME_FORMAT_PRECISION_SECONDS))
		    ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NEGATIVE_CLICK, text)
			return
		end
	end
	ZO_Dialogs_ShowPlatformDialog(id, {nodeIndex = nodeIndex}, {mainTextParams = {name}})
end

local function weightComparison(x, y)
    if x.weight ~= y.weight then
        return x.weight > y.weight
    end
	return (x.barename or x.name) < (y.barename or y.name)
end

local function nameComparison(x, y)
	return (x.barename or x.name) < (y.barename or y.name)
end

local function addDeveloperTooltip(nodeData)
    local items = {
        "bareName='" .. (nodeData.barename or '-').."'",
        "searchName='" .. Utils.SearchName(nodeData.originalName or nodeData.name or '-').."'",
        "weight="..(nodeData.weight or 0)
    }
    if nodeData.nodeIndex then
        table.insert(items, "nodeIndex="..(nodeData.nodeIndex or "-"))
    end
    if nodeData.zoneId then
        table.insert(items, "zoneId="..(nodeData.zoneId or "-"))
    end
    if nodeData.tooltip then
        table.insert(items, 1, nodeData.tooltip)
    end

    nodeData.tooltip = table.concat(items, "; ")
end

local function buildCategoryHeader(scrollData, id, title, collapsed)
    title = tonumber(title) ~= nil and GetString(title) or title
    local recentEntry = ZO_ScrollList_CreateDataEntry(collapsed and 2 or 0, { id = id, name = title })
    table.insert(scrollData, recentEntry)
end

local function buildResult(listEntry, currentNodeIndex, isSelected)
    local nodeData = Utils.shallowCopy(listEntry)
    nodeData.isSelected = isSelected
    nodeData.dataIndex = currentNodeIndex

    -- Nav.log("%s: traders %d", nodeData.barename, nodeData.traders or 0)
    if listEntry.traders and listEntry.traders > 0 then
        if listEntry.traders >= 5 then
            nodeData.suffix = "|t20:23:Navigator/media/city_narrow.dds:inheritcolor|t"
        elseif listEntry.traders >= 2 then
            nodeData.suffix = "|t20:23:Navigator/media/town_narrow.dds:inheritcolor|t"
        end
        nodeData.suffix = (nodeData.suffix or "") .. "|t23:23:/esoui/art/icons/servicemappins/servicepin_guildkiosk.dds:inheritcolor|t"
    end

    if nodeData.bookmarked then --Nav.Bookmarks:contains(nodeData) then
        nodeData.suffix = (nodeData.suffix or "") .. "|t25:25:Navigator/media/bookmark.dds:inheritcolor|t"
    end

    if not nodeData.known and nodeData.nodeIndex then
        nodeData.tooltip = GetString(NAVIGATOR_NOT_KNOWN)
    end

    nodeData.isFree = true
    if Nav.isRecall and nodeData.known and nodeData.nodeIndex then -- and nodeData.poiType == Nav.POI_WAYSHRINE
        local _, timeLeft = GetRecallCooldown()

        if timeLeft == 0 then
            local currencyType = CURT_MONEY
            local currencyAmount = GetRecallCost(nodeData.nodeIndex)
            if currencyAmount > 0 then
                local formatType = ZO_CURRENCY_FORMAT_AMOUNT_ICON
                local currencyString = zo_strformat(SI_NUMBER_FORMAT, ZO_Currency_FormatKeyboard(currencyType, currencyAmount, formatType))
                nodeData.tooltip = string.format(GetString(SI_TOOLTIP_RECALL_COST) .. "%s", currencyString)
                nodeData.isFree = false
            end
        end
    end


    if Nav.isDeveloper then
        addDeveloperTooltip(nodeData)
    end

    return nodeData
end

local function buildList(scrollData, id, title, list, defaultString)
    local collapsed = MT.collapsedCategories[id] and true or false
    local hasFocus = MT.editControl:HasFocus()

    buildCategoryHeader(scrollData, id, title, collapsed)

    if collapsed then
        return
    elseif #list == 0 and defaultString then
        list = {{ hint = GetString(defaultString) }}
    end

    local currentNodeIndex = MT.resultCount

    for i = 1, #list do
        if list[i].hint then
            local entry = ZO_ScrollList_CreateDataEntry(3, { hint = list[i].hint })
            table.insert(scrollData, entry)
        else
            local isSelected = hasFocus and list[i].known and (currentNodeIndex == Nav.targetNode)
            local nodeData = buildResult(list[i], currentNodeIndex, isSelected)

            local entry = ZO_ScrollList_CreateDataEntry(1, nodeData)
            table.insert(scrollData, entry)

            currentNodeIndex = currentNodeIndex + 1
        end
    end

    MT.resultCount = currentNodeIndex
end

function MT:UpdateEditDefaultText()
	local searchString = self.editControl:GetText()
	if searchString == "" then
		-- reinstate default text
        local openTabBinding = ZO_Keybindings_GetHighestPriorityNarrationStringFromAction("NAVIGATOR_OPENTAB") or '-'
        local s = zo_strformat(self.editControl:HasFocus() and GetString(NAVIGATOR_SEARCH) or GetString(NAVIGATOR_SEARCH_KEYPRESS),
            openTabBinding)
		ZO_EditDefaultText_Initialize(self.editControl, s)
	else
		-- remove default text
		ZO_EditDefaultText_Disable(self.editControl)
	end
end

function MT:buildScrollList(keepScrollPosition)
    local scrollPosition = 0
    if keepScrollPosition then
        scrollPosition = ZO_ScrollList_GetScrollValue(self.listControl)
        -- Nav.log("MT:buildScrollList: pos=%d", scrollPosition)
    end

	ZO_ScrollList_Clear(self.listControl)

	self:UpdateEditDefaultText()

    local scrollData = ZO_ScrollList_GetDataList(self.listControl)

    local isSearching = #Nav.results > 0 or (self.searchString and self.searchString ~= "")
    MT.resultCount = 0
    if isSearching then
        buildList(scrollData, "results", NAVIGATOR_CATEGORY_RESULTS, Nav.results, NAVIGATOR_HINT_NORESULTS)
    else
        local group = Nav.Players:GetGroupList()
        if #group > 0 then
            buildList(scrollData, "group", SI_MAIN_MENU_GROUP, group)
        end

        local bookmarks = Nav.Bookmarks:getBookmarks()
        buildList(scrollData, "bookmarks", NAVIGATOR_CATEGORY_BOOKMARKS, bookmarks, NAVIGATOR_HINT_NOBOOKMARKS)

        local recentCount = Nav.saved.recentsCount
        local recents = Nav.Recents:getRecents(recentCount)
        buildList(scrollData, "recents", NAVIGATOR_CATEGORY_RECENT, recents, NAVIGATOR_HINT_NORECENTS)

        local zone = Nav.Locations:getCurrentMapZone()
        if zone and zone.zoneId == 2 then
            local list = Nav.Locations:getZoneList()
            table.sort(list, nameComparison)
            buildList(scrollData, "zones", NAVIGATOR_CATEGORY_ZONES, list)
        elseif zone then
            local list = Nav.Locations:getKnownNodes(zone.zoneId)

            if Nav.isRecall and zone.zoneId ~= Nav.ZONE_CYRODIIL then
                local playerInfo = Nav.Players:GetPlayerInZone(zone.zoneId)
                if playerInfo then
                    playerInfo.name = zo_strformat(GetString(NAVIGATOR_TRAVEL_TO_ZONE), zone.name)
                    -- playerInfo.suffix = "via " .. playerInfo.suffix
                    playerInfo.colour = ZO_SECOND_CONTRAST_TEXT
                else
                    playerInfo = {
                        name = GetString(NAVIGATOR_NO_TRAVEL_PLAYER),
                        barename = "",
                        zoneId = zone.zoneId,
                        zoneName = GetZoneNameById(zone.zoneId),
                        icon = "/esoui/art/crafting/crafting_smithing_notrait.dds",
                        poiType = Nav.POI_NONE,
                        known = false
                    }
                    end
                playerInfo.weight = 10.0 -- list this first!
                table.insert(list, playerInfo)
            end

            table.sort(list, weightComparison)
            buildList(scrollData, "results", zone.name, list)
        end
    end

	ZO_ScrollList_Commit(self.listControl)

    if keepScrollPosition then
        ZO_ScrollList_ScrollAbsolute(self.listControl, scrollPosition)
    elseif MT.resultCount > 0 then
        -- FIXME: this doesn't account for the headings
        ZO_ScrollList_ScrollDataIntoView(self.listControl, Nav.targetNode + 1, nil, true)
    end
end

function MT:executeSearch(searchString, keepTargetNode)
	local results

    MT.searchString = searchString

    results = Search:Run(searchString or "", MT.filter)

	Nav.results = results
    if not keepTargetNode or Nav.targetNode >= (MT.resultCount or 0) then
        -- Nav.log("executeSearch: reset targetNode keep=%d, oldTarget=%d, count=%d", keepTargetNode and 1 or 0, Nav.targetNode, (MT.resultCount or 0))
    	Nav.targetNode = 0
        keepTargetNode = false
    end

	MT:buildScrollList(keepTargetNode)
    MT:updateFilterControl()
end

function MT:getTargetDataIndex()
	local currentNodeIndex = 0

    local scrollData = ZO_ScrollList_GetDataList(self.listControl)

    for i = 1, #scrollData do
        if scrollData[i].typeId == 1 then -- wayshrine row
            if currentNodeIndex == Nav.targetNode then
                return i
            end
            currentNodeIndex = currentNodeIndex + 1
        end
    end

	return nil
end

function MT:getTargetNode()
    local i = self:getTargetDataIndex()

    if i then
        local scrollData = ZO_ScrollList_GetDataList(self.listControl)
        return scrollData[i].data
    end

    return nil
end

function MT:getNextCategoryFirstIndex()
    local scrollData = ZO_ScrollList_GetDataList(self.listControl)

    if #scrollData <= 2 then
        return -- nothing to find!
    end

    local currentIndex = self:getTargetDataIndex()
    local currentNodeIndex = Nav.targetNode + 1

    local i = currentIndex + 1
    local foundCategory = false

    while true do
        if scrollData[i].typeId == 1 then -- wayshrine row
            if (foundCategory and scrollData[i].data.known) or i == currentIndex then
                -- return the first entry after the category header
                -- Nav.log("Index %d node %d is result - returning", i, currentNodeIndex)
                return currentNodeIndex
            end
            -- Nav.log("Index %d node %d is result - incrementing", i, currentNodeIndex)
            currentNodeIndex = currentNodeIndex + 1
        elseif scrollData[i].typeId == 0 then -- category header
            -- Nav.log("Index %d node %d is category", i, currentNodeIndex)
            foundCategory = true
        end

        if i >= #scrollData then
            -- Nav.log("Wrapping at index %d node %d", i, currentNodeIndex)
            i = 1
            currentNodeIndex = 0
        else
            i = i + 1
        end
    end
end

function MT:init()
	Nav.log("MapTab:init")

	local _refreshing = false
	local _isDirty = true 
	
	self.isDirty = function()
		return _isDirty
	end
	
	self.setDirty = function()
		_isDirty = true 
	end
	
	self.refreshIfRequired = function(self,...)
		--df("RefreshIfRequired isDirty=%s refreshing=%s", tostring(_isDirty), tostring(_refreshing))
		if _isDirty == true and _refreshing == false then 
			_refreshing = true -- only allow one refresh at any one time
			self:refresh(...)
			_isDirty = false
			_refreshing = false
		end 
	end
	
end

local function getMapIdByZoneId(zoneId)
    if zoneId == 2 then -- Tamriel
        return 27
    elseif zoneId == 981 then -- Brass Fortress
        return 1348
    elseif zoneId == 1463 then -- The Scholarium
        return 2515
    else
        return GetMapIdByZoneId(zoneId)
    end
end

function MT:onTextChanged(editbox)
	local searchString = string.lower(editbox:GetText())
    if searchString == "z:" then
        local mapId = getMapIdByZoneId(2) -- Tamriel
        Nav.log("MT:onTextChanged mapId %d", mapId or -1)
        -- if mapId then
        WORLD_MAP_MANAGER:SetMapById(mapId)
        -- end
        MT.filter = Nav.FILTER_NONE
        editbox:SetText("")
        editbox.editTextChanged = false
        searchString = ""
    elseif searchString == "h:" then
        self.filter = Nav.FILTER_HOUSES
        editbox:SetText("")
        editbox.editTextChanged = false
        searchString = ""
    elseif searchString == '@' or searchString == "p:" then
        self.filter = Nav.FILTER_PLAYERS
        editbox.editTextChanged = false
        editbox:SetText("")
        searchString = ""
    else
        self.editControl.editTextChanged = true
    end

    self:executeSearch(searchString)
end

function MT:selectCurrentResult()
	local data = self:getTargetNode()
	if data then
		self:selectResult(nil, data, 1)
	end
end

function MT:nextResult()
    local known = false
    local startNode = Nav.targetNode
    repeat
    	Nav.targetNode = (Nav.targetNode + 1) % MT.resultCount
        local node = self:getTargetNode()
        if node and node.known then
            known = true
        end
    until known or Nav.targetNode == startNode
	self:buildScrollList()
end

function MT:previousResult()
    local known = false
    local startNode = Nav.targetNode
    repeat
        Nav.targetNode = Nav.targetNode - 1
        if Nav.targetNode < 0 then
            Nav.targetNode = MT.resultCount - 1
        end
        local node = self:getTargetNode()
        if node and node.known then
            known = true
        end
    until known or Nav.targetNode == startNode
	self:buildScrollList()
end

function MT:nextCategory()
    Nav.targetNode = self:getNextCategoryFirstIndex()
	self:buildScrollList()
end

function MT:previousCategory()
    -- Nav.targetNode = self:getPreviousCategoryFirstIndex()
	-- self:buildScrollList()
end

function MT:resetFilter()
	Nav.log("MT.resetFilter")
    self.filter = Nav.FILTER_NONE
    self:hideFilterControl()
    self:ImmediateRefresh()
	ZO_ScrollList_ResetToTop(self.listControl)
end

function MT:resetSearch()
	Nav.log("MT.resetSearch")
	self.editControl:SetText("")
    self.filter = Nav.FILTER_NONE
    self:hideFilterControl()
    self:ImmediateRefresh()

	--ZO_EditDefaultText_Initialize(editbox, GetString(FASTER_TRAVEL_WAYSHRINES_SEARCH))
	--ResetVisibility(listcontrol)
	ZO_ScrollList_ResetToTop(self.listControl)
end

local function showWayshrineMenu(owner, data)
	ClearMenu()

    local entry = {}
    if data.nodeIndex then
        entry.nodeIndex = data.nodeIndex
    elseif data.zoneId then
        entry.zoneId = data.zoneId
    else
        Nav.log("showWayshrineMenu: unrecognised data")
        return
    end

    local isPlayer = Nav.IsPlayer(data.poiType)

    if data.nodeIndex then
        if data.poiType == Nav.POI_HOUSE then
            local houseId = GetFastTravelNodeHouseId(data.nodeIndex)
            AddMenuItem(zo_strformat(GetString(SI_WORLD_MAP_ACTION_TRAVEL_TO_HOUSE_INSIDE), data.name), function()
                RequestJumpToHouse(houseId, false)
                zo_callLater(function() SCENE_MANAGER:Hide("worldMap") end, 10)
                ClearMenu()
            end)
            AddMenuItem(zo_strformat(GetString(SI_WORLD_MAP_ACTION_TRAVEL_TO_HOUSE_OUTSIDE), data.name), function()
                RequestJumpToHouse(houseId, true)
                zo_callLater(function() SCENE_MANAGER:Hide("worldMap") end, 10)
                ClearMenu()
            end)
        else
            local strId = (Nav.isRecall and data.poiType ~= Nav.POI_HOUSE) and SI_WORLD_MAP_ACTION_RECALL_TO_WAYSHRINE or SI_WORLD_MAP_ACTION_TRAVEL_TO_WAYSHRINE
            AddMenuItem(zo_strformat(GetString(strId), data.name), function()
                MT:jumpToNode(data)
                ClearMenu()
            end)
        end
        AddMenuItem(GetString(NAVIGATOR_MENU_SHOWONMAP), function()
            MT:PanToPOI(data, false)
            ClearMenu()
        end)
        AddMenuItem(GetString(NAVIGATOR_MENU_SETDESTINATION), function()
            MT:PanToPOI(data, true)
            ClearMenu()
        end)
    elseif data.zoneId and Nav.isRecall then
        AddMenuItem(zo_strformat(GetString(SI_WORLD_MAP_ACTION_TRAVEL_TO_WAYSHRINE), data.name), function()
            local node = Nav.Players:GetPlayerInZone(data.zoneId)
            if not node then
                ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.GENERAL_ALERT_ERROR, GetString(NAVIGATOR_NO_PLAYER_IN_ZONE), data.name)
                return
            end
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, GetString(NAVIGATOR_TRAVELING_TO_ZONE_VIA_PLAYER), node.zoneName, node.userID)
            zo_callLater(function() SCENE_MANAGER:Hide("worldMap") end, 10)
            if node.poiType == Nav.POI_FRIEND then
                JumpToFriend(node.userID)
            elseif node.poiType == Nav.POI_GUILDMATE then
                JumpToGuildMember(node.userID)
            end
            ClearMenu()
        end)
    end

    if isPlayer then
        if Nav.Players:IsGroupLeader() and data.poiType == Nav.POI_GROUPMATE then
            AddMenuItem(GetString(SI_GROUP_LIST_MENU_PROMOTE_TO_LEADER), function()
                GroupPromote(data.unitTag)
                --bookmarks:remove(entry)
                ClearMenu()
                MT.menuOpen = false
                MT:ImmediateRefresh()
            end)
        end
    else
        local bookmarks = Nav.Bookmarks
        if bookmarks:contains(entry) then
            AddMenuItem(GetString(NAVIGATOR_MENU_REMOVEBOOKMARK), function()
                bookmarks:remove(entry)
                ClearMenu()
                MT.menuOpen = false
                MT:ImmediateRefresh()
            end)
        else
            AddMenuItem(GetString(NAVIGATOR_MENU_ADDBOOKMARK), function()
                bookmarks:add(entry)
                ClearMenu()
                MT.menuOpen = false
                MT:ImmediateRefresh()
            end)
        end
    end

    MT.menuOpen = true
	ShowMenu(owner)
    SetMenuHiddenCallback(function()
        Nav.log("SetMenuHiddenCallback: Menu hidden")
        MT.menuOpen = false
        if MT.needsRefresh then
            MT:ImmediateRefresh()
        end
    end)
end

local function showGroupMenu(owner, data)
    ClearMenu()

    AddMenuItem(GetString(SI_GROUP_LEAVE), function()
        ZO_Dialogs_ShowDialog("GROUP_LEAVE_DIALOG")
        ClearMenu()
        MT.menuOpen = false
        MT:ImmediateRefresh()
    end)

    MT.menuOpen = true
    ShowMenu(owner)
    SetMenuHiddenCallback(function()
        Nav.log("SetMenuHiddenCallback: Menu hidden")
        MT.menuOpen = false
        if MT.needsRefresh then
            MT:ImmediateRefresh()
        end
    end)
end

function MT:PanToPOI(node, setWaypoint)
    local function panToPOI(zoneIndex, poiIndex)
        local normalizedX, normalizedZ = GetPOIMapInfo(zoneIndex, poiIndex)
        Nav.log("MT:PanToPOI: poiIndex=%d, %f,%f", poiIndex, normalizedX, normalizedZ)
        if setWaypoint then
            PingMap(MAP_PIN_TYPE_PLAYER_WAYPOINT, MAP_TYPE_LOCATION_CENTERED, normalizedX, normalizedZ)
        end

        local mapPanAndZoom = ZO_WorldMap_GetPanAndZoom()
        mapPanAndZoom:PanToNormalizedPosition(normalizedX, normalizedZ, false)
    end

    local targetMapId = node.mapId or getMapIdByZoneId(node.zoneId)
    local currentMapId = GetCurrentMapId()
    local targetZoneIndex = GetZoneIndex(node.zoneId)

    if targetMapId ~= currentMapId then
        WORLD_MAP_MANAGER:SetMapById(targetMapId)

        zo_callLater(function()
            panToPOI(targetZoneIndex, node.poiIndex)
        end, 100)
    else
        panToPOI(targetZoneIndex, node.poiIndex)
    end
end

function MT:selectResult(control, data, mouseButton)
    if mouseButton == 1 then
        if data.nodeIndex or data.userID then
            self:jumpToNode(data)
        elseif data.poiType == Nav.POI_ZONE then
            MT.filter = Nav.FILTER_NONE
            self.editControl:SetText("")

            local mapZoneId = Nav.Locations:getCurrentMapZoneId()
            local currentMapId = GetCurrentMapId()
            local mapId = data.mapId or getMapIdByZoneId(data.zoneId)
            Nav.log("selectResult: data.zoneId %d data.mapId %d mapZoneId %d mapId %d", data.zoneId, data.mapId or 0, mapZoneId, mapId)
            if data.zoneId ~= mapZoneId or (data.mapId and data.mapId ~= currentMapId) then
                Nav.log("selectResult: mapId %d", mapId or 0)
                if mapId then
                    WORLD_MAP_MANAGER:SetMapById(mapId)
                end
            end
        end
    elseif mouseButton == 2 then
        if data.nodeIndex or data.poiType == Nav.POI_ZONE or Nav.IsPlayer(data.poiType) then
            showWayshrineMenu(control, data)
        else
            Nav.log("selectResult: unhandled mb2; poiType=%d zoneId=%d", data.poiType or -1, data.zoneId or -1)
        end
    else
        Nav.log("selectResult: unhandled; poiType=%d zoneId=%d", data.poiType or -1, data.zoneId or -1)
    end
end

function MT:RowMouseUp(control, mouseButton, upInside)
	if upInside then
		local data = ZO_ScrollList_GetData(control)
        self:selectResult(control, data, mouseButton)
	end
end

function MT:CategoryRowMouseUp(control, mouseButton, upInside)
	if upInside then
        --Nav.log("MT:CategoryRowMouseUp %d %s", mouseButton, )
        local data = ZO_ScrollList_GetData(control)
        if mouseButton == 2 then
            if data.id == "group" then
                showGroupMenu(control, data)
            end
        else
            Nav.log("Toggling category %s", data.id)
            self.collapsedCategories[data.id] = not self.collapsedCategories[data.id]
            MT:buildScrollList(true)
            MT:updateFilterControl()
        end
	end
end

function MT:IsViewingInitialZone()
    local zone = Nav.Locations:getCurrentMapZone()
    return not zone or zone.zoneId == Nav.initialMapZoneId
end

function MT:OnMapChanged()
    local mapId = GetCurrentMapId()
    if Nav.mapVisible and mapId ~= self.currentMapId then
        self.currentMapId = mapId
        local zone = Nav.Locations:getCurrentMapZone()
        Nav.log("OnMapChanged: now zoneId=%d mapId=%d initial=%d", zone and zone.zoneId or 0, mapId or 0, Nav.initialMapZoneId or 0)
        if zone and zone.zoneId <= 2 then
            self.collapsedCategories = { bookmarks = true, recents = true }
        else
            self.collapsedCategories = {}
        end
        Nav.targetNode = 0
        self.filter = Nav.FILTER_NONE
        self:updateFilterControl()
        self.editControl:SetText("")
        -- end
        self:executeSearch("")
    end
end

Nav.MapTab = MT