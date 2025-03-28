Navigator = {
  name = "Navigator",
  menuName = "Navigator",          -- A UNIQUE identifier for menu object.
  displayName = "|c66CC66N|r|c66CCFFavigator|r",
  settingsName = "NavigatorSettings",
  author = "SirNightstorm",
  appVersion = "0",
  svName = "Navigator_SavedVariables",
  Location = {},
  Wayshrine = {},
  Search = {},
  isCLI = false,
  isDeveloper = (GetDisplayName() == '@SirNightstorm' and true) or false,
  results = {},
  mapVisible = false,
  currentNodeIndex = nil,
}
local Nav = Navigator

Nav.CONFIRMFASTTRAVEL_ALWAYS = 0
Nav.CONFIRMFASTTRAVEL_WHENCOST = 1
Nav.CONFIRMFASTTRAVEL_NEVER = 2

Nav.ACTION_SHOWONMAP = 0
Nav.ACTION_SETDESTINATION = 1
Nav.ACTION_TRAVEL = 2
Nav.ACTION_TRAVELOUTSIDE = 3
Nav.ACTION_VISITHOUSE = 4

Nav.JUMPSTATE_WORLD = 0
Nav.JUMPSTATE_WAYSHRINE = 1
Nav.JUMPSTATE_CYRODIIL = 2
Nav.JUMPSTATE_TRANSITUS = 3
Nav.jumpState = Nav.JUMPSTATE_WORLD

Nav.default = {
  recentNodes = {},
  bookmarks = {},
  defaultTab = true,
  autoFocus = false,
  includeUndiscovered = false,
  tpCommand = "/nav",
  loggingEnabled = false,
  recentsCount = 10,
  ignoreDefiniteArticlesInSort = false,
  listPOIs = true,
  useHouseNicknames = false,
  destinationActions = {
      singleClick = Nav.ACTION_TRAVEL,
      doubleClick = Nav.ACTION_TRAVEL,
      enterKey = Nav.ACTION_TRAVEL,
      slash = Nav.ACTION_TRAVEL
  },
  zoneActions = {
      singleClick = Nav.ACTION_SHOWONMAP,
      doubleClick = Nav.ACTION_TRAVEL,
      enterKey = Nav.ACTION_SHOWONMAP,
      slash = Nav.ACTION_TRAVEL
  },
  poiActions = {
      singleClick = Nav.ACTION_SHOWONMAP,
      doubleClick = Nav.ACTION_SETDESTINATION,
      enterKey = Nav.ACTION_SHOWONMAP,
      slash = Nav.ACTION_SHOWONMAP
  },
  houseActions = {
      singleClick = Nav.ACTION_TRAVEL,
      doubleClick = Nav.ACTION_TRAVELOUTSIDE,
      enterKey = Nav.ACTION_TRAVEL,
      slash = Nav.ACTION_TRAVEL
  },
  singleClickZone = false,
  confirmFastTravel = Nav.CONFIRMFASTTRAVEL_ALWAYS
}

local logger = LibDebugLogger and LibDebugLogger(Nav.name)

local _events = {}

function Nav.log(...)
  if logger and Nav.saved and Nav.saved["loggingEnabled"] then
    logger:Debug(string.format(...))
  end
end

function Nav.logWarning(...)
  if logger and Nav.saved and Nav.saved["loggingEnabled"] then
    logger:Warn(string.format(...))
  end
end

function Nav.mkstr(id, str)
    if _G[id] then
        SafeAddString(_G[id], str, 1)
    else
        ZO_CreateStringId(id, str)
        SafeAddVersion(id, 1)
    end
end

local function GetUniqueEventId(id)
  local count = _events[id] or 0
  count = count + 1
  _events[id] = count
  return count
end

local function getEventName(id)
  return table.concat({ Nav.name, tostring(id), tostring(GetUniqueEventId(id)) }, "_")
end

local function addEvent(id, func)
  local name = getEventName(id)
  EVENT_MANAGER:RegisterForEvent(name, id, func)
end

local function addEvents(func, ...)
  local count = select('#', ...)
  local id
  for i = 1, count do
  id = select(i, ...)
  if not id then
    df('%s element %d is nil.  Please report.', Nav.name, i)
  else
    addEvent(id, func)
  end
  end
end


local ButtonGroup

