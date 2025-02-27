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
	return Nav.SearchName(x.node.name) < Nav.SearchName(y.node.name)
end

function Search:AddCandidates(list)
    for i = 1, #list do
        local node = list[i]
        local searchName = Nav.SearchName(node.originalName or node.name)
        table.insert(self.candidates, { searchName = searchName, node = node })
    end
end

function Search:Execute(searchTerm)
    searchTerm = Utils.SimplifyAccents(searchTerm)
    local result = {}

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

function Search:Run(searchTerm, filter)
    self.candidates = {}

    searchTerm = searchTerm and string.lower(searchTerm) or "" -- FIXME: Should string.lower be removed?
    searchTerm = searchTerm:gsub("[^%w ]", "")
    local hasSearch = searchTerm ~= ""

    -- Nav.log("Search:Run('%s', %d)", searchTerm, filter)

    if filter == Nav.FILTER_NONE and searchTerm == "" then
        return {}
    end

    if filter == Nav.FILTER_PLAYERS then
        self:AddCandidates(Nav.Players:GetPlayerList())
    elseif filter == Nav.FILTER_HOUSES then
        self:AddCandidates(Locations:GetHouseList(hasSearch))
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