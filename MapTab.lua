local MT = MapSearch.MapTab or {}
local Search = MapSearch.Search
local Utils = MapSearch.Utils
local logger = MapSearch.logger

local function LayoutRow(rowControl, data, scrollList)
	local name = data.name

	if data.icon ~= nil then
		rowControl.icon:SetTexture(data.icon)
		rowControl.icon:SetHidden(false)
	else
		rowControl.icon:SetHidden(true)
	end

	rowControl.arrow:SetHidden(not data.isSelected)
    rowControl.bg:SetHidden(not data.isSelected)

	rowControl.label:SetText(name)

	if data.isSelected then
		rowControl.label:SetColor(ZO_SELECTED_TEXT:UnpackRGBA())
    elseif data.colour ~= nil then
        logger:Info("LayoutRow: "..name..": ")
        logger:Info(data.colour.UnpackRGBA)
        MapSearch.colour = data.colour
		rowControl.label:SetColor(data.colour:UnpackRGBA())
    else
		rowControl.label:SetColor(ZO_NORMAL_TEXT:UnpackRGBA())
	end

    if data.tooltip ~= nil then
        logger:Info("Adding tooltip for "..name..": "..data.tooltip)
        rowControl:SetHandler("OnMouseEnter", function(rc)
            ZO_Tooltips_ShowTextTooltip(rc, LEFT, data.tooltip)
        end)
        rowControl:SetHandler("OnMouseExit", function(_)
            ZO_Tooltips_HideTextTooltip()
            if data.isSelected then
                rowControl.label:SetColor(ZO_SELECTED_TEXT:UnpackRGBA())
            end
        end )
    end
end

local function showWayshrineConfirm(data,isRecall)
	local nodeIndex,name,refresh,clicked = data.nodeIndex,data.name,data.refresh,data.clicked
	ZO_Dialogs_ReleaseDialog("FAST_TRAVEL_CONFIRM")
	ZO_Dialogs_ReleaseDialog("RECALL_CONFIRM")
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

local function buildScrollList(control, results)
	ZO_ScrollList_Clear(control)
	
	local editBox = MapSearch_WorldMapTabSearchEdit
	local searchString = editBox:GetText()
	if searchString == "" then
		-- reinstate default text
		ZO_EditDefaultText_Initialize(editBox, GetString(MAPSEARCH_SEARCH))
	else
		-- remove default text
		ZO_EditDefaultText_Disable(editBox)
	end


    local scrollData = ZO_ScrollList_GetDataList(control)
	local currentNodeIndex = 0

	for index, nodeMap in ipairs(results) do
		local nodeData = {
			name = nodeMap.name,
			barename = Utils.bareName(nodeMap.name),
			nodeIndex = nodeMap.nodeIndex,
			poiType = nodeMap.poiType,
			icon = nodeMap.icon,
            colour = nodeMap.colour,
            tooltip = nodeMap.tooltip
		}

		-- nodeData.icon = nodeData.icon:gsub('glow', 'complete')

		-- if currentNodeIndex == MapSearch.targetNode then
		-- 	nodeData.icon = "esoui/art/chatwindow/chat_overflowarrow_up.dds"
		-- end
		-- nodeData.icon = nodeMap.icon
		nodeData.isSelected = (currentNodeIndex == MapSearch.targetNode)

		-- nodeMap.barename = Utils.bareName(nodeMap.name)

		local entry = ZO_ScrollList_CreateDataEntry(1, nodeData)
		-- local entry = ZO_ScrollList_CreateDataEntry(1, deepCopy(nodeMap))
		table.insert(scrollData, entry)

		currentNodeIndex = currentNodeIndex + 1
	end
	MT.resultCount = currentNodeIndex
    
	ZO_ScrollList_Commit(control)
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

	buildScrollList(control, results)
end

local function setupScrollList(control)
	logger:Info("setupScrollList")
	local height = 25 -- height of the row, not the window
	local setupFunction = LayoutRow
	local hideCallback = nil
	local dataTypeSelectSound = nil
	local resetControlCallback = nil
	local selectTemplate = "ZO_ThinListHighlight"
	local selectCallback = OnRowSelect

	ZO_ScrollList_AddDataType(control, 0, "MapSearch_WorldMapCategoryRow", 40, setupFunction, hideCallback, dataTypeSelectSound, resetControlCallback)
	ZO_ScrollList_AddDataType(control, 1, "MapSearch_WorldMapWayshrineRow", 23, setupFunction, hideCallback, dataTypeSelectSound, resetControlCallback)

	ZO_ScrollList_EnableSelection(control, selectTemplate, selectCallback)
end

local function getTargetNode(results)
	local currentNodeIndex = 0

	for nodeIndex, nodeMap in ipairs(results) do
		if currentNodeIndex == MapSearch.targetNode then
			return nodeMap
		end

		currentNodeIndex = currentNodeIndex + 1
	end

	return nil
end

function MT:init(tabControl)
	logger:Info("MapTab:init")
	self.tabControl = tabControl

    local control = MapSearch_WorldMapTabList
	self.listControl = control

	self.editControl = MapSearch_WorldMapTabSearchEdit

	setupScrollList(control)

	executeSearch(control)

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

function MT.onTextChanged(editbox, listcontrol)
	local searchString = string.lower(editbox:GetText())
	logger:Info("OnTextChanged: "..searchString)
	executeSearch(listcontrol, searchString)
end

function MT.jumpToResult()
	local node = getTargetNode(MapSearch.Search.result)

	if node then
		showWayshrineConfirm(node, MapSearch.isRecall)
	end
end

function MT.nextResult()
	MapSearch.targetNode = (MapSearch.targetNode + 1) % MT.resultCount
	buildScrollList(MapSearch_WorldMapTabList, MapSearch.results)
end

function MT.previousResult()
	MapSearch.targetNode = MapSearch.targetNode - 1
	if MapSearch.targetNode < 0 then
		MapSearch.targetNode = MapSearch.results - 1
	end
	buildScrollList(MapSearch_WorldMapTabList, MapSearch.results)
end

function MT.resetFilter(editbox, listcontrol, lose_focus)
	--logger.Info(editbox)
	MapSearch_WorldMapTabSearchEdit:SetText("")

	executeSearch(MapSearch_WorldMapTabList, "")

	-- if lose_focus then
	-- 	editbox:LoseFocus()
	-- end
	--ZO_EditDefaultText_Initialize(editbox, GetString(FASTER_TRAVEL_WAYSHRINES_SEARCH))
	--ResetVisibility(listcontrol)
	ZO_ScrollList_ResetToTop(MapSearch_WorldMapTabList)
end

function MT:rowMouseUp(control, mouseButton, upInside)
	logger:Info("Row Mouse Up")
	logger:Info(control)
	--MapSearch.clickedControl = { control, mouseButton, upInside }

	if(upInside) then
		local data = ZO_ScrollList_GetData(control)
		--MapSearch.clickedData = data
		showWayshrineConfirm(data, MapSearch.isRecall)
		-- if data.clicked then
		-- 	data:clicked(control,button)
		-- 	-- self:RowMouseClicked(control,data,button)
		-- 	logger:Info("Row Mouse Up clicked? "..data.clicked)
		-- end
	end

end

MapSearch.MapTab = MT