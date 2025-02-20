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
      type = "slider",
      name = "Entries in Recent list",
      tooltip = "Setting this to 0 will disable the Recent list",
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
        name = "Confirm fast travel",
        tooltip = "Whether/when to show the standard alert prompt when jumping to a wayshrine. Only affects Navigator, not the World Map",
        choices = {"Always", zo_strformat("When costs <<1>>", gold), "Never"},
        choicesValues = { self.CONFIRMFASTTRAVEL_ALWAYS, self.CONFIRMFASTTRAVEL_WHENCOST, self.CONFIRMFASTTRAVEL_NEVER },
        getFunc = function() return sv.confirmFastTravel end,
        setFunc = function(value) sv.confirmFastTravel = value end,
        width = "full",
        default = self.default.confirmFastTravel,
    })

    table.insert(optionsTable, {
        type = "checkbox",
        name = "Show Points Of Interest on the zone list",
        tooltip = "If this is disabled, only \"destinations\" such as wayshrines, dungeons, houses or players will be listed",
        getFunc = function() return sv.listPOIs end,
        setFunc = function(value) sv.listPOIs = value end,
        default = self.default.listPOIs,
    })

    table.insert(optionsTable, {
        type = "checkbox",
        name = "Show and search undiscovered locations",
        tooltip = "List undiscovered locations and show them in search results",
        getFunc = function() return sv.includeUndiscovered end,
        setFunc = function(value)
            sv.includeUndiscovered = value
        end,
        width = "full"
    })

    table.insert(optionsTable, {
        type = "checkbox",
        name = "Show and search house nicknames",
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
        name = "Auto-focus Search box",
        tooltip = "Automatically puts the cursor in the search box when the tab is selected. This means that the 'M' key can't be used to exit the map; use 'Escape' instead.",
        getFunc = function() return sv.autoFocus end,
        setFunc = function(value)
            sv.autoFocus = value
        end,
        width = "full",
        warning = "When active, the 'M' key can't be used to immediately exit the map; use 'Escape' instead."
    })

    if LibSlashCommander then
      table.insert(optionsTable, {
        type = "dropdown",
        name = "Chat command",
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

    if GetWorldName() == "EU Megaserver" then
        table.insert(optionsTable, {
            type = "divider"
        })
        table.insert(optionsTable, 	{
            type = "description",
            title = "Join our guild!",
            text = "|cC5C29E|H1:guild:767808|hMora's Whispers|h is a vibrant social lair with a free trader, loads of events, weekly raffles, fully equipped guild base, active Discord and so forth! Hit the link above to find out more!|r",
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
  