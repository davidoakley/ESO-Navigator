local Nav = Navigator --- @class Navigator

local function getActionSettings(sv)
    local submenuTable = {}
    local actionTypes = { "singleClick", "doubleClick", "enterKey" }
    local destinationActionDefaults = { Nav.ACTION_TRAVEL, Nav.ACTION_TRAVEL, Nav.ACTION_TRAVEL }
    table.insert(submenuTable, {
        type = "nav_actions",
        name = GetString(NAVIGATOR_SETTINGS_DESTINATION_ACTIONS_NAME),
        tooltip = GetString(NAVIGATOR_SETTINGS_DESTINATION_ACTIONS_TOOLTIP),
        actions = {GetString(NAVIGATOR_SETTINGS_ACTIONS_SINGLE_CLICK), GetString(NAVIGATOR_SETTINGS_ACTIONS_DOUBLE_CLICK), GetString(NAVIGATOR_SETTINGS_ACTIONS_ENTER_KEY)},
        choices = function(_)
            return {GetString(NAVIGATOR_SETTINGS_ACTIONS_CHOICE_SHOW_ON_MAP), GetString(NAVIGATOR_SETTINGS_ACTIONS_CHOICE_SET_DESTINATION), GetString(NAVIGATOR_SETTINGS_ACTIONS_CHOICE_TRAVEL)}
        end,
        choicesValues = function(_)
            return { Nav.ACTION_SHOWONMAP, Nav.ACTION_SETDESTINATION, Nav.ACTION_TRAVEL }
        end,
        choicesTooltips = function(index)
            return index == 1 and { nil, nil, GetString(NAVIGATOR_SETTINGS_DESTINATION_ACTIONS_WARNING) } or {"","",""}
        end,
        getFunc = function(index) return sv.destinationActions[actionTypes[index]] end,
        setFunc = function(index, value) sv.destinationActions[actionTypes[index]] = value end,
        default = function(index) return destinationActionDefaults[index] end,
        reference = Nav.settingsName .. "_destinationActions"
    })

    local zoneActionDefaults = { Nav.ACTION_SHOWONMAP, Nav.ACTION_TRAVEL, Nav.ACTION_SHOWONMAP }
    table.insert(submenuTable, {
        type = "nav_actions",
        name = GetString(NAVIGATOR_SETTINGS_ZONE_ACTIONS_NAME),
        actions = {GetString(NAVIGATOR_SETTINGS_ACTIONS_SINGLE_CLICK), GetString(NAVIGATOR_SETTINGS_ACTIONS_DOUBLE_CLICK), GetString(NAVIGATOR_SETTINGS_ACTIONS_ENTER_KEY)},
        choices = function(_)
            return {GetString(NAVIGATOR_SETTINGS_ACTIONS_CHOICE_SHOW_ON_MAP), GetString(NAVIGATOR_SETTINGS_ACTIONS_CHOICE_TRAVEL)}
        end,
        choicesValues = function(_)
            return { Nav.ACTION_SHOWONMAP, Nav.ACTION_TRAVEL }
        end,
        getFunc = function(index) return sv.zoneActions[actionTypes[index]] end,
        setFunc = function(index, value) sv.zoneActions[actionTypes[index]] = value end,
        default = function(index) return zoneActionDefaults[index] end,
        reference = Nav.settingsName .. "_zoneActions"
    })

    local poiActionDefaults = { Nav.ACTION_SHOWONMAP, Nav.ACTION_SETDESTINATION, Nav.ACTION_SHOWONMAP }
    table.insert(submenuTable, {
        type = "nav_actions",
        name = GetString(NAVIGATOR_SETTINGS_POI_ACTIONS_NAME),
        tooltip = GetString(NAVIGATOR_SETTINGS_POI_ACTIONS_TOOLTIP),
        actions = {GetString(NAVIGATOR_SETTINGS_ACTIONS_SINGLE_CLICK), GetString(NAVIGATOR_SETTINGS_ACTIONS_DOUBLE_CLICK), GetString(NAVIGATOR_SETTINGS_ACTIONS_ENTER_KEY)},
        choices = function(_)
            return {GetString(NAVIGATOR_SETTINGS_ACTIONS_CHOICE_SHOW_ON_MAP), GetString(NAVIGATOR_SETTINGS_ACTIONS_CHOICE_SET_DESTINATION)}
        end,
        choicesValues = function(_)
            return { Nav.ACTION_SHOWONMAP, Nav.ACTION_SETDESTINATION }
        end,
        getFunc = function(index) return sv.poiActions[actionTypes[index]] end,
        setFunc = function(index, value) sv.poiActions[actionTypes[index]] = value end,
        default = function(index) return poiActionDefaults[index] end,
        reference = Nav.settingsName .. "_poiActions"
    })

    return submenuTable
