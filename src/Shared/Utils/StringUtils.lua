local HttpService = game:GetService("HttpService")

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
        output[str:sub(matchStart, matchEnd)] = {Start = matchStart, End = matchEnd}
        init += 1
    until not str:match(pattern, init)
    return output
end

-- Replaces part of a string given where it should start and end
function StringUtils.replaceAt(str, newStr, repStart, repEnd)
    return str:sub(1, repStart - 1).. newStr.. str:sub(repEnd + 1)
end

-- Returns whether the string is JSON formatted
function StringUtils.isJSON(str)
    return pcall(HttpService.JSONDecode, HttpService, str)
end

-- Replaces pattern repetitions such as "/////" to "/"
function StringUtils.collapseOccurances(str, pattern)
    local rep = pattern
    pattern = pattern.rep(2)
    repeat
        str = str:gsub(pattern, rep)
    until not str:match(rep)
    return str
end

return StringUtils