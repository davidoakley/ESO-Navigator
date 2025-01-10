local MT = MapSearch_MapTab --MapSearch.MapTab or {}
local Search = MapSearch.Search
local Utils = MapSearch.Utils
local logger = MapSearch.logger

function MT:layoutRow(rowControl, data, scrollList)
	local name = data.name
    local tooltipText = data.tooltip
    local icon = data.icon
    local iconColour = { 1.0, 1.0, 1.0, 1.0 }

    if data.suffix ~= nil then
        name = name .. " |c82826F" .. data.suffix .. "|r"
    end

    if MapSearch.isRecall and data.poiType == POI_TYPE_WAYSHRINE then
        local _, timeLeft = GetRecallCooldown()

        if timeLeft == 0 then
            icon = "/esoui/art/tradinghouse/tradinghouse_sell_tabicon_up.dds"
            iconColour = { 1.0, 0.8, 0.2, 1 }

            -- local cost,hasEnough = GetRecallCostInfo()
            local currencyType = CURT_MONEY
            local currencyAmount = GetRecallCost()
            local formatType = ZO_CURRENCY_FORMAT_AMOUNT_ICON
            local currencyString = zo_strformat(SI_NUMBER_FORMAT, ZO_Currency_FormatKeyboard(currencyType, currencyAmount, formatType))
            local costText = string.format(GetString(SI_TOOLTIP_RECALL_COST) .. "%s", currencyString)
            if tooltipText then
                tooltipText = costText .. "; " .. tooltipText
            else
                tooltipText = costText
            end
        end
    end

	if data.icon ~= nil then
        rowControl.icon:SetColor(unpack(iconColour))
		rowControl.icon:SetTexture(icon)
		rowControl.icon:SetHidden(false)
    else
		rowControl.icon:SetHidden(true)
	end

    -- MT.rowControl = rowControl
	rowControl.keybind:SetHidden(not data.isSelected)
    rowControl.bg:SetHidden(not data.isSelected)

	rowControl.label:SetText(name)

	if data.isSelected then
		rowControl.label:SetColor(ZO_SELECTED_TEXT:UnpackRGBA())
    elseif data.colour ~= nil then
        MapSearch.colour = data.colour
		rowControl.label:SetColor(data.colour:UnpackRGBA())
    else
		rowControl.label:SetColor(ZO_NORMAL_TEXT:UnpackRGBA())
	end

    if tooltipText then
        rowControl:SetHandler("OnMouseEnter", function(rc)
            ZO_Tooltips_ShowTextTooltip(rc, LEFT, tooltipText)
        end)
        rowControl:SetHandler("OnMouseExit", function(_)
            ZO_Tooltips_HideTextTooltip()
            if data.isSelected then
                rowControl.label:SetColor(ZO_SELECTED_TEXT:UnpackRGBA())
            end
        end )
    end
end

function MT:layoutCategoryRow(rowControl, data, scrollList)
	-- if data.icon ~= nil then
	-- 	rowControl.icon:SetTexture(data.icon)
	-- 	rowControl.icon:SetHidden(false)
	-- else
	-- 	rowControl.icon:SetHidden(true)
	-- end

	rowControl.label:SetText(data.name)
end

local function jumpToPlayer(node)
    local userID, poiType, zoneId, zoneName = node.userID, node.poiType, node.zoneId, node.zoneName
    local Locs = MapSearch.Locations

    Locs:setupPlayerZones()

    if not Locs.players[userID] or Locs.players[userID].zoneId ~= zoneId then
        -- Player has disappeared or moved!
        CHAT_SYSTEM:AddMessage(userID .. " is no longer in "..zoneName)

        if Locs.playerZones[zoneId] then
            node = Locs.playerZones[zoneId]
            userID, poiType, zoneId, zoneName = node.userID, node.poiType, node.zoneId, node.zoneName
        else
            -- Eeek! Refresh the search results and finish
            MT:buildScrollList()
            return
        end
    end

    CHAT_SYSTEM:AddMessage("Jumping to "..zoneName.." via "..userID)
    SCENE_MANAGER:Hide("worldMap")

    if poiType == POI_TYPE_FRIEND then
        JumpToFriend(userID)
    elseif poiType == POI_TYPE_GUILDMATE then
        JumpToGuildMember(userID)
    end
end

local function jumpToNode(node)
    local isRecall = MapSearch.isRecall
	local nodeIndex,name,refresh,clicked = node.nodeIndex,node.originalName,node.refresh,node.clicked

    ZO_Dialogs_ReleaseDialog("FAST_TRAVEL_CONFIRM")
	ZO_Dialogs_ReleaseDialog("RECALL_CONFIRM")

    if node.poiType == POI_TYPE_FRIEND or node.poiType == POI_TYPE_GUILDMATE then
        jumpToPlayer(node)
        return
    end

	name = name or select(2, MapSearch.Wayshrine.Data.GetNodeInfo(nodeIndex)) -- just in case
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

