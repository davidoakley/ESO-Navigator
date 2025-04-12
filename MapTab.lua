local MT = Navigator_MapTab -- from XML
local Nav = Navigator

MT.filter = Nav.FILTER_NONE
MT.needsRefresh = Nav.REFRESH_NONE
MT.collapsedCategories = {}
MT.targetNode = 0

function MT:queueRefresh(refreshMode)
    if self.needsRefresh == Nav.REFRESH_NONE then
        self.needsRefresh = refreshMode
        if self.visible and not self.menuOpen then
            zo_callLater(function()
                if self.needsRefresh ~= Nav.REFRESH_NONE and self.visible and not self.menuOpen then
                    self:ImmediateRefresh(self.needsRefresh)
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

function MT:ImmediateRefresh(refreshMode)
    if refreshMode == nil then
        refreshMode = Nav.REFRESH_REBUILD
    end

    if Nav.Locations.keepsDirty then
        Nav.Locations:UpdateKeeps()
    end
    if refreshMode == Nav.REFRESH_REBUILD then
        self:UpdateContent(self.searchString, true)
    else
        ZO_ScrollList_RefreshVisible(self.listControl)
    end
    self.needsRefresh = Nav.REFRESH_NONE
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
    if node.pinType then
        table.insert(items, "pinType="..(node.pinType or "-"))
    end
    if node.icon or node.originalIcon then
        table.insert(items, "icon="..(node.originalIcon or node.icon or "-"))
    end

    return table.concat(items, "\n")
end

local currentTooltip

function MT:layoutRow(rowControl, data, _)
    local node = data.node
    local isSelected = self.editControl:HasFocus() and node.known and (data.nodeIndex == MT.targetNode)
	local name = node:GetName()
    local icon = node:GetIcon()
    local categoryId = data.dataEntry.categoryId

    local suffix = node:GetSuffix()
    if node.zoneSuffix and categoryId == "results" then
        node.suffix = node.zoneSuffix
    end
    if suffix ~= nil and suffix ~= "" then
        local colour = ZO_ColorDef:New(node:GetSuffixColour(isSelected))
        name = name .. " " .. colour:Colorize(suffix)
    end

    local tagString = node:CreateTagListString(isSelected, categoryId ~= "bookmarks")
    if tagString then
        name = name .. "  " .. tagString
    end

	if icon ~= nil then
        rowControl.icon:SetColor(ZO_ColorDef.HexToFloats(node:GetIconColour(isSelected)))
		rowControl.icon:SetTexture(icon)
		rowControl.icon:SetHidden(false)
    else
		rowControl.icon:SetHidden(true)
	end

    local overlayIcon, overlayColour = node:GetOverlayIcon(isSelected)
    if overlayIcon then
        rowControl.overlay:SetColor(ZO_ColorDef.HexToFloats(overlayColour))
        rowControl.overlay:SetTexture(overlayIcon)
        rowControl.overlay:SetHidden(false)
    else
        rowControl.overlay:SetHidden(true)
    end

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
        --InitializeTooltip(InformationTooltip, rc, TOPRIGHT, 0, -2, BOTTOMLEFT)
        --currentTooltip = InformationTooltip

        currentTooltip = Nav.Tooltip:New(node, rc)

        local devTooltip = getDeveloperTooltip(node)
        if currentTooltip and devTooltip then
            --tooltipText = (tooltipText and (tooltipText .. "\n") or "") .. devTooltip
            currentTooltip.tooltip:AddLine(devTooltip, 'ZoFontGameSmall', 0.7725, 0.7608, 0.6196, TOPLEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_LEFT, false)
        end
    end)
    rowControl:SetHandler("OnMouseExit", function(_)
        if currentTooltip then
            currentTooltip:Clear()
            currentTooltip = nil
        end
        --ZO_Tooltips_HideTextTooltip()
        rowControl.label:SetColor(ZO_ColorDef.HexToFloats(node:GetColour()))
    end)
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
            local data = {
                node = list[i],
                indexInCategory = i,
                categoryEntryCount = #list,
                nodeIndex = currentNodeIndex
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

    if #list > 0 and listed == 0 and (MT.filter == Nav.FILTER_NONE or MT.filter ~= Nav.FILTER_ALL) then
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


    MT.resultCount = 0
    for i = 1, #self.content.categories do
        local category = self.content.categories[i]
        buildCategory(scrollData, category)
    end

	ZO_ScrollList_Commit(self.listControl)

    if not keepScrollPosition or self.targetNode >= (self.resultCount or 0) then
        -- Nav.log("executeSearch: reset targetNode keep=%d, oldTarget=%d, count=%d", keepTargetNode and 1 or 0, self.targetNode, (MT.resultCount or 0))
        self.targetNode = 0
        keepScrollPosition = false
    end

    if keepScrollPosition then
        ZO_ScrollList_ScrollAbsolute(self.listControl, scrollPosition)
    end
    if MT.resultCount > 0 then
        -- FIXME: this doesn't account for the headings
        ZO_ScrollList_ScrollDataIntoView(self.listControl, self.targetNode + 1, nil, true)
    end
end

function MT:UpdateContent(searchString, keepTargetNode)
    self.searchString = searchString

    self.content = Nav.ContentBuilder.Build(self.searchString, self.filter)

    self:buildScrollList(keepTargetNode)
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
    local setFilter = function(filter)
        self.filter = filter
        editbox:SetText("")
        editbox.editTextChanged = false
        searchString = ""
        self:UpdateFilterControl()
    end

    if searchString == "z:" then
        setFilter(Nav.FILTER_ZONES)
    elseif searchString == "h:" then
        setFilter(Nav.FILTER_HOUSES)
    elseif searchString == '@' or searchString == "p:" then
        setFilter(Nav.FILTER_PLAYERS)
    elseif searchString == "t:" then
        setFilter(Nav.FILTER_TRADERS)
    elseif searchString == "m:" then
        setFilter(Nav.FILTER_TREASURE)
    elseif searchString == "a:" then
        self.filter = Nav.FILTER_ALL
        editbox:SetText("")
        editbox.editTextChanged = false
        searchString = ""
    else
        self.editControl.editTextChanged = true
    end

    self:UpdateContent(searchString, false)
end

function MT:OnEnter()
	local data = self:getTargetData()
	if data and data.node then
        if data.node.OnEnter then
            data.node:OnEnter()
        elseif data.node.OnClick then
            data.node:OnClick(false)
        end
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
    ZO_ScrollList_RefreshVisible(self.listControl)
    ZO_ScrollList_ScrollDataIntoView(self.listControl, self.targetNode + 1, nil, true)
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
	self:buildScrollList(true)
end

function MT:nextCategory()
    self.targetNode = self:getNextCategoryFirstIndex()
	self:buildScrollList(true)
end

function MT:previousCategory()
    -- self.targetNode = self:getPreviousCategoryFirstIndex()
	-- self:buildScrollList()
end

function MT:resetFilter()
	Nav.log("MT.resetFilter")
    self.filter = Nav.FILTER_NONE
    --self:hideFilterControl()
    self:ImmediateRefresh()
	ZO_ScrollList_ResetToTop(self.listControl)
end

function MT:resetSearch()
	Nav.log("MT.resetSearch")
	self.editControl:SetText("")
    self.filter = Nav.FILTER_NONE
    self:UpdateFilterControl()
    --self:hideFilterControl()
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
        --MT:updateFilterControl()
    end
end

function MT:HintRowMouseUp(control, mouseButton)
    if mouseButton == 1 then
        local data = ZO_ScrollList_GetData(control)
        if data.onClick then
            data.onClick()
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
        if zone and Nav.Locations:ShouldCollapseCategories(zone.zoneId) then
            self.collapsedCategories = { bookmarks = true, recents = true }
        else
            self.collapsedCategories = {}
        end

        if (self.searchString or "") == "" and self.filter == Nav.FILTER_NONE then
            Nav.log("MT:OnMapChanged: UpdateContent")
            self.targetNode = 0
            self:UpdateContent("", false)
        end

        Nav.Node.RemovePings()
    end
end

function MT:OpenViewMenu()
    ClearMenu()

    local doFilter = function(filterId)
        self.filter = filterId
        self:UpdateFilterControl()
        self:queueRefresh()
    end

    local addItem = function (icon, stringId, callback, gap)
        AddMenuItem(string.format("|t24:24:Navigator/media/icons/%s.dds:inheritcolor|t %s",
                                  icon, GetString(stringId)),
                    callback, nil, nil, nil, nil, gap or 0)
    end

    addItem("zone", NAVIGATOR_SETTINGS_ZONE_ACTIONS_NAME, function() doFilter(Nav.FILTER_ZONES) end)
    addItem("player", NAVIGATOR_MENU_PLAYERS, function() doFilter(Nav.FILTER_PLAYERS) end)
    addItem("house", NAVIGATOR_SETTINGS_HOUSE_ACTIONS_NAME, function() doFilter(Nav.FILTER_HOUSES) end)
    addItem("trader", NAVIGATOR_MENU_GUILDTRADERS, function() doFilter(Nav.FILTER_TRADERS) end)
    if LibTreasure_GetItemIdData then
        addItem("map", NAVIGATOR_MENU_TREASUREMAPS_SURVEYS, function() doFilter(Nav.FILTER_TREASURE) end)
    end
    addItem("search_up", NAVIGATOR_MENU_CLEARVIEW, function() doFilter(Nav.FILTER_NONE) end, 12)

    --AddMenuItem("|t24:24:Navigator/media/icons/search_up.dds|t Clear view", function() doFilter(Nav.FILTER_NONE) end,
    --        nil, nil, nil, nil, 12)

    MT.menuOpen = true
    ShowMenu(self.searchControl)
    ZO_Menu:ClearAnchors()
    ZO_Menu:SetAnchor(TOPLEFT, self.searchControl, BOTTOMLEFT, 0, 2)

    SetMenuHiddenCallback(function()
        Nav.log("SetMenuHiddenCallback: Menu hidden")
        MT.menuOpen = false
        if MT.needsRefresh then
            MT:ImmediateRefresh()
        end
    end)
end

function MT:UpdateFilterControl()
    local textures = { "search_up", "search_down", "search_over" }

    if     self.filter == Nav.FILTER_PLAYERS  then textures = { "player" }
    elseif self.filter == Nav.FILTER_HOUSES   then textures = { "house" }
    elseif self.filter == Nav.FILTER_ZONES    then textures = { "zone" }
    elseif self.filter == Nav.FILTER_TRADERS  then textures = { "trader" }
    elseif self.filter == Nav.FILTER_TREASURE then textures = { "map" }
    --elseif self.filter == Nav.FILTER_NONE then
    --elseif self.filter == Nav.FILTER_ALL then
    end

    self.viewButton:SetNormalTexture(string.format("Navigator/media/icons/%s.dds", textures[1]))
    self.viewButton:SetPressedTexture(string.format("Navigator/media/icons/%s.dds", textures[2] or textures[1]))
    self.viewButton:SetMouseOverTexture(string.format("Navigator/media/icons/%s.dds", textures[3] or textures[1]))
end

function MT:SetViewButtonTooltip()
    self.viewButton:SetHandler("OnMouseEnter", function(control)
        ZO_Tooltips_ShowTextTooltip(control, LEFT, GetString(NAVIGATOR_TOOLTIP_VIEWMENU))
    end)
    self.viewButton:SetHandler("OnMouseExit", function(_)
        ZO_Tooltips_HideTextTooltip()
    end)
end

MT:SetViewButtonTooltip()

Nav.MapTab = MT