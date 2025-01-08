local MT = MapSearch.MapTab or {}
local Search = MapSearch.Search
local Utils = MapSearch.Utils
local logger = MapSearch.logger

local function LayoutRow(rowControl, data, scrollList)
	local name = data.name

    if data.suffix ~= nil then
        name = name .. " |c82826F" .. data.suffix .. "|r"
    end

    -- if MapSearch.isRecall and data.poiType == POI_TYPE_WAYSHRINE then
        -- name = name .. " |t80%:80%:/esoui/art/currency/gold_mipmap.dds|t"
        -- data.icon = "/esoui/art/currency/gold_mipmap.dds"
    -- end

	if data.icon ~= nil then
		rowControl.icon:SetTexture(data.icon)
		rowControl.icon:SetHidden(false)
        if MapSearch.isRecall and data.poiType == POI_TYPE_WAYSHRINE then
            rowControl.icon:SetColor(0.8, 0.7, 0.1, 1)
        else
            rowControl.icon:SetColor(1, 1, 1, 1)
        end
    else
		rowControl.icon:SetHidden(true)
	end

	rowControl.arrow:SetHidden(not data.isSelected)
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

    if data.tooltip ~= nil then
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

local function LayoutCategoryRow(rowControl, data, scrollList)
	-- if data.icon ~= nil then
	-- 	rowControl.icon:SetTexture(data.icon)
	-- 	rowControl.icon:SetHidden(false)
	-- else
	-- 	rowControl.icon:SetHidden(true)
	-- end

	rowControl.label:SetText(data.name)
end

local function showWayshrineConfirm(data,isRecall)
	local nodeIndex,name,refresh,clicked = data.nodeIndex,data.originalName,data.refresh,data.clicked
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

local function buildList(scrollData, title, list)
    if #list > 0 then
        local recentEntry = ZO_ScrollList_CreateDataEntry(0, { name = title })
        table.insert(scrollData, recentEntry)
    end

    local currentNodeIndex = MT.resultCount

    for i = 1, #list do
        local recent = list[i]

        local nodeData = Utils.shallowCopy(recent)
		nodeData.isSelected = (currentNodeIndex == MapSearch.targetNode)

		local entry = ZO_ScrollList_CreateDataEntry(1, nodeData)
		table.insert(scrollData, entry)

        currentNodeIndex = currentNodeIndex + 1
    end

    MT.resultCount = currentNodeIndex
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

    MT.resultCount = 0
    buildList(scrollData, "Results", results)
    buildList(scrollData, "Recent", MapSearch.Recents:getRecents())
    buildList(scrollData, "Bookmarks", MapSearch.Bookmarks:getBookmarks())

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
	local hideCallback = nil
	local dataTypeSelectSound = nil
	local resetControlCallback = nil
	local selectTemplate = "ZO_ThinListHighlight"
	local selectCallback = OnRowSelect

	ZO_ScrollList_AddDataType(control, 0, "MapSearch_WorldMapCategoryRow", 50, LayoutCategoryRow, hideCallback, dataTypeSelectSound, resetControlCallback)
	ZO_ScrollList_AddDataType(control, 1, "MapSearch_WorldMapWayshrineRow", 27, LayoutRow, hideCallback, dataTypeSelectSound, resetControlCallback)

	ZO_ScrollList_EnableSelection(control, selectTemplate, selectCallback)
end

local function getTargetNode(results)
	local currentNodeIndex = 0

    local scrollData = ZO_ScrollList_GetDataList(MapSearch_WorldMapTabList)
    MT.scrollData = scrollData

    for i = 1, #scrollData do
        if scrollData[i].typeId == 1 then -- wayshrine row
            if currentNodeIndex == MapSearch.targetNode then
                return scrollData[i].data
            end
            currentNodeIndex = currentNodeIndex + 1
        end
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
    ZO_ScrollList_ScrollDataIntoView(MapSearch_WorldMapTabList, MapSearch.targetNode + 1, nil, true)
end

function MT.previousResult()
	MapSearch.targetNode = MapSearch.targetNode - 1
	if MapSearch.targetNode < 0 then
		MapSearch.targetNode = MT.resultCount - 1
	end
	buildScrollList(MapSearch_WorldMapTabList, MapSearch.results)
    ZO_ScrollList_ScrollDataIntoView(MapSearch_WorldMapTabList, MapSearch.targetNode + 1, nil, true)
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

local function showWayshrineMenu(owner, nodeIndex)
	ClearMenu()

    local bookmarks = MapSearch.Bookmarks
	if bookmarks:contains(nodeIndex) then
		AddMenuItem("Remove Bookmark", function()
			bookmarks:remove(nodeIndex)
			ClearMenu()
            buildScrollList(MapSearch_WorldMapTabList, MapSearch.results)
		end)
	else
		AddMenuItem("Add Bookmark", function()
			bookmarks:add(nodeIndex)
			ClearMenu()
            buildScrollList(MapSearch_WorldMapTabList, MapSearch.results)
		end)
	end
	ShowMenu(owner)
end

function MT:rowMouseUp(control, mouseButton, upInside)
	--MapSearch.clickedControl = { control, mouseButton, upInside }

	if(upInside) then
		local data = ZO_ScrollList_GetData(control)
        if mouseButton == 1 then
            showWayshrineConfirm(data, MapSearch.isRecall)
		elseif mouseButton == 2 then
			showWayshrineMenu(control, data.nodeIndex)
		end
	end

end

MapSearch.MapTab = MT