local function buildList(scrollData, title, list)
    if #list > 0 then
        local recentEntry = ZO_ScrollList_CreateDataEntry(0, { name = title })
        table.insert(scrollData, recentEntry)
    end

    local currentNodeIndex = MT.resultCount

    for i = 1, #list do
        local listEntry = list[i]

        local nodeData = Utils.shallowCopy(listEntry)
		nodeData.isSelected = (currentNodeIndex == MapSearch.targetNode)
        nodeData.dataIndex = currentNodeIndex

        -- logger:Info("%s: traders %d", nodeData.barename, nodeData.traders or 0)
        if listEntry.traders and listEntry.traders > 0 then
            if listEntry.traders >= 5 then
                nodeData.suffix = "|t20:23:MapSearch/media/city_narrow.dds:inheritcolor|t"
            elseif listEntry.traders >= 2 then
                nodeData.suffix = "|t20:23:MapSearch/media/town_narrow.dds:inheritcolor|t"
            end
            nodeData.suffix = (nodeData.suffix or "") .. "|t23:23:/esoui/art/icons/servicemappins/servicepin_guildkiosk.dds:inheritcolor|t"
        end

		local entry = ZO_ScrollList_CreateDataEntry(1, nodeData)
		table.insert(scrollData, entry)

        currentNodeIndex = currentNodeIndex + 1
    end

    MT.resultCount = currentNodeIndex
end

function MT:buildScrollList()
	ZO_ScrollList_Clear(self.listControl)

	local searchString = self.editControl:GetText()
	if searchString == "" then
		-- reinstate default text
		ZO_EditDefaultText_Initialize(self.editControl, GetString(MAPSEARCH_SEARCH))
	else
		-- remove default text
		ZO_EditDefaultText_Disable(self.editControl)
	end

    local scrollData = ZO_ScrollList_GetDataList(self.listControl)

    MT.resultCount = 0
    buildList(scrollData, "Results", MapSearch.results)
    buildList(scrollData, "Bookmarks", MapSearch.Bookmarks:getBookmarks())
    buildList(scrollData, "Recent", MapSearch.Recents:getRecents())

	ZO_ScrollList_Commit(self.listControl)

    if MT.resultCount > 0 then
        -- FIXME: this doesn't account for the headings
        ZO_ScrollList_ScrollDataIntoView(self.listControl, MapSearch.targetNode + 1, nil, true)
    end
end

local function executeSearch(control, searchString)
	local results

	if searchString ~= nil and #searchString > 0 then
		results = Search.run(searchString)
	else
		results = {}
	end

	MapSearch.results = results
	MapSearch.targetNode = 0

	MT:buildScrollList()
end

function MT:getTargetDataIndex()
	local currentNodeIndex = 0

    local scrollData = ZO_ScrollList_GetDataList(self.listControl)

    for i = 1, #scrollData do
        if scrollData[i].typeId == 1 then -- wayshrine row
            if currentNodeIndex == MapSearch.targetNode then
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
    local currentNodeIndex = MapSearch.targetNode + 1

    local i = currentIndex + 1
    local foundCategory = false

    while true do
        if scrollData[i].typeId == 1 then -- wayshrine row
            if foundCategory or i == currentIndex then
                -- return the first entry after the category header
                -- logger:Debug("Index %d node %d is result - returning", i, currentNodeIndex)
                return currentNodeIndex
            end
            -- logger:Debug("Index %d node %d is result - incrementing", i, currentNodeIndex)
            currentNodeIndex = currentNodeIndex + 1
        elseif scrollData[i].typeId == 0 then -- category header
            -- logger:Debug("Index %d node %d is category", i, currentNodeIndex)
            foundCategory = true
        end

        if i >= #scrollData then
            -- logger:Debug("Wrapping at index %d node %d", i, currentNodeIndex)
            i = 1
            currentNodeIndex = 0
        else
            i = i + 1
        end
    end
end

function MT:init()
	logger:Debug("MapTab:init")

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

function MT:onTextChanged(editbox, listcontrol)
	local searchString = string.lower(editbox:GetText())
	executeSearch(listcontrol, searchString)
end

function MT:jumpToTargetNode()
	local node = self:getTargetNode()

	if node then
		jumpToNode(node)
	end
end

function MT:nextResult()
	MapSearch.targetNode = (MapSearch.targetNode + 1) % MT.resultCount
	self:buildScrollList()
end

function MT:previousResult()
	MapSearch.targetNode = MapSearch.targetNode - 1
	if MapSearch.targetNode < 0 then
		MapSearch.targetNode = MT.resultCount - 1
	end
	self:buildScrollList()
end

function MT:nextCategory()
    MapSearch.targetNode = self:getNextCategoryFirstIndex()
	self:buildScrollList()
end

function MT:resetFilter(lose_focus)
	--logger.Info(editbox)
	self.editControl:SetText("")

	executeSearch(self.listControl, "")

	-- if lose_focus then
	-- 	editbox:LoseFocus()
	-- end
	--ZO_EditDefaultText_Initialize(editbox, GetString(FASTER_TRAVEL_WAYSHRINES_SEARCH))
	--ResetVisibility(listcontrol)
	ZO_ScrollList_ResetToTop(self.listControl)
end

local function showWayshrineMenu(owner, nodeIndex)
	ClearMenu()

    local bookmarks = MapSearch.Bookmarks
	if bookmarks:contains(nodeIndex) then
		AddMenuItem("Remove Bookmark", function()
			bookmarks:remove(nodeIndex)
			ClearMenu()
            MT:buildScrollList()
		end)
	else
		AddMenuItem("Add Bookmark", function()
			bookmarks:add(nodeIndex)
			ClearMenu()
            MT:buildScrollList()
		end)
	end
	ShowMenu(owner)
end

function MT:rowMouseUp(control, mouseButton, upInside)
	--MapSearch.clickedControl = { control, mouseButton, upInside }

	if(upInside) then
		local data = ZO_ScrollList_GetData(control)
        if mouseButton == 1 then
            jumpToNode(data)
            -- showWayshrineConfirm(data, MapSearch.isRecall)
		elseif mouseButton == 2 then
			showWayshrineMenu(control, data.nodeIndex)
		end
	end
end

MapSearch.MapTab = MT