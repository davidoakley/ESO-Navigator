local MapTab = MapSearch.class()
MapSearch.MapTab = MapTab
MapTab.resultCount = 0

local Search = MapSearch.Search
local Utils = MapSearch.Utils
local logger = LibDebugLogger("MapSearch")




local function LayoutRow(rowControl, data, scrollList)
	-- The rowControl, data, and scrollListControl are all supplied by the internal callback trigger
	-- What is contained in data is determined by the structure of the table of data items you used
	--[[ Copied here from where we created the data so we can easily reference the data structure
	pets[petcounter] = {
		index = index,
		name = petNameClean,
		description = p2
		texture = p3
	}
	]]
	local name = data.name

	if data.poiType == 6 then
		-- name = name .. " |c5c594aDungeon|r"
		-- /esoui/art/icons/poi/poi_dungeon_complete.dds
	end

	if data.icon ~= nil then
		rowControl.icon:SetTexture(data.icon)
		rowControl.icon:SetHidden(false)
	else
		rowControl.icon:SetHidden(true)
	end

	rowControl.arrow:SetHidden(not data.isSelected)

	rowControl.label:SetText(name)

	if data.isSelected then
		rowControl.label:SetColor(ZO_SELECTED_TEXT:UnpackRGBA())
	else
		rowControl.label:SetColor(ZO_NORMAL_TEXT:UnpackRGBA())
	end
	--[[
	rowControl:SetFont("ZoFontWinH4")
	rowControl:SetMaxLineCount(1) -- Forces the text to only use one row.  If it goes longer, the extra will not display.
	rowControl:SetText(data.name)
	
	-- When we added the data type earlier we also enabled being able to select an item and which function to run
	-- when an row is slected.  We still need to set up a handler to actuall register the mouse click which
	-- then triggers the row as "selected".  See https://wiki.esoui.com/UI_XML#OnAddGameData and following
	-- entries for "On" events that can be set as handlers.
	rowControl:SetHandler("OnMouseUp", function() ZO_ScrollList_MouseClick(scrollList, rowControl) end)
	
	-- Just for fun!!
	-- Put together a tooltip string to display when the user positions mouse over the scroll list row.
	-- https://wiki.esoui.com/How_to_format_strings_with_zo_strformat#Concatenating_lists
	-- Using \n inserts a newline to bump the image down a bit.  There may be a better way to do this,
	-- but I find \n frequently used in the source code so the developers use it too.
	-- Added in a spacer |u to move the texture over a bit so it was not tight against the left side.
	-- https://wiki.esoui.com/Text_Formatting  |u40:0:: |u
	local concatToolTip = {}
	table.insert(concatToolTip, "\n\n\n|u40:0:: |u|t600%:600%:")
	table.insert(concatToolTip, data.texture)
	table.insert(concatToolTip, "|t\n\n\n")
	table.insert(concatToolTip, "|t1150%:100%:EsoUI/Art/Miscellaneous/horizontalDivider.dds|t\n") -- the % is the percentage of the font height.  Make it too large and it disappers.
	table.insert(concatToolTip, data.description)
	local tooltip = table.concat(concatToolTip, "")
	
	rowControl:SetHandler("OnMouseEnter", function(rowControl) ZO_Tooltips_ShowTextTooltip(rowControl, LEFT, tooltip) end)
	rowControl:SetHandler("OnMouseExit", function(rowControl) ZO_Tooltips_HideTextTooltip() end )
	]]
end

