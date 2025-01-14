MapSearch = {
  name = "MapSearch",
  menuName = "Map Search",          -- A UNIQUE identifier for menu object.
  author = "SirNightstorm",
  version = "0.1.0",
  svName = "MapSearch_SavedVariables",
  default = {
    recentNodes = {},
    maxRecent = 10,
    bookmarkNodes = {},
    defaultTab = false,
    autoFocus = false,
    tpCommand = "None"
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

local function AddWorldMapFragment(strId, fragment, normal, highlight, pressed)
  WORLD_MAP_INFO.modeBar:Add(strId, { fragment }, { pressed = pressed, highlight = highlight, normal = normal })
  end

local function GetPaths(path, ...)
  return unpack(Utils.map({ ... }, function(p)
    return path .. p
  end))
end

local function OnMapStateChange(oldState, newState)
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

  if newState == SCENE_SHOWING then
    logger:Debug("WorldMap showing")
    MS.mapVisible = true
    local zone = MS.Locations:getCurrentMapZone()
    MS.initialMapZoneId = zone and zone.zoneId or nil
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
  ZO_CreateStringId("MAPSEARCH_OPENTAB","Open Search tab (on Map screen)")
  ZO_CreateStringId("SI_BINDING_NAME_MAPSEARCH_SEARCH", "Open Map Search")
  ZO_CreateStringId("MAPSEARCH_TAB_SEARCH","Search")
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
  addEvent(EVENT_POI_DISCOVERED , OnPOIUpdated)
  addEvent(EVENT_POI_UPDATED, OnPOIUpdated)

  -- local normal, highlight, pressed = GetPaths("/esoui/art/guild/guildhistory_indexicon_guildstore_", "up.dds", "over.dds", "down.dds")
  local normal = "/esoui/art/tradinghouse/tradinghouse_browse_tabicon_up.dds"
  local highlight = "/esoui/art/tradinghouse/tradinghouse_browse_tabicon_over.dds"
  local pressed = "/esoui/art/tradinghouse/tradinghouse_browse_tabicon_down.dds"

  AddWorldMapFragment(MAPSEARCH_TAB_SEARCH, self.MapTab.fragment, normal, highlight, pressed)

  logger:Debug("Initialize exits")
end

local function OnAddOnLoaded(_, addonName)
  if addonName ~= "MapSearch" then return end

  MS:initialize()

  EVENT_MANAGER:UnregisterForEvent(MS.name, EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent(MS.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

SLASH_COMMANDS["/mapsearch"] = function (extra)
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
end
