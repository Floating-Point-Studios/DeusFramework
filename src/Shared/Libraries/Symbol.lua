-- Based on https://github.com/Roblox/roact/blob/master/src/Symbol.lua

-- TODO: Allow symbols from Deus to work with symbols from other projects

local Symbols = {}

function __tostring(self)
    return "[Symbol] ".. Symbols[self].__type
end

local Symbol = {}

function Symbol.new(name, nonGlobal)
    local symbol = Symbols[name]

    if nonGlobal or not symbol then
        symbol = newproxy(true)
        local metatable = getmetatable(symbol)

        metatable.__metatable = "[Symbol] Locked metatable"
        metatable.__type = name

        if nonGlobal then
            metatable.__tostring = function()
                return "[Symbol] ".. name
            end
        else
            Symbols[name] = symbol
            Symbols[symbol] = metatable
            metatable.__tostring = __tostring
        end
    end

    return symbol
end

return Symbol