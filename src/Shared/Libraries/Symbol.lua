-- Based on https://github.com/Roblox/roact/blob/master/src/Symbol.lua

-- TODO: Allow symbols from Deus to work with symbols from other popular projects

local Symbols = {}

function __tostring(self)
    return "[Symbol] ".. Symbols[self].__type
end

local Symbol = {}

function Symbol.new(name)
    local symbol = Symbols[name]
    if symbol then
        return symbol
    end

    local self = newproxy(true)
    local metatable = getmetatable(self)

    metatable.__tostring = __tostring
    metatable.__metatable = "[Symbol] Locked metatable"
    metatable.__type = name

    Symbols[name] = self
    Symbols[self] = metatable

    return self
end

return Symbol