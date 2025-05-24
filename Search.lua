local Nav = Navigator
local Search = Nav.Search or {}
local Utils = Nav.Utils
local Locations = Nav.Locations
local colors = Nav.ansicolors
local fzy = Nav.fzy

Search.candidates = {}

local function match(searchName, searchTerm)
    if fzy.has_match(searchTerm, searchName, nil) then
        local _, s = fzy.positions(searchTerm, searchName, nil)
        return s
    else
        return 0
    end
end

local function matchComparison(x,y)
    if x.match ~= y.match then
        return x.match > y.match
    end
	return x.searchName < y.searchName -- Nav.SearchName(x.node.name) < Nav.SearchName(y.node.name)
end

function Search:AddCandidates(list)
    for i = 1, #list do
        local node = list[i]
        local searchName = Nav.SearchName(node.originalName or node.name)
        searchName = searchName:gsub("^@", "") -- remove '@' prefix
        table.insert(self.candidates, { searchName = searchName, node = node })
    end
end

function Search:Execute(searchTerm)
    searchTerm = Utils.SimplifyAccents(searchTerm)
    local result = {}

    --Nav.log("Search:Execute: %d candidates", #self.candidates or -1)
    for i = 1, #self.candidates do
        local candidate = self.candidates[i]
        local matchLevel = searchTerm ~= "" and match(candidate.searchName, searchTerm) or 1.0
        if matchLevel > 0 then
            matchLevel = matchLevel * candidate.node:GetWeight()
            candidate.match = matchLevel
            --candidate.matchChars = matchChars
            candidate.searchName = candidate.searchName
            candidate.searchTerm = searchTerm

            table.insert(result, candidate)
        end
    end

    return result
end

function Search:Run(searchTerm, view)
    self.candidates = {}

    searchTerm = Nav.Utils.trim(searchTerm or "")
    local hasSearch = searchTerm ~= ""

    --Nav.Utils.logChars("Épreuve")
    --Nav.Utils.logChars(searchTerm)
    -- Nav.log("Search:Run('%s', %d)", searchTerm, view)

    if view == Nav.VIEW_NONE and searchTerm == "" then
        return {}
    end

    if view == Nav.VIEW_PLAYERS then
        self:AddCandidates(Nav.Players:GetPlayerList(hasSearch))
    elseif view == Nav.VIEW_HOUSES then
        self:AddCandidates(Locations:GetHouseList(hasSearch))
    elseif view == Nav.VIEW_ZONES then
        local list = Nav.Locations:GetZoneList()
        table.sort(list, Nav.Node.NameComparison)
        self:AddCandidates(list)
    elseif view == Nav.VIEW_TREASURE then
        self:AddCandidates(Locations:GetMapZones())
    elseif view == Nav.VIEW_TRADERS then
        self:AddCandidates(Locations:GetTraderNodeList())
    else
        self:AddCandidates(Locations:GetNodeList(nil, hasSearch))
        self:AddCandidates(Locations:GetZoneList(true))
    end

    local result = self:Execute(searchTerm)

    table.sort(result, matchComparison)

    self.result = result -- Just for debugging

    local resultNodes = {}
    for i = 1, #result do
        table.insert(resultNodes, result[i].node)
    end

    return resultNodes
end

function Search:FilterContent(content, searchTerm)
    for c = 1, #content.categories do
        local category = content.categories[c]

        self.candidates = {}
        self:AddCandidates(category.list)

        local result = self:Execute(searchTerm)
        table.sort(result, matchComparison)

        local newList = {}
        for i = 1, #result do
            table.insert(newList, result[i].node)
        end
        category.list = newList
    end
end
  
function Search.highlightResult(result, matchChars)
    local out = ""
    for i = 1, #result do
        local c = result:sub(i, i)
        if Utils.tableContains(matchChars, i) then
            if Nav.isCLI then
                out = out..'%{underline}'..c..'%{reset}'
            else
                out = out..c
            end
        else
            out = out..c
        end
    end
    return colors(out)
end

Nav.Search = Search