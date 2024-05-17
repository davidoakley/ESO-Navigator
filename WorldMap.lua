--xml backend

local Tab = MapSearch_WorldMapTab
--MapSearch.WorldMapInfoControl.Initialise(Tab)

Tab.rowOffsetX = 20

function Tab:IconMouseEnter(...)

end

function Tab:IconMouseExit(...)

end

function Tab:IconMouseDown(icon, button,data )
    if(button == 1) then
	
	end
end

function Tab:IconMouseUp(icon, button,data)
    if(button == 1) then
		self:IconMouseClicked(icon,data)
	end
end

function Tab:IconMouseClicked(...)

end


function Tab:RowMouseEnter(control, label ,data)
	ZO_SelectableLabel_OnMouseEnter(label)

end 

function Tab:RowMouseExit(control, label, data)
	ZO_SelectableLabel_OnMouseExit(label)

end

local function RefreshIcon(data, control, icon)
	local idata = data ~= nil and data.icon
	local hidden = idata == nil or idata.hidden == nil or idata.hidden
	
	icon:SetHidden(hidden)
	
	if hidden then return end 
	
	icon:SetResizeToFitFile(false)
	
	icon:SetTexture(idata.path)
	
	if idata.size ~= nil then 
		if idata.size.width ~= nil then 
			icon:SetWidth(idata.size.width)
		end
		if idata.size.height ~= nil then 
			icon:SetHeight(idata.size.height)
		end 
	end 
	
	-- set anchor
	icon:ClearAnchors()
	
	if idata.offset ~= nil then 
		icon:SetAnchor(TOPLEFT,control,TOPLEFT,idata.offset.x,idata.offset.y)
	else
		icon:SetAnchor(TOPLEFT,control,TOPLEFT,-6,-2)
	end
		 
end

function Tab:OnRefreshRow(control,data)
	local icon = control.icon 
	
	control.RowMouseEnter = function(c,label) self:RowMouseEnter(c,label,data) end 
	control.RowMouseExit = function(c,label) self:RowMouseExit(c,label,data) end
	if icon then
		control.IconMouseEnter = function(c,icon) self:IconMouseEnter(icon,data) end 
		control.IconMouseExit = function(c,icon) self:IconMouseExit(icon,data) end 
		control.IconMouseDown = function(c,icon,button) self:IconMouseDown(icon,button,data) end 
		control.IconMouseUp = function(c,icon,button) self:IconMouseUp(icon,button,data) end 
		RefreshIcon(data,control,icon)
	end
end

