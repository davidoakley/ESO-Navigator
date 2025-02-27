local MT = Navigator_MapTab -- from XML
local Nav = Navigator
local Search = Nav.Search
local Utils = Nav.Utils

MT.filter = Nav.FILTER_NONE
MT.needsRefresh = false
MT.collapsedCategories = {}
MT.targetNode = 0

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
    if Nav.Locations.keepsDirty then
        Nav.Locations:UpdateKeeps()
    end
    self:executeSearch(self.searchString, true)
    self.needsRefresh = false
end

local function getDeveloperTooltip(node)
    if not Nav.isDeveloper or not Nav.saved.loggingEnabled then
        return nil
    end

    local items = {
        "searchName='" .. Nav.SearchName(node.originalName or node.name or '-').."'",
        "sortName='" .. Nav.SortName(node.name).."'",
        "weight="..(node:GetWeight() or 0)
    }
    if node.originalName then
        table.insert(items, 1, "originalName='" .. node.originalName)
    end
    if node.nodeIndex then
        table.insert(items, "nodeIndex="..(node.nodeIndex or "-"))
    end
    if node.zoneId then
        table.insert(items, "zoneId="..(node.zoneId or "-"))
    end

    return table.concat(items, "\n")
end

function MT:layoutRow(rowControl, data, _)
    local node = data.node
    local isSelected = data.isSelected
	local name = node:GetName()
    local icon = node:GetIcon()
    local categoryId = data.dataEntry.categoryId

    local suffix = node:GetSuffix()
    if node.zoneSuffix and categoryId == "results" then
        node.suffix = node.zoneSuffix
    end
    if suffix ~= nil then
        local colour = ZO_ColorDef:New(node:GetSuffixColour(isSelected))
        name = name .. " " .. colour:Colorize(suffix)
    end

    local tagList = node:GetTagList(categoryId ~= "bookmarks")
    if tagList and #tagList > 0 then
        local colour = ZO_ColorDef:New(node:GetTagColour(isSelected))
        local tagStrings = {}
        for i = 1, #tagList do
            table.insert(tagStrings, string.format("|t18:24:Navigator/media/tags/%s.dds:inheritcolor|t", tagList[i]))
        end
        name = name .. " " .. colour:Colorize(table.concat(tagStrings, ""))
    end

	if icon ~= nil then
        rowControl.icon:SetColor(ZO_ColorDef.HexToFloats(node:GetIconColour(isSelected)))
		rowControl.icon:SetTexture(icon)
		rowControl.icon:SetHidden(false)
    else
		rowControl.icon:SetHidden(true)
	end

    rowControl.cost:SetHidden(not node:GetRecallCost())

    rowControl.keybind:SetHidden(not isSelected)
    rowControl.bg:SetHidden(not isSelected)
    if isSelected then
        rowControl.label:SetAnchor(TOPRIGHT, rowControl.keybind, TOPLEFT, -4, -1)
    else
        rowControl.label:SetAnchor(TOPRIGHT, rowControl, TOPRIGHT, -4, 0)
    end

	rowControl.label:SetText(name)

    rowControl.label:SetColor(ZO_ColorDef.HexToFloats(node:GetColour(isSelected)))

    rowControl:SetHandler("OnMouseEnter", function(rc)
        local tooltipText
        if not node.known and node.nodeIndex then
            tooltipText = GetString(NAVIGATOR_NOT_KNOWN)
        else
            local recallCost = node:GetRecallCost()
            if recallCost then
                local currencyType = CURT_MONEY
                local formatType = ZO_CURRENCY_FORMAT_AMOUNT_ICON
                local currencyString = zo_strformat(SI_NUMBER_FORMAT, ZO_Currency_FormatKeyboard(currencyType, recallCost, formatType))
                tooltipText = string.format(GetString(SI_TOOLTIP_RECALL_COST) .. "%s", currencyString)
            end
        end

        if node.GetTooltip then
            local t = node:GetTooltip()
            if t then
                tooltipText = (tooltipText and (tooltipText .. "\n") or "") .. t
            end
        end

        local devTooltip = getDeveloperTooltip(node)
        if devTooltip then
            tooltipText = (tooltipText and (tooltipText .. "\n") or "") .. devTooltip
        end

        if tooltipText then
            ZO_Tooltips_ShowTextTooltip(rc, LEFT, tooltipText)
        end
    end)
    rowControl:SetHandler("OnMouseExit", function(_)
        ZO_Tooltips_HideTextTooltip()
        rowControl.label:SetColor(ZO_ColorDef.HexToFloats(node:GetColour()))
    end)
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
    elseif self.filter == Nav.FILTER_ALL then
        self:showFilterControl('All')
    end
end

function MT:layoutCategoryRow(rowControl, data, _)
	rowControl.label:SetText(data.name)
end