local function OnMapStateChange(_, newState)
    if not ButtonGroup then
        ButtonGroup = {
            {
                name = GetString(NAVIGATOR_KEYBIND_SEARCH),
                keybind = "NAVIGATOR_OPENTAB", --"UI_SHORTCUT_QUICK_SLOTS", --"NAVIGATOR_SEARCH",
                order = 200,
                visible = function() return true end,
                callback = function() Nav.showSearch() end,
            },
            alignment = KEYBIND_STRIP_ALIGN_CENTER,
        }
    end

  if newState == SCENE_SHOWING then
    Nav.mapVisible = true
    local zone = Nav.Locations:getCurrentMapZone()
    Nav.initialMapZoneId = zone and zone.zoneId or nil
    Nav.log("WorldMap showing; initialMapZoneId=%d", Nav.initialMapZoneId or 0)
    PushActionLayerByName("Map")
    KEYBIND_STRIP:AddKeybindButtonGroup(ButtonGroup)
    if Nav.saved and Nav.saved["defaultTab"] and not FasterTravel then
      WORLD_MAP_INFO:SelectTab(NAVIGATOR_TAB_SEARCH)
    end
    Nav.Locations:SetTreasureData()

    if zone and Nav.Locations:ShouldCollapseCategories(zone.zoneId) then
        Nav.MapTab.collapsedCategories = { bookmarks = true, recents = true }
    else
        Nav.MapTab.collapsedCategories = {}
    end
  elseif newState == SCENE_HIDDEN then
    Nav.log("WorldMap hidden")
    Nav.mapVisible = false
    KEYBIND_STRIP:RemoveKeybindButtonGroup(ButtonGroup)
    RemoveActionLayerByName("Map")
  end
end

local function OnMapChanged()
    if Nav.MapTab.visible then
        Nav.Locations:UpdateKeeps()
        Nav.MapTab:ImmediateRefresh()
    else
    end
  Nav.MapTab:OnMapChanged()
end

local function OnStartFastTravel(eventCode, nodeIndex)
    Nav.jumpState = Nav.JUMPSTATE_WAYSHRINE
    Nav.currentNodeIndex = nodeIndex
    Nav.log("OnStartFastTravel(%d,%d) jumpState %d", eventCode, nodeIndex, Nav.jumpState)
    Nav.MapTab:ImmediateRefresh()
end

local function OnStartFastTravelKeep(eventCode, nodeIndex)
    Nav.jumpState = Nav.JUMPSTATE_TRANSITUS
    Nav.Locations:UpdateKeeps()
    Nav.log("OnStartFastTravelKeep(%d,%d) jumpState %d", eventCode, nodeIndex, Nav.jumpState)
    Nav.MapTab:ImmediateRefresh()
end

local function OnEndFastTravel()
  Nav.jumpState = Nav.currentZoneId == Nav.ZONE_CYRODIIL and Nav.JUMPSTATE_CYRODIIL or Nav.JUMPSTATE_WORLD
  Nav.currentNodeIndex = nil
  Nav.Locations:SetKeepsInaccessible()
  Nav.log("OnEndFastTravel() jumpState %d", Nav.jumpState)
end

local function OnPlayerActivated()
  Nav.Recents:onPlayerActivated()
  Nav.currentZoneId = ZO_ExplorationUtils_GetPlayerCurrentZoneId()
  Nav.jumpState = Nav.currentZoneId == Nav.ZONE_CYRODIIL and Nav.JUMPSTATE_CYRODIIL or Nav.JUMPSTATE_WORLD
  Nav.log("OnPlayerActivated() zoneId %d jumpState %d", Nav.currentZoneId, Nav.jumpState)
end

local function OnPOIUpdated()
  Nav.Locations:clearKnownNodes()
end

local function SetPlayersDirty(_)
  -- Nav.log("SetPlayersDirty("..eventCode..")")
  Nav.Players:ClearPlayers()
  Nav.MapTab:queueRefresh()
end

local function SetKeepsDirty(_)
    Nav.Locations:SetKeepsDirty()
    Nav.MapTab:queueRefresh()
end

function Nav.showSearch(callback)
    Nav.log("showSearch")
    local tabVisible = Nav.MapTab.visible
    MAIN_MENU_KEYBOARD:ShowScene("worldMap")
    WORLD_MAP_INFO:SelectTab(NAVIGATOR_TAB_SEARCH)
    Nav.MapTab:resetSearch()
    if Nav.saved.autoFocus or tabVisible then
        Nav.MapTab.editControl:TakeFocus()
        Nav.log("showSearch: setting editControl focus")
    end
    if callback then
        callback()
    end
end

