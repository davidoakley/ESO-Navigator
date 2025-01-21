MapSearch = {
  name = "Navigator",
  menuName = "Navigator",          -- A UNIQUE identifier for menu object.
  settingsName = "NavigatorSettings",
  author = "SirNightstorm",
  appVersion = "0",
  svName = "Navigator_SavedVariables",
  default = {
    recentNodes = {},
    maxRecent = 10,
    bookmarkNodes = {},
    defaultTab = false,
    autoFocus = false,
    tpCommand = "/nav"
  },
  Location = {},
  Wayshrine = {},
  Search = {},
  isRecall = true,
  isCLI = false,
  isDeveloper = (GetDisplayName() == '@SirNightstorm' and true) or false,
  results = {},
  targetNode = 0,
  mapVisible = false,
}
local MS = MapSearch

local logger = LibDebugLogger(MS.name)
MS.logger = logger

local Utils = MS.Utils

local _events = {}

local function GetUniqueEventId(id)
  local count = _events[id] or 0
  count = count + 1
  _events[id] = count
  return count
end

local function getEventName(id)
  return table.concat({ MS.name, tostring(id), tostring(GetUniqueEventId(id)) }, "_")
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
    df('%s element %d is nil.  Please report.', MS.name, i)
  else
    addEvent(id, func)
  end
  end
end


local ButtonGroup = {
  {
    name = "Search", --GetString(SI_BINDING_NAME_FASTER_TRAVEL_REJUMP),
    keybind = "MAPSEARCH_OPENTAB", --"UI_SHORTCUT_QUICK_SLOTS", --"MAPSEARCH_SEARCH",
    order = 200,
    visible = function() return true end,
    callback = function() MS.showSearch() end,
    },
    alignment = KEYBIND_STRIP_ALIGN_CENTER,
  }

local function OnMapStateChange(oldState, newState)
  if newState == SCENE_SHOWING then
    MS.mapVisible = true
    local zone = MS.Locations:getCurrentMapZone()
    MS.initialMapZoneId = zone and zone.zoneId or nil
    logger:Debug(zo_strformat("WorldMap showing; initialMapZoneId=<<1>>", MS.initialMapZoneId or 0))
    PushActionLayerByName("Map")
    KEYBIND_STRIP:AddKeybindButtonGroup(ButtonGroup)
    if MS.saved and MS.saved["defaultTab"] then
      WORLD_MAP_INFO:SelectTab(MAPSEARCH_TAB_SEARCH)
    end
    logger:Debug("WorldMap showing done")
  elseif newState == SCENE_HIDDEN then
    logger:Debug("WorldMap hidden")
    MS.mapVisible = false
    KEYBIND_STRIP:RemoveKeybindButtonGroup(ButtonGroup)
    RemoveActionLayerByName("Map")
  end
end

local function OnMapChanged()
  logger:Debug("OnMapChanged")
  MS.MapTab.OnMapChanged()
end

local function OnStartFastTravel(eventCode, nodeIndex)
  logger:Debug("OnStartFastTravel: "..eventCode..", "..nodeIndex)
  MS.isRecall = false
end

local function OnEndFastTravel()
  logger:Debug("OnEndFastTravel")
  MS.isRecall = true
end

local function OnPlayerActivated()
  logger:Debug("OnPlayerActivated")
  MS.Recents:onPlayerActivated()
end

local function OnPOIUpdated()
  logger:Debug("OnPOIUpdated")
  MS.Locations:clearKnownNodes()
end

local function SetPlayersDirty(eventCode)
  -- logger:Debug("SetPlayersDirty("..eventCode..")")
  MS.Locations:ClearPlayers()
  MS.MapTab:queueRefresh()
end

function MS.showSearch()
  logger:Debug("showSearch")
  local tabVisible = MapSearch.MapTab.visible
  MAIN_MENU_KEYBOARD:ShowScene("worldMap")
  WORLD_MAP_INFO:SelectTab(MAPSEARCH_TAB_SEARCH)
  MS.MapTab:resetSearch(false)
  if MapSearch.saved.autoFocus or tabVisible then
    MS.MapTab.editControl:TakeFocus()
    logger:Debug("showSearch: setting editControl focus")
  end
end

