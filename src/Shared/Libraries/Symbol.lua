-- Based on https://github.com/Roblox/roact/blob/master/src/Symbol.lua

-- TODO: Allow symbols from Deus to work with symbols from other projects

local function makeSymbol(name)
    local symbol = newproxy(true)
    local metatable = getmetatable(symbol)

    metatable.__metatable = "[Symbol] Locked metatable"
    metatable.__type = name

    return symbol, metatable
end

local Symbols = {}

function __tostring(self)
    return "[Symbol] ".. Symbols[self].__type
end

local Symbol = {}

-- Creates a nonglobal symbol
function Symbol.new(name)
    local symbol, metatable = makeSymbol(name)

    metatable.__tostring = function()
        return name
    end

    return symbol
end

-- Creates or gets a global symbol
function Symbol.get(name)
    if Symbols[name] then
        return Symbols[name]
    else
        local symbol, metatable = makeSymbol(name)

        metatable.__tostring = __tostring

        Symbols[name] = symbol
        Symbols[symbol] = metatable

        return symbol
    end
end

return Symbol