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
      registerForRefresh = true,
      registerForDefaults = true,
    }
    self.settingsPanel = LAM:RegisterAddonPanel(self.settingsName, panelData)
  
    local optionsTable = {}
  
    table.insert(optionsTable, {
        type = "checkbox",
        name = "Auto-select Navigator tab",
        tooltip = "Automatically selects the Navigator tab when the Maps screen is opened.",
        getFunc = function() return sv.defaultTab end,
        setFunc = function(value)
          sv.defaultTab = value
          end,
        width = "full", --or "half",
        requiresReload = true,
        disabled = function() return FasterTravel ~= nil end,
        warning = function()
          if FasterTravel then
            return "Navigator cannot auto-select its tab when the |c99FFFFFaster Travel|r addon is also enabled"
          else
            return nil
          end
        end
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
      warning = "When active, the 'M' key can't be used to immediately exit the map; use 'Escape' instead."
    })

    table.insert(optionsTable, {
      type = "slider",
      name = "Entries in Recent list",
      min = 0,
      max = 20,
      getFunc = function() return sv.recentsCount end,
      setFunc = function(value) sv.recentsCount = value end,
      width = "full",
      default = 10
    })  

    if LibSlashCommander then
      table.insert(optionsTable, {
        type = "dropdown",
        name = "Chat command:",
        tooltip = "Select what name to give the chat slash command",
        choices = {"None", "/nav", "/tp"},
        getFunc = function() return sv.tpCommand end,
        setFunc = function(value) sv.tpCommand = value end,
        width = "full",
        default = self.default.tpCommand,
        requiresReload = true,
        warning = function()
          if PITHKA and PITHKA.SV and PITHKA.SV.options.enableTeleport then
            return "|c8080FFPithka's Achievement Tracker|r has its teleport command enabled, which also uses '/tp'"
          else
            return nil
          end
        end
      })
    else
      table.insert(optionsTable, 	{
        type = "description",
        text = "|cFFFF00|t24:24:/esoui/art/miscellaneous/eso_icon_warning.dds:inheritcolor|t|r Navigator's chat command is only available if the |c99FFFFLibSlashCommander|r add-on is installed and enabled"
      })
    end

    table.insert(optionsTable, {
        type = "checkbox",
        name = "Show and search house nicknames",
        --tooltip = "",
        getFunc = function() return sv.useHouseNicknames end,
        setFunc = function(value)
            sv.useHouseNicknames = value
            self.Locations:setupNodes()
        end,
        width = "full"
    })

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
  