function MT:layoutHintRow(rowControl, data, _)
	rowControl.label:SetText(data.hint or "-")
end

local function ShowUndiscovered()
    MT.filter = Nav.FILTER_ALL
    MT:ImmediateRefresh()
end

local function buildCategoryHeader(scrollData, id, title, collapsed)
    title = tonumber(title) ~= nil and GetString(title) or title
    local recentEntry = ZO_ScrollList_CreateDataEntry(collapsed and 2 or 0, { id = id, name = title })
    table.insert(scrollData, recentEntry)
end

local function buildCategory(scrollData, category)
    local collapsed = MT.collapsedCategories[category.id] and true or false
    local hasFocus = MT.editControl:HasFocus()
    local list = category.list

    buildCategoryHeader(scrollData, category.id, category.title, collapsed)

    if collapsed then
        return
    elseif #list == 0 and category.emptyHint then
        list = {{ hint = GetString(category.emptyHint) }}
    end

    local currentNodeIndex = MT.resultCount
    local includeUnknown = Nav.saved.includeUndiscovered or MT.filter == Nav.FILTER_ALL
    local listed = 0

    for i = 1, #list do
        if list[i].hint then
            local entry = ZO_ScrollList_CreateDataEntry(3, { hint = list[i].hint })
            table.insert(scrollData, entry)
        elseif list[i].known or includeUnknown then
            local isSelected = hasFocus and list[i].known and (currentNodeIndex == MT.targetNode)
            local data = {
                node = list[i],
                isSelected = isSelected,
                indexInCategory = i,
                categoryEntryCount = #list
            }

            local entry = ZO_ScrollList_CreateDataEntry(1, data, category.id)
            table.insert(scrollData, entry)

            currentNodeIndex = currentNodeIndex + 1
            listed = listed + 1

            if category.maxEntries and listed >= category.maxEntries then
                break
            end
        end
    end

    if #list > 0 and listed == 0 then
        local entry = ZO_ScrollList_CreateDataEntry(3, { hint = GetString(NAVIGATOR_HINT_SHOWUNDISCOVERED), onClick = ShowUndiscovered })
        table.insert(scrollData, entry)
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
    ClearMenu() -- Close any right-click menu

    local scrollPosition = 0
    if keepScrollPosition then
        scrollPosition = ZO_ScrollList_GetScrollValue(self.listControl)
        -- Nav.log("MT:buildScrollList: pos=%d", scrollPosition)
    end

	ZO_ScrollList_Clear(self.listControl)

	self:UpdateEditDefaultText()

    local scrollData = ZO_ScrollList_GetDataList(self.listControl)

    self.content = nil
    local isSearching = #Nav.results > 0 or (self.searchString and self.searchString ~= "")

    if isSearching then
        self.content = Nav.SearchContent:New(Nav.results)
    else
        local zone = Nav.Locations:getCurrentMapZone()
        if zone and zone.zoneId == Nav.ZONE_TAMRIEL then
            self.content = Nav.ZoneListContent:New()
        elseif zone.zoneId == Nav.ZONE_CYRODIIL then
            self.content = Nav.CyrodiilContent:New()
        elseif zone then
            self.content = Nav.ZoneContent:New(zone)
        end
    end
    if not self.content then
        self.content = Nav.ZoneListContent:New()
        Nav.logWarning("MT:buildScrollList: no content chosen")
    end
    self.content:Compose()

    MT.resultCount = 0
    for i = 1, #self.content.categories do
        local category = self.content.categories[i]
        buildCategory(scrollData, category)
    end

	ZO_ScrollList_Commit(self.listControl)

    if keepScrollPosition then
        ZO_ScrollList_ScrollAbsolute(self.listControl, scrollPosition)
    elseif MT.resultCount > 0 then
        -- FIXME: this doesn't account for the headings
        ZO_ScrollList_ScrollDataIntoView(self.listControl, self.targetNode + 1, nil, true)
    end
end

function MT:executeSearch(searchString, keepTargetNode)
	local results

    MT.searchString = searchString

    results = Search:Run(searchString or "", MT.filter)

	Nav.results = results
    if not keepTargetNode or self.targetNode >= (MT.resultCount or 0) then
        -- Nav.log("executeSearch: reset targetNode keep=%d, oldTarget=%d, count=%d", keepTargetNode and 1 or 0, self.targetNode, (MT.resultCount or 0))
    	self.targetNode = 0
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
            if currentNodeIndex == self.targetNode then
                return i
            end
            currentNodeIndex = currentNodeIndex + 1
        end
    end

	return nil
end

function MT:getTargetData()
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
    local currentNodeIndex = self.targetNode + 1

    local i = currentIndex + 1
    local foundCategory = false

    while true do
        if scrollData[i].typeId == 1 then -- wayshrine row
            if (foundCategory and scrollData[i].data.node and scrollData[i].data.node.known) or i == currentIndex then
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
end

