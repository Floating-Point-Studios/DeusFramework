local TableUtils

local StringUtils = {}

-- Returns number of matches found
function StringUtils.countMatches(str, pattern)
    local _,occurances = str:gsub(pattern, pattern)
    return occurances
end

-- Returns matches found as a table with start and end indexes
function StringUtils.getMatches(str, pattern)
    local output = {}
    local init = 1
    repeat
        local matchStart, matchEnd = str:find(pattern, init)
        table.insert(output, {Match = str:sub(matchStart, matchEnd), Start = matchStart, End = matchEnd})
        init = matchEnd + 1
    until not str:match(pattern, init)
    return output
end

-- Replaces part of a string given where it should start and end
function StringUtils.replaceAt(str, newStr, repStart, repEnd)
    return str:sub(1, repStart - 1).. newStr.. str:sub(repEnd + 1)
end

-- Replaces pattern repetitions such as "/////" to "/"
function StringUtils.collapseOccurances(str, pattern)
    local rep = pattern
    pattern = pattern:rep(2)
    repeat
        str = str:gsub(pattern, rep)
	until not str:match(pattern)
    return str
end

function StringUtils.hash(str)
    local bytes = TableUtils.sum({string.byte(str, 1, #str)})
    return tostring(Random.new(bytes):NextInteger(10000000, 99999999))
end

function StringUtils.reverseSub(str, subStart, subEnd)
    local strLength = #str
    subStart = subStart or 1
    subEnd = subEnd or strLength

    return str:sub(strLength - subEnd + 1, strLength - subStart + 1)
end

function StringUtils.sub(str, subStart, subEnd)
    local strLength = #str
    subStart = subStart or 1
    subEnd = subEnd or strLength

    if subStart < 0 then
        subStart %= strLength
    end
    if subEnd < 0 then
        subEnd %= strLength
    end

    return str:sub(subStart, subEnd)
end

StringUtils.replace = StringUtils.replaceAt

function StringUtils:start()
    TableUtils = self:Load("Deus.TableUtils")
end

return StringUtils