function MS:CreateStrings()
  -- Make this properly localisable!
  local openTabBinding = ZO_Keybindings_GetHighestPriorityNarrationStringFromAction("MAPSEARCH_OPENTAB") or '-'
  -- openTabBinding = ZO_Keybindings_GenerateTextKeyMarkup(openTabBinding)
  ZO_CreateStringId("MAPSEARCH_SEARCH","Search locations, zones or @players")
  ZO_CreateStringId("MAPSEARCH_SEARCH_KEYPRESS","Search ("..openTabBinding..")")
  ZO_CreateStringId("MAPSEARCH_OPENTAB","Open Navigator tab (on Map screen)")
  ZO_CreateStringId("SI_BINDING_NAME_MAPSEARCH_SEARCH", "Open Map Navigator")
  ZO_CreateStringId("MAPSEARCH_TAB_SEARCH","Navigator")
end

local function moveTabToFirst()
  local buttons = WORLD_MAP_INFO.modeBar.menuBar.m_object.m_buttons
  local ourButton = buttons[#buttons]
  buttons[#buttons] = nil
  table.insert(buttons, 1, ourButton)
  WORLD_MAP_INFO.modeBar:UpdateButtons(false)
  logger:Debug("Menu re-ordered")
end

function MS:initialize()
  logger:Debug("initialize starts")
  -- https://wiki.esoui.com/How_to_add_buttons_to_the_keybind_strip

  self.saved = ZO_SavedVars:NewAccountWide(self.svName, 1, nil, self.default)

  self:CreateStrings()

  SCENE_MANAGER:GetScene('worldMap'):RegisterCallback("StateChange", OnMapStateChange)

  self.MapTab:init()
  self.Recents:init()
  self.Bookmarks:init()
  self.Chat:Init()
  self:loadSettings()

  CALLBACK_MANAGER:RegisterCallback("OnWorldMapChanged", OnMapChanged)
  CALLBACK_MANAGER:RegisterCallback("OnWorldMapModeChanged", OnMapChanged)

  addEvent(EVENT_START_FAST_TRAVEL_INTERACTION, OnStartFastTravel)
  addEvent(EVENT_END_FAST_TRAVEL_INTERACTION, OnEndFastTravel)
  addEvent(EVENT_PLAYER_ACTIVATED, OnPlayerActivated)

  addEvents(OnPOIUpdated, EVENT_POI_DISCOVERED, EVENT_POI_UPDATED, EVENT_FAST_TRAVEL_NETWORK_UPDATED)

  addEvents(SetPlayersDirty,
    EVENT_GROUP_MEMBER_JOINED, EVENT_GROUP_MEMBER_LEFT, EVENT_GROUP_MEMBER_CONNECTED_STATUS,
    EVENT_GUILD_SELF_JOINED_GUILD, EVENT_GUILD_SELF_LEFT_GUILD, EVENT_GUILD_MEMBER_ADDED, EVENT_GUILD_MEMBER_REMOVED,
    EVENT_GUILD_MEMBER_CHARACTER_ZONE_CHANGED, EVENT_FRIEND_CHARACTER_ZONE_CHANGED,
    EVENT_FRIEND_ADDED, EVENT_FRIEND_REMOVED)


  -- local normal, highlight, pressed = GetPaths("/esoui/art/guild/guildhistory_indexicon_guildstore_", "up.dds", "over.dds", "down.dds")
  local normal = "Navigator/media/tabicon_up.dds"
  local highlight = "Navigator/media/tabicon_over.dds"
  local pressed = "Navigator/media/tabicon_down.dds"

  WORLD_MAP_INFO.modeBar:Add(MAPSEARCH_TAB_SEARCH, { self.MapTab.fragment }, { pressed = pressed, highlight = highlight, normal = normal })
  moveTabToFirst()

  logger:Debug("Initialize exits")
end

local function OnAddOnLoaded(_, addonName)
  if addonName ~= "Navigator" then return end

  MS:initialize()

  EVENT_MANAGER:UnregisterForEvent(MS.name, EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent(MS.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

--[[SLASH_COMMANDS["/mapsearch"] = function (extra)
  if extra == 'save' then
      MapSearch.Locations:initialise()
      -- buildLocations()
      MapSearch.saved.locations = Utils.deepCopy(MS.Search.locations)
      MapSearch.saved.zones = Utils.deepCopy(MS.Search.zones)
      MapSearch.saved.result = Utils.deepCopy(MS.Search.result)
      d("Written MapSearch data to Saved Preferences")
  elseif extra == 'clear' then
      MapSearch.saved.categories = nil
      MapSearch.saved.locations = nil
      MapSearch.saved.zones = nil
      MapSearch.saved.result = nil
      d("Cleared MapSearch data from Saved Preferences")
  end
end ]]--