function MT:onTextChanged(editbox)
	local searchString = string.lower(editbox:GetText())
    if searchString == "z:" then
        local mapId = Nav.Locations.GetMapIdByZoneId(2) -- Tamriel
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
    elseif searchString == "a:" then
        self.filter = Nav.FILTER_ALL
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
	local data = self:getTargetData()
	if data then
		self:selectResult(nil, data, 1)
	end
end

function MT:nextResult()
    local known = false
    local startNode = self.targetNode
    repeat
    	self.targetNode = (self.targetNode + 1) % MT.resultCount
        local data = self:getTargetData()
        if data and data.node and data.node:IsKnown() then
            known = true
        end
    until known or self.targetNode == startNode
	self:buildScrollList()
end

function MT:previousResult()
    local known = false
    local startNode = self.targetNode
    repeat
        self.targetNode = self.targetNode - 1
        if self.targetNode < 0 then
            self.targetNode = MT.resultCount - 1
        end
        local data = self:getTargetData()
        if data and data.node and data.node:IsKnown() then
            known = true
        end
    until known or self.targetNode == startNode
	self:buildScrollList()
end

function MT:nextCategory()
    self.targetNode = self:getNextCategoryFirstIndex()
	self:buildScrollList()
end

function MT:previousCategory()
    -- self.targetNode = self:getPreviousCategoryFirstIndex()
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
    local bookmarks = Nav.Bookmarks

    if data.node.AddMenuItems then
        data.node:AddMenuItems()
    end

    if data.dataEntry.categoryId == "bookmarks" then
        local yPad = 12
        if data.indexInCategory > 1 then
            AddMenuItem(GetString(NAVIGATOR_MENU_MOVEBOOKMARKUP), function()
                Nav.Bookmarks:Move(data.node, -1)
                MT.menuOpen = false
                zo_callLater(function() MT:ImmediateRefresh() end, 10)
            end, nil, nil, nil, nil, yPad)
            yPad = 0
        end
        if data.indexInCategory < data.categoryEntryCount then
            AddMenuItem(GetString(NAVIGATOR_MENU_MOVEBOOKMARKDOWN), function()
                Nav.Bookmarks:Move(data.node, 1)
                MT.menuOpen = false
                zo_callLater(function() MT:ImmediateRefresh() end, 10)
            end, nil, nil, nil, nil, yPad)
            yPad = 0
        end
        AddMenuItem(GetString(NAVIGATOR_MENU_REMOVEBOOKMARK), function()
            bookmarks:remove(data.node)
            MT.menuOpen = false
            zo_callLater(function() MT:ImmediateRefresh() end, 10)
        end)
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

local function showGroupMenu(owner, _)
    ClearMenu()

    AddMenuItem(GetString(SI_GROUP_LEAVE), function()
        ZO_Dialogs_ShowDialog("GROUP_LEAVE_DIALOG")
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

function MT:selectResult(control, data, mouseButton, isDoubleClick)
    if mouseButton == 1 then
        if data.node and data.node.OnClick then
            --Nav.log("OnClick %s", data.node:GetName() or "-")
            data.node:OnClick(isDoubleClick)
        end
    elseif mouseButton == 2 then
        showWayshrineMenu(control, data)
    else
        Nav.log("selectResult: unhandled; poiType=%d zoneId=%d", data.poiType or -1, data.zoneId or -1)
    end
end

function MT:HandleMouseUp(handler, control, mouseButton, upInside)
    if upInside then
        if control.isDoubleClick then
            Nav.log("MT:HandleMouseUp 2")
            handler(self, control, mouseButton, true)
            control.isDoubleClick = false
            zo_removeCallLater(control.doubleClickTimer)
        else
            Nav.log("MT:HandleMouseUp 1")
            handler(self, control, mouseButton, false)
            if mouseButton == 1 then
                control.isDoubleClick = true
                control.doubleClickTimer = zo_callLater(function()
                    control.isDoubleClick = false
                end, 500)
            end
        end
    end
end

function MT:RowMouseUp(control, mouseButton, isDoubleClick)
    local data = ZO_ScrollList_GetData(control)
    self:selectResult(control, data, mouseButton, isDoubleClick)
end

function MT:CategoryRowMouseUp(control, mouseButton)
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

function MT:HintRowMouseUp(control, mouseButton)
    local data = ZO_ScrollList_GetData(control)
    if data.onClick then
        data.onClick()
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

        if (self.searchString or "") == "" and self.filter == Nav.FILTER_NONE then
            Nav.log("MT:OnMapChanged: executeSearch")
            self.targetNode = 0
            self:executeSearch("")
        end

        Nav.Node.RemovePings()
    end
end

Nav.MapTab = MT