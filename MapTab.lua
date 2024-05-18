local MapTab = MapSearch.class()
MapSearch.MapTab = MapTab

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

	rowControl.label:SetText(data.name)
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


--------------------------------------------------
-- Step 7: Process the selection.
-- If the user has selected a pet, summon that pet
--------------------------------------------------
local function OnRowSelect(previouslySelectedData, selectedData, reselectingDuringRebuild)
    if not selectedData then return end
    --UseCollectible(selectedData.index)
end

local function getZoneWayshrines(zoneIndex)
	local data = {}

	--logger:Info("zoneIndex "..zoneIndex)
	local iter = MapSearch.Wayshrine.GetKnownWayshrinesByZoneIndex(zoneIndex,-1)
	-- iter = Utils.map(iter,function(item)
	-- 	if item.traders_cnt then
	-- 		item.name = string.format("|ce000e0%1d|r %s", -- magenta
	-- 			item.traders_cnt, Utils.ShortName(item.name))
	-- 	else
	-- 		item.name = empty_prefix .. Utils.ShortName(item.name)
	-- 	end
	-- 	return AttachWayshrineDataHandlers(args,item)
	-- end)

	data = {}
	for i in iter do
		-- if i.traders_cnt then
			table.insert(data, i)
		-- end
	end

	return data
end

local function getCategories()
	local categories = {}
	local locations = MapSearch.Location.Data.GetList()

	for i, map in ipairs(locations) do
		if map.zoneId ~= nil then
			print(" - "..map.zoneId.." - "..map.name)

			local nodes = getZoneWayshrines(map.zoneIndex)
			table.sort(nodes, Utils.SortByBareName)
			map.nodes = nodes
	
			--categories[map.zoneIndex] = map
			table.insert(categories, map)
		end
	end

	return categories
end

local function deepCopy(obj)
    if type(obj) ~= 'table' then return obj end
    local res = {}
    for k, v in pairs(obj) do res[deepCopy(k)] = deepCopy(v) end
    return res
end

local function nocase (s)
    s = string.gsub(s, "%a", function (c)
          return string.format("[%s%s]", string.lower(c),
                                         string.upper(c))
        end)
    return s
end
  

local function filter(categoriesRef, searchTerm)
    local categories = deepCopy(categoriesRef)
    searchTerm = nocase(searchTerm)

    for i, category in ipairs(categories) do
        if string.find(category.name, searchTerm) then
            category.show = true
        end
        for j, node in ipairs(category.nodes) do
            if string.find(node.name, searchTerm) then
                node.show = true
                category.showNodes = true
            end
        end
    end

    local result = {}
    for i, category in ipairs(categories) do
        if category.show then
            table.insert(result, category)
        elseif category.showNodes then
            local resultNodes = {}
            for j, node in ipairs(category.nodes) do
                if node.show then
                    table.insert(resultNodes, node)
                end
            end
            category.nodes = resultNodes
            table.insert(result, category)
        end
    end

    return result
end


local function buildCategories()
	local categories = getCategories()
	table.sort(categories, Utils.SortByBareName)

	MapSearch.categories = categories
end

local function buildScrollList(control, searchString)

	ZO_ScrollList_Clear(control)

    local scrollData = ZO_ScrollList_GetDataList(control)

	if MapSearch.categories == nil then
		buildCategories()
	end

	local categories

	if searchString ~= nil and #searchString > 0 then
		categories = filter(MapSearch.categories, searchString)
	else
		categories = MapSearch.categories
	end

	local filteredCats = filter(categories, "sto")

	-- MapSearch.categories = categories
	-- MapSearch.saved.categories = categories

	for index, map in ipairs(categories) do
		local nodes = map.nodes -- getZoneWayshrines(map.zoneIndex)
		-- table.sort(nodes, Utils.SortByBareName)

		local categoryData = {
			name = map.name,
			barename = Utils.BareName(map.name)
		}

		if #nodes >= 1 then
			local entry = ZO_ScrollList_CreateDataEntry(0, categoryData)
			table.insert(scrollData, entry)
	
			for nodeIndex, nodeMap in ipairs(nodes) do
				local nodeData = {
					name = nodeMap.name,
					barename = Utils.BareName(nodeMap.name)
				}
		
				local entry = ZO_ScrollList_CreateDataEntry(1, nodeData)
				table.insert(scrollData, entry)
			end

			--table.insert(MapSearch.categories, categoryData)
		end
	end
    
	ZO_ScrollList_Commit(control)
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

	ZO_ScrollList_AddDataType(control, 0, "MapSearch_WorldMapCategoryRow", height, setupFunction, hideCallback, dataTypeSelectSound, resetControlCallback)
	ZO_ScrollList_AddDataType(control, 1, "MapSearch_WorldMapWayshrineRow", height, setupFunction, hideCallback, dataTypeSelectSound, resetControlCallback)

	ZO_ScrollList_EnableSelection(control, selectTemplate, selectCallback)
end

function MapTab:init(tabControl)
	logger:Info("MapTab:init")
	self.tabControl = tabControl

    local control = MapSearch_WorldMapTabList
	self.listControl = control

	setupScrollList(control)

	buildScrollList(control)

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

function MapTab:AddCategory(categoryId,item)

	local refresh = item.refresh 
	local clicked = item.clicked
	
	item.clicked =  function(data,c) 
							if clicked then 
								clicked(data,c)
							else
								self:SetCategoryHidden(categoryId,not self:IsCategoryHidden(categoryId)) 
							end
						end
	item.refresh =  function(data,c)
							c.label:SetText(data.name) 
							if refresh then
								
								refresh(data,c)
							end
						end
	--item.data = nil 
	local header = Utils.extend(item)
	header.hidden = nil 
	self.control:AddCategory(self.control.list,header,categoryId)
	return header
end

function MapTab:AddCategories(data, tab) -- tab = 0 for Players, 1 for Wayshrines
	local categoryId = 1
	local parentId
	
	local hideRecents = (tab == 1) and not TraderTravel.settings.recentsEnabled 
	local categories = {}
	
	for i,item in ipairs(data) do 
		if i ~= TraderTravel.settings.recentsPosition or not hideRecents then
			categories[i] = self:AddCategory(categoryId,item)
			if #item.data > 0 then
				self.control:AddEntries(self.control.list,item.data,1,categoryId)
				item.categoryId=categoryId
			end
		end
		categoryId = categoryId + 1
	end
	return categories
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
	buildScrollList(listcontrol, searchString)
end