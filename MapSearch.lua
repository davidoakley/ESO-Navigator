MapSearch = {}
local MS = MapSearch
MS.name = "MapSearch"
MS.svName = "MapSearch_SavedVariables"
MS.default = {
  recentNodes = {},
  maxRecent = 10,
  bookmarkNodes = {}
}
MS.Location = {}
MS.Wayshrine = {}
MS.Search = {}
MS.isRecall = true
MS.isCLI = false
MS.isDeveloper = (GetDisplayName() == '@SirNightstorm' and true) or false

-- Make this properly localisable!
ZO_CreateStringId("MAPSEARCH_SEARCH","Search")
ZO_CreateStringId("SI_BINDING_NAME_MAPSEARCH_SEARCH", "Search")
ZO_CreateStringId("MAPSEARCH_TAB_SEARCH","Search")

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

function MS:initialize()
  logger:Info("MS.initialize starts")
  -- https://wiki.esoui.com/How_to_add_buttons_to_the_keybind_strip

  self.saved = ZO_SavedVars:NewAccountWide(self.svName, 1, nil, self.default)

  local mapTabControl = MapSearch_WorldMapTab
  
  local ButtonGroup = {
		{
			name = "Search", --GetString(SI_BINDING_NAME_FASTER_TRAVEL_REJUMP),
			keybind = "UI_SHORTCUT_QUICK_SLOTS", --"MAPSEARCH_SEARCH",
			order = 200,
			visible = function() return true end,
			callback = function() self.showSearch() end,
		},
		alignment = KEYBIND_STRIP_ALIGN_CENTER,
	}

  SCENE_MANAGER:GetScene('worldMap'):RegisterCallback("StateChange",
    function(oldState, newState)
      if newState == SCENE_SHOWING then
        KEYBIND_STRIP:AddKeybindButtonGroup(ButtonGroup)
      elseif newState == SCENE_HIDDEN then
        KEYBIND_STRIP:RemoveKeybindButtonGroup(ButtonGroup)
      end
    end)

  -- local mapTab = MS.MapTab(mapTabControl)
  self.MapTab:init(mapTabControl)
  self.Recents:init()
  self.Bookmarks:init()

  -- local normal, highlight, pressed = GetPaths("/esoui/art/guild/guildhistory_indexicon_guildstore_", "up.dds", "over.dds", "down.dds")
  local normal = "/esoui/art/tradinghouse/tradinghouse_browse_tabicon_up.dds"
  local highlight = "/esoui/art/tradinghouse/tradinghouse_browse_tabicon_over.dds"
  local pressed = "/esoui/art/tradinghouse/tradinghouse_browse_tabicon_down.dds"

  AddWorldMapFragment(MAPSEARCH_TAB_SEARCH, mapTabControl.fragment, normal, highlight, pressed)

  logger:Info("MS.Initialize exits")
end

-- Then we create an event handler function which will be called when the "addon loaded" event
-- occurs. We'll use this to initialize our addon after all of its resources are fully loaded.
local function onAddOnLoaded(event, addonName)
  -- The event fires each time *any* addon loads - but we only care about when our own addon loads.
  if addonName ~= "MapSearch" then return end

  MS:initialize()

  --unregister the event again as our addon was loaded now and we do not need it anymore to be run for each other addon that will load
  EVENT_MANAGER:UnregisterForEvent(MS.name, EVENT_ADD_ON_LOADED)
end

local function onStartFastTravel(eventCode, nodeIndex)
  logger:Info("onStartFastTravel: "..eventCode..", "..nodeIndex)
  MS.isRecall = false
end

local function onEndFastTravel()
  logger:Info("onEndFastTravel")
  MS.isRecall = true
end

local function onPlayerActivated()
  MS.Recents:onPlayerActivated()
end

function MS.showSearch()
  logger:Info("MS.showSearch")
  MAIN_MENU_KEYBOARD:ShowScene("worldMap")
  WORLD_MAP_INFO:SelectTab(MAPSEARCH_TAB_SEARCH)
  MS.MapTab:resetFilter(false)
  MapSearch_WorldMapTabSearchEdit:TakeFocus()
end

-- Finally, we'll register our event handler function to be called when the proper event occurs.
-->This event EVENT_ADD_ON_LOADED will be called for EACH of the addns/libraries enabled, this is why there needs to be a check against the addon name
-->within your callback function! Else the very first addon loaded would run your code + all following addons too.
EVENT_MANAGER:RegisterForEvent(MS.name, EVENT_ADD_ON_LOADED, onAddOnLoaded)

addEvent(EVENT_START_FAST_TRAVEL_INTERACTION, onStartFastTravel)
addEvent(EVENT_END_FAST_TRAVEL_INTERACTION, onEndFastTravel)
addEvent(EVENT_PLAYER_ACTIVATED, onPlayerActivated)

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
