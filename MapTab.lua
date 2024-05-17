local MapTab = MapSearch.class()
MapSearch.MapTab = MapTab

local Utils = MapSearch.Utils
local logger = LibDebugLogger(MapSearch.name)




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

local function getCategories()
	local categories = {}
	local locations = MapSearch.Location.Data.GetList()

	for i, map in ipairs(locations) do
		if map.zoneId ~= nil then
			print(" - "..map.zoneId.." - "..map.name)
			categories[map.zoneIndex] = map
		end
	end

	return categories
end

function MapTab:init(control)
	self.control = control
	
    -- logger:Info("MapTab:init: "..self.control.list)

    local control = MapSearch_WorldMapTabList

    local typeId = 0
	local templateName = "MapSearch_WorldMapWayshrineRow" --"ZO_SelectableLabel"
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

    local data = MapSearch.Wayshrine.Data

    local scrollData = ZO_ScrollList_GetDataList(control)

	local categories = getCategories()
	for index, map in pairs(categories) do
		local entry = ZO_ScrollList_CreateDataEntry(0, {name = map.name})
		table.insert(scrollData, entry)
	end
    
	ZO_ScrollList_Commit(control)

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


function MapTab:Refresh(...)

end