local function moveTabToFirst()
  local buttons = WORLD_MAP_INFO.modeBar.menuBar.m_object.m_buttons
  local ourButton = buttons[#buttons]
  buttons[#buttons] = nil
  table.insert(buttons, 1, ourButton)

  local buttonData = WORLD_MAP_INFO.modeBar.buttonData
  local ourData = buttonData[#buttonData]
  buttonData[#buttonData] = nil
  table.insert(buttonData, 1, ourData)

  WORLD_MAP_INFO.modeBar:UpdateButtons(false)
  Nav.log("Menu re-ordered")
end

function Nav:initialize()
  Nav.log("initialize starts")
  -- https://wiki.esoui.com/How_to_add_buttons_to_the_keybind_strip

  self.saved = ZO_SavedVars:NewAccountWide(self.svName, 1, nil, self.default)

  SCENE_MANAGER:GetScene('worldMap'):RegisterCallback("StateChange", OnMapStateChange)

  self.currentAlliance = GetUnitAlliance("player")

  self.MapTab:init()
  self.Recents:init()
  self.Bookmarks:init()
  self.Chat:Init()
  self:loadSettings()

  CALLBACK_MANAGER:RegisterCallback("OnWorldMapChanged", OnMapChanged)
  CALLBACK_MANAGER:RegisterCallback("OnWorldMapModeChanged", OnMapChanged)

  addEvent(EVENT_START_FAST_TRAVEL_INTERACTION, OnStartFastTravel)
  addEvent(EVENT_START_FAST_TRAVEL_KEEP_INTERACTION, OnStartFastTravelKeep)
  addEvent(EVENT_END_FAST_TRAVEL_INTERACTION, OnEndFastTravel)
  addEvent(EVENT_END_FAST_TRAVEL_KEEP_INTERACTION, OnEndFastTravel)
  addEvent(EVENT_PLAYER_ACTIVATED, OnPlayerActivated)

  addEvents(OnPOIUpdated, EVENT_POI_DISCOVERED, EVENT_POI_UPDATED, EVENT_FAST_TRAVEL_NETWORK_UPDATED)

  addEvents(SetPlayersDirty,
    EVENT_GROUP_MEMBER_JOINED, EVENT_GROUP_MEMBER_LEFT, EVENT_GROUP_MEMBER_CONNECTED_STATUS,
    EVENT_GUILD_SELF_JOINED_GUILD, EVENT_GUILD_SELF_LEFT_GUILD, EVENT_GUILD_MEMBER_ADDED, EVENT_GUILD_MEMBER_REMOVED,
    EVENT_GUILD_MEMBER_CHARACTER_ZONE_CHANGED, EVENT_FRIEND_CHARACTER_ZONE_CHANGED,
    EVENT_FRIEND_ADDED, EVENT_FRIEND_REMOVED, EVENT_GROUP_MEMBER_ROLE_CHANGED)

  addEvent(EVENT_GUILD_MEMBER_PLAYER_STATUS_CHANGED, function(_, _, _, oldStatus, newStatus)
    if newStatus == PLAYER_STATUS_OFFLINE or (oldStatus == PLAYER_STATUS_OFFLINE and newStatus == PLAYER_STATUS_ONLINE) then
      SetPlayersDirty()
    end
  end)

  addEvents(SetKeepsDirty, EVENT_FAST_TRAVEL_NETWORK_UPDATED, EVENT_FAST_TRAVEL_KEEP_NETWORK_UPDATED,
          EVENT_FAST_TRAVEL_KEEP_NETWORK_LINK_CHANGED, EVENT_CAMPAIGN_STATE_INITIALIZED,
          EVENT_CAMPAIGN_SELECTION_DATA_CHANGED, EVENT_CURRENT_CAMPAIGN_CHANGED, EVENT_ASSIGNED_CAMPAIGN_CHANGED,
          EVENT_KEEPS_INITIALIZED, EVENT_KEEP_ALLIANCE_OWNER_CHANGED, EVENT_KEEP_UNDER_ATTACK_CHANGED
  )

  local buttonData = {
    pressed = "Navigator/media/tabicon_down.dds",
    highlight = "Navigator/media/tabicon_over.dds",
    normal = "Navigator/media/tabicon_up.dds",
    callback = function()
      -- Hide the modebar title
      WORLD_MAP_INFO.modeBar.label:SetText("")
    end
  }

  WORLD_MAP_INFO.modeBar:Add(NAVIGATOR_TAB_SEARCH, { self.MapTab.fragment }, buttonData)
  if self.saved["defaultTab"] and not FasterTravel then
    moveTabToFirst()
  end

  Nav.log("Initialize exits")
end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= "Navigator" then return end

    Nav:initialize()

    if PP and PP.ADDON_NAME then
        local success, error = pcall(function()
            PP.ScrollBar(Navigator_MapTabListScrollBar)
            ZO_Scroll_SetMaxFadeDistance(Navigator_MapTabList, PP.savedVars.ListStyle.list_fade_distance)
        end)
        if not success then
            Nav.logWarning("OnAddOnLoaded: PP error '%s'", error)
        end
    end

    EVENT_MANAGER:UnregisterForEvent(Nav.name, EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent(Nav.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
