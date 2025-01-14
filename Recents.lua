local MS = MapSearch
local Recents = MS.Recents or {
    nodes = {},
    maxEntries = 10
}
local logger = MS.logger
local FTrecent = nil

function Recents:init()
    self.nodes = MS.saved.recentNodes or {}
    self.maxEntries = MS.saved.maxRecent or 10

    if _G["FasterTravel"] ~= nil and
       _G["FasterTravel"].settings ~= nil and
       _G["FasterTravel"].settings.recentsEnabled then
        logger:Debug("FasterTravel is active")
        FTrecent = _G["FasterTravel"].settings.recent
        -- logger:Debug(FT.settings.recent)
    else
        self:addTravelDialogCallbacks()
        self:hook(true)
    end
end

function Recents:insert(nodeIndex)
    if nodeIndex == 211 or nodeIndex == 212 then
        -- Always store The Harborage as index 210
        nodeIndex = 210
    end

    for i = 1, #self.nodes do
        if self.nodes[i] == nodeIndex then
            table.remove(self.nodes, i)
            logger:Debug("Recents:insert("..nodeIndex..") removed existing entry #"..i)
            break
        end
    end
    if #self.nodes >= self.maxEntries then
        table.remove(self.nodes)
        logger:Debug("Recents:insert("..nodeIndex..") removed overflow entry #"..#self.nodes)
    end
    table.insert(self.nodes, 1, nodeIndex)
    logger:Debug("Recents:insert("..nodeIndex..")")
    self:save()
end

function Recents:save()
    MS.saved.recentNodes = self.nodes
    MS.saved.maxRecent = self.maxEntries
end

function Recents:getRecents()
    local results = {}
    local nodeMap = MS.Locations:getNodeMap()

    if nodeMap ~= nil then
        for i = 1, #self.nodes do
            local node = MS.Utils.shallowCopy(nodeMap[self.nodes[i]])
            node.known = MS.Locations:isKnownNode(node.nodeIndex)
            table.insert(results, node)
        end
    end

    return results
end

function Recents:onPlayerActivated()
    if FTrecent ~= nil and #FTrecent >= 1 then
        -- Pull the most recent nodeIndex from FasterTravel
        local nodeIndex = FTrecent[1].nodeIndex
        logger:Debug("Recents:onPlayerActivated: adding recent from FasterTravel: "..nodeIndex)
        self:insert(nodeIndex)
    end
end

local travelDialogs = {
    FAST_TRAVEL_CONFIRM = {},
    TRAVEL_TO_HOUSE_CONFIRM = {},
    RECALL_CONFIRM = {}
}

-- replacement callbacks factory
local function MyCallbackFactory(name)
    return function(dialog)
        logger:Debug("Callback %s", name)
        local node = dialog.data
        if node.nodeIndex then -- is nil when travelling to house since U29
            Recents:insert(node.nodeIndex)
        end
        if travelDialogs[name].saved_callback then -- call the original callback if not nil
            travelDialogs[name].saved_callback(dialog)
        end
    end
end

function Recents.addTravelDialogCallbacks()
	-- find the original dialogs for RECALL_CONFIRM and FAST_TRAVEL_CONFIRM
	for name, data in pairs(travelDialogs) do
		-- extract "Confirm" callbacks if any and save them
		if 	ESO_Dialogs[name] and
			ESO_Dialogs[name].buttons and
			ESO_Dialogs[name].buttons[1] then 
				data.saved_callback = ESO_Dialogs[name].buttons[1].callback -- may be nil
                logger:Debug("Saved callback for travel dialog '"..name.."'")
        end
		-- create new callbacks
        logger:Debug("Adding callback for travel dialog '"..name.."'")
		data.my_callback = MyCallbackFactory(name)
	end
end

Recents.__Hook_Checker = function(name, node, params, ...)
    logger:Debug("HookChecker: %s", name)
    if travelDialogs[name] then
        logger:Debug("Hook checkpoint TRAVEL")
        -- replace callbacks
        for name, data in pairs(travelDialogs) do
            if 	ESO_Dialogs[name] and 
                ESO_Dialogs[name].buttons and
                ESO_Dialogs[name].buttons[1] then 
                    if ESO_Dialogs[name].buttons[1].callback ~= data.my_callback then
                        if ESO_Dialogs[name].buttons[1].callback == data.saved_callback then
                            ESO_Dialogs[name].buttons[1].callback = data.my_callback
                        else
                            logger:Debug(
                                "Something nasty going on - who else modifies %s dialog?!",
                                name
                            )
                        end
                    end
            else --[[
                Bandits UI has an option to turn off fast travel confirmations
                which sets ESO_Dialogs[name].buttons to nil 
                but if it is in use, all travels are autoconfirmed!
                so we can add the wayshrine to Recents without further consideration
                ]]--
                if node.nodeIndex then 
                    Recents:insert(node.nodeIndex)
                end
            end
        end
    else
        logger:Debug("Hook checkpoint NON-TRAVEL")
        -- restore original callbacks
        for name, data in pairs(travelDialogs) do
            if 	ESO_Dialogs[name] and 
                ESO_Dialogs[name].buttons and
                ESO_Dialogs[name].buttons[1] then 
                    if ESO_Dialogs[name].buttons[1].callback ~= data.saved_callback then
                        if ESO_Dialogs[name].buttons[1].callback == data.my_callback then
                            ESO_Dialogs[name].buttons[1].callback = data.saved_callback
                        else
                            logger:Debug(
                                "Something nasty going on - who else modifies %s dialog?!",
                                name
                            )
                        end
                    end
            end
        end
    end
    return false -- true == I've done everything, don't call ZO_Dialogs_ShowPlatformDialog
end

function Recents:hook(enabled)
    if enabled then
        ZO_PreHook("ZO_Dialogs_ShowPlatformDialog", self.__Hook_Checker)
    else
        ZO_PreHook("ZO_Dialogs_ShowPlatformDialog", function() return false end)
    end
end

MS.Recents = Recents