local function ShowWayshrineConfirm(data,isRecall)
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
			barename = Utils.BareName(nodeMap.name),
			nodeIndex = nodeMap.nodeIndex,
			poiType = nodeMap.poiType,
			icon = nodeMap.icon
		}

		-- nodeData.icon = nodeData.icon:gsub('glow', 'complete')

		-- if currentNodeIndex == MapSearch.targetNode then
		-- 	nodeData.icon = "esoui/art/chatwindow/chat_overflowarrow_up.dds"
		-- end
		-- nodeData.icon = nodeMap.icon
		nodeData.isSelected = (currentNodeIndex == MapSearch.targetNode)

		nodeMap.barename = Utils.BareName(nodeMap.name)

		local entry = ZO_ScrollList_CreateDataEntry(1, nodeData)
		-- local entry = ZO_ScrollList_CreateDataEntry(1, deepCopy(nodeMap))
		table.insert(scrollData, entry)

		currentNodeIndex = currentNodeIndex + 1
	end
	MapTab.resultCount = currentNodeIndex
    
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


function MapTab:init(tabControl)
	logger:Info("MapTab:init")
	self.tabControl = tabControl

    local control = MapSearch_WorldMapTabList
	self.listControl = control

	self.editControl = MapSearch_WorldMapTabSearchEdit

	setupScrollList(control)

	executeSearch(control)

	local _refreshing = false
	local _isDirty = true 
	
	self.IsDirty = function()
		return _isDirty
	end
	
	self.SetDirty = function()
		_isDirty = true 
	end
	
	self.RefreshIfRequired = function(self,...)
		--df("RefreshIfRequired isDirty=%s refreshing=%s", tostring(_isDirty), tostring(_refreshing))
		if _isDirty == true and _refreshing == false then 
			_refreshing = true -- only allow one refresh at any one time
			self:Refresh(...)
			_isDirty = false
			_refreshing = false
		end 
	end
	
end

function MapTab:SetCategoryHidden(categoryId,value)
	self.control:SetCategoryHidden(self.control.list,categoryId,value)
end

function MapTab:IsCategoryHidden(categoryId)
	return self.control:GetCategoryHidden(self.control.list,categoryId)
end

function MapTab:ClearControl()
	self.control:Clear(self.control.list)
end

function MapTab:RefreshControl(categories)
	if self.control == nil then return end
	self.control:Refresh(self.control.list)
	if categories == nil then return end
	
	for i,item in ipairs(categories) do
		self.control:SetCategoryHidden(self.control.list,item.categoryId,item.hidden)
	end
	
	self.control:Refresh(self.control.list)
end


function MapTab:Refresh()
	logger:Info("MapTab:Refresh")
end

function MapTab.OnTextChanged(editbox, listcontrol)
	local searchString = string.lower(editbox:GetText())
	logger:Info("OnTextChanged: "..searchString)
	executeSearch(listcontrol, searchString)
end

function MapTab.JumpToResult()
	local node = getTargetNode(MapSearch.Search.result)

	if node then
		ShowWayshrineConfirm(node, MapSearch.isRecall)
	end
end

function MapTab.NextResult()
	MapSearch.targetNode = (MapSearch.targetNode + 1) % MapTab.resultCount
	buildScrollList(MapSearch_WorldMapTabList, MapSearch.results)
end

function MapTab.PreviousResult()
	MapSearch.targetNode = MapSearch.targetNode - 1
	if MapSearch.targetNode < 0 then
		MapSearch.targetNode = MapSearch.results - 1
	end
	buildScrollList(MapSearch_WorldMapTabList, MapSearch.results)
end

function MapTab.ResetFilter(editbox, listcontrol, lose_focus)
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

function MapTab.RowMouseUp(control, mouseButton, upInside)
	logger:Info("Row Mouse Up")
	logger:Info(control)
	--MapSearch.clickedControl = { control, mouseButton, upInside }

	if(upInside) then
		local data = ZO_ScrollList_GetData(control:GetParent())
		--MapSearch.clickedData = data
		ShowWayshrineConfirm(data, MapSearch.isRecall)
		-- if data.clicked then
		-- 	data:clicked(control,button)
		-- 	-- self:RowMouseClicked(control,data,button)
		-- 	logger:Info("Row Mouse Up clicked? "..data.clicked)
		-- end
	end

end
