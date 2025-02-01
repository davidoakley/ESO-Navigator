local Nav = Navigator
local Search = Nav.Search or {}
local Utils = Nav.Utils
local Locations = Nav.Locations
local colors = Nav.ansicolors
local fzy = Nav.fzy

Nav.FILTER_NONE = 0
Nav.FILTER_PLAYERS = 1
Nav.FILTER_HOUSES = 4

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
	return (x.barename or x.name) < (y.barename or y.name)
end

function Search:AddCandidates(list)
    for i = 1, #list do
        local node = list[i]
        local searchName = Utils.SearchName(node.originalName or node.name)
        self.candidates[searchName] = node
    end
end

function Search:Execute(searchTerm)
    searchTerm = Utils.removeAccents(searchTerm)
    local result = {}

    for searchName, node in pairs(self.candidates) do
        local matchLevel = searchTerm ~= "" and match(searchName, searchTerm) or 1.0
        if matchLevel > 0 then
            local resultNode = Utils.shallowCopy(node)
            if node.weight then
                matchLevel = matchLevel * node.weight
            end
            resultNode.match = matchLevel
            -- resultNode.matchChars = matchChars

            table.insert(result, resultNode)
        end
    end

    return result
end

function Search:Run(searchTerm, filter)
    self.candidates = {}

    searchTerm = searchTerm and string.lower(searchTerm) or ""
    searchTerm = searchTerm:gsub("[^%w ]", "")

    -- Nav.log("Search:Run('%s', %d)", searchTerm, filter)

    if filter == Nav.FILTER_NONE and searchTerm == "" then
        return {}
    end

    if filter == Nav.FILTER_PLAYERS then
        self:AddCandidates(Nav.Players:GetPlayerList())
    elseif filter == Nav.FILTER_HOUSES then
        self:AddCandidates(Locations:getHouseList())
    else
        self:AddCandidates(Locations:getKnownNodes())
        self:AddCandidates(Locations:getZoneList())
    end

    local result = self:Execute(searchTerm)

    table.sort(result, matchComparison)

    self.result = result
    return result
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