end

function Navigator:loadSettings()
    local LAM = LibAddonMenu2
    local sv = self.saved
    if sv == nil then return end
  
    local panelData = {
      type = "panel",
      name = self.menuName,
      displayName = self.displayName,
      author = self.author, -- DynamicFPS.Colorize(DynamicFPS.author, "AAF0BB"),
      version = self.appVersion,
      website = "https://www.esoui.com/downloads/info4026-Navigator-MapSearchFastTravel.html",
      feedback = "https://www.esoui.com/portal.php?id=401&a=bugreport",
      registerForRefresh = true,
      registerForDefaults = true,
    }
    self.settingsPanel = LAM:RegisterAddonPanel(self.settingsName, panelData)
  
    local optionsTable = {}
  
    table.insert(optionsTable, {
        type = "checkbox",
        name = GetString(NAVIGATOR_SETTINGS_DEFAULT_TAB_NAME),
        tooltip = GetString(NAVIGATOR_SETTINGS_DEFAULT_TAB_TOOLTIP),
        getFunc = function() return sv.defaultTab end,
        setFunc = function(value)
          sv.defaultTab = value
          end,
        width = "full", --or "half",
        requiresReload = true,
        disabled = function() return FasterTravel ~= nil end,
        warning = function()
          if FasterTravel then
            return GetString(NAVIGATOR_SETTINGS_DEFAULT_TAB_WARNING)
          else
            return nil
          end
        end
    })

    table.insert(optionsTable, {
      type = "slider",
      name = GetString(NAVIGATOR_SETTINGS_RECENT_COUNT_NAME),
      tooltip = GetString(NAVIGATOR_SETTINGS_RECENT_COUNT_TOOLTIP),
      min = 0,
      max = 20,
      getFunc = function() return sv.recentsCount end,
      setFunc = function(value) sv.recentsCount = value end,
      width = "full",
      default = self.default.recentsCount
    })

    -- Get the text for a gold currency icon
    local currencyInfo = ZO_CURRENCIES_DATA[CURT_MONEY]
    local iconSize = currencyInfo.keyboardPercentOfLineSize
    local iconMarkup = currencyInfo.keyboardTexture
    local gold = zo_iconFormat(iconMarkup, iconSize, iconSize)
    table.insert(optionsTable, {
        type = "dropdown",
        name = GetString(NAVIGATOR_SETTINGS_CONFIRM_FAST_TRAVEL_NAME),
        tooltip = GetString(NAVIGATOR_SETTINGS_CONFIRM_FAST_TRAVEL_TOOLTIP),
        choices = {GetString(NAVIGATOR_SETTINGS_CONFIRM_FAST_TRAVEL_CHOICE_1), zo_strformat(GetString(NAVIGATOR_SETTINGS_CONFIRM_FAST_TRAVEL_CHOICE_2), gold), GetString(NAVIGATOR_SETTINGS_CONFIRM_FAST_TRAVEL_CHOICE_3)},
        choicesValues = { self.CONFIRMFASTTRAVEL_ALWAYS, self.CONFIRMFASTTRAVEL_WHENCOST, self.CONFIRMFASTTRAVEL_NEVER },
        getFunc = function() return sv.confirmFastTravel end,
        setFunc = function(value) sv.confirmFastTravel = value end,
        width = "full",
        default = self.default.confirmFastTravel,
    })



    table.insert(optionsTable, {
        type = "checkbox",
        name = GetString(NAVIGATOR_SETTINGS_LIST_POI_NAME),
        tooltip = GetString(NAVIGATOR_SETTINGS_LIST_POI_TOOLTIP),
        getFunc = function() return sv.listPOIs end,
        setFunc = function(value) sv.listPOIs = value end,
        default = self.default.listPOIs,
    })

    table.insert(optionsTable, {
        type = "checkbox",
        name = GetString(NAVIGATOR_SETTINGS_INCLUDE_UNDISCOVERED_NAME),
        tooltip = GetString(NAVIGATOR_SETTINGS_INCLUDE_UNDISCOVERED_TOOLTIP),
        getFunc = function() return sv.includeUndiscovered end,
        setFunc = function(value)
            sv.includeUndiscovered = value
        end,
        width = "full"
    })

    table.insert(optionsTable, {
        type = "checkbox",
        name = GetString(NAVIGATOR_SETTINGS_USE_HOUSE_NICKNAME_NAME),
        --tooltip = "",
        getFunc = function() return sv.useHouseNicknames end,
        setFunc = function(value)
            sv.useHouseNicknames = value
            self.Locations:SetupNodes()
        end,
        width = "full"
    })

    table.insert(optionsTable, {
        type = "checkbox",
        name = GetString(NAVIGATOR_SETTINGS_AUTO_FOCUS_NAME),
        tooltip = GetString(NAVIGATOR_SETTINGS_AUTO_FOCUS_TOOLTIP),
        getFunc = function() return sv.autoFocus end,
        setFunc = function(value)
            sv.autoFocus = value
        end,
        width = "full",
        warning = GetString(NAVIGATOR_SETTINGS_AUTO_FOCUS_WARNING)
    })

    if LibSlashCommander then
      table.insert(optionsTable, {
        type = "dropdown",
        name = GetString(NAVIGATOR_SETTINGS_CHAT_COMMAND_NAME),
        tooltip = GetString(NAVIGATOR_SETTINGS_CHAT_COMMAND_TOOLTIP),
        choices = {GetString(NAVIGATOR_SETTINGS_CHAT_COMMAND_CHOICE_1), "/nav", "/tp"},
        getFunc = function() return sv.tpCommand end,
        setFunc = function(value) sv.tpCommand = value end,
        width = "full",
        default = self.default.tpCommand,
        requiresReload = true,
        warning = function()
          if PITHKA and PITHKA.SV and PITHKA.SV.options.enableTeleport then
            return GetString(NAVIGATOR_SETTINGS_CHAT_COMMAND_WARNING)
          else
            return nil
          end
        end
      })
    else
      table.insert(optionsTable, 	{
        type = "description",
        text = GetString(NAVIGATOR_SETTINGS_CHAT_COMMAND_UNAVAILABLE)
      })
    end

    table.insert(optionsTable, {
        type = "submenu",
        name = GetString(NAVIGATOR_SETTINGS_ACTIONS_NAME),
        tooltip = GetString(NAVIGATOR_SETTINGS_ACTIONS_TOOLTIP),
        controls = getActionSettings(sv),
        reference = Nav.settingsName .. "_actions"
    })

    if GetWorldName() == "EU Megaserver" then
        table.insert(optionsTable, {
            type = "divider"
        })
        table.insert(optionsTable, 	{
            type = "description",
            title = GetString(NAVIGATOR_SETTINGS_JOIN_GUILD_NAME),
            text = GetString(NAVIGATOR_SETTINGS_JOIN_GUILD_DESCRIPTION),
            enableLinks = true,
            reference = Navigator.settingsName .. "_ad"
        })
    end
    -- table.insert(optionsTable, 	{
    --   type = "description",
    --   -- title = "My Description",
    --   text = function()
    --     if PITHKA and PITHKA.SV and PITHKA.SV.options.enableTeleport then
    --       return "|cFFFF00|t24:24:/esoui/art/miscellaneous/eso_icon_warning.dds:inheritcolor|t|r |c8080FFPithka's Achievement Tracker|r has its teleport command enabled, which also uses '/tp'"
    --     else
    --       return ""
    --     end
    --   end,
    -- })

    LAM:RegisterOptionControls(self.settingsName, optionsTable)
  end
  