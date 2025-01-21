function MapSearch:loadSettings()
    local LAM = LibAddonMenu2
    local logger = MapSearch.logger
    local sv = self.saved
    if sv == nil then return end
  
    local panelData = {
      type = "panel",
      name = self.menuName,
      displayName = self.menuName,
      author = self.author, -- DynamicFPS.Colorize(DynamicFPS.author, "AAF0BB"),
      version = self.appVersion,
      registerForRefresh = true,
      registerForDefaults = true,
    }
    self.settingsPanel = LAM:RegisterAddonPanel(self.settingsName, panelData)
  
    local optionsTable = {}
  
    table.insert(optionsTable, {
        type = "checkbox",
        name = "Auto-select Search tab",
        tooltip = "Automatically selects the Search tab when the Maps screen is opened.",
        getFunc = function() return sv.defaultTab end,
        setFunc = function(value)
          sv.defaultTab = value
          end,
        width = "full", --or "half",
        requiresReload = true,
    })

    table.insert(optionsTable, {
      type = "checkbox",
      name = "Auto-focus Search box",
      tooltip = "Automatically puts the cursor in the search box when the tab is selected. This means that the 'M' key can't be used to exit the map; use 'Escape' instead.",
      getFunc = function() return sv.autoFocus end,
      setFunc = function(value)
        sv.autoFocus = value
        end,
      width = "full",
    })

    table.insert(optionsTable, {
      type = "dropdown",
      name = "Teleport chat command:",
      tooltip = "Select what name to give the chat slash command",
      choices = {"None", "/nav", "/tp"},
      getFunc = function() return sv.tpCommand end,
      setFunc = function(value) sv.tpCommand = value end,
      width = "full",
      default = MapSearch.default.tpCommand,
      requiresReload = true,
    })

    table.insert(optionsTable, 	{
      type = "description",
      -- title = "My Description",
      text = function()
        if PITHKA and PITHKA.SV and PITHKA.SV.options.enableTeleport then
          return "|cFFFF00|t24:24:/esoui/art/miscellaneous/eso_icon_warning.dds:inheritcolor|t|r |c8080FFPithka's Achievement Tracker|r has its teleport command enabled, which also uses '/tp'"
        else
          return ""
        end
      end,
    })

    LAM:RegisterOptionControls(self.settingsName, optionsTable)
  end
  