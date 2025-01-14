function MapSearch:loadSettings()
    local LAM = LibAddonMenu2
    local sv = self.saved
    if sv == nil then return end
  
    local panelData = {
      type = "panel",
      name = self.menuName,
      displayName = self.menuName,
      author = self.author, -- DynamicFPS.Colorize(DynamicFPS.author, "AAF0BB"),
      version = self.version,
      registerForRefresh = true,
      registerForDefaults = true,
    }
    self.settingsPanel = LAM:RegisterAddonPanel(self.menuName, panelData)
  
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
      type = "dropdown",
      name = "Teleport chat command:",
      tooltip = "Select what name to give the chat slash command",
      choices = {"None", "/tp", "/mstp"},
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

    LAM:RegisterOptionControls(self.menuName, optionsTable)
  end
  