local Output

local Metatables = setmetatable({}, {__mode = "v"})
local SymbolIndex
local SymbolNewIndex

local function __index(self, i)
    local original = self
    self = Metatables[self] or self

    local v = rawget(self, i)
    if v then
        return v
    end

    -- Check if proxy has a custom __index set
    local customIndex = self[SymbolIndex]
    if customIndex then
        if type(customIndex) == "function" then
            return customIndex(original, i)
        else
            return customIndex[i]
        end
    end
end

local function __newindex(self, i, v)
    local original = self
    self = Metatables[self] or self

    if rawget(self, i) then
        rawset(self, i, v)
        return true
    end

    -- Check if proxy has a custom __newindex set
    local customNewIndex = self[SymbolNewIndex]
    if customNewIndex then
        return customNewIndex(original, i, v)
    end
end

local function __tostring()
    return "[Proxy] DeusProxy"
end

local Proxy = {}

function Proxy.new(values, metamethods)
    metamethods = metamethods or {}

    local proxy = newproxy(true)
    local meta = getmetatable(proxy)

    meta.__metatable        = metamethods.__metatable or "[Proxy] Locked Metatable"
    meta.__index            = __index
    meta.__newindex         = __newindex
    meta.__tostring         = metamethods.__tostring or __tostring

    meta.__call             = metamethods.__call
    meta.__concat           = metamethods.__concat
    meta.__unm              = metamethods.__unm
    meta.__add              = metamethods.__add
    meta.__sub              = metamethods.__sub
    meta.__mul              = metamethods.__mul
    meta.__div              = metamethods.__div
    meta.__mod              = metamethods.__mod
    meta.__pow              = metamethods.__pow
    --[[
    These metamethods don't work with userdatas

    meta.__eq               = metamethods.__eq
    meta.__lt               = metamethods.__lt
    meta.__le               = metamethods.__le
    ]]
    meta.__len              = metamethods.__len

    meta[SymbolIndex]       = metamethods.__index
    meta[SymbolNewIndex]    = metamethods.__newindex

    meta.Proxy              = proxy

    for i,v in pairs(values) do
        Output.assert(meta[i] == nil, "Index %s is reserved in Proxy", i, 1)
        meta[i] = v
    end

    setmetatable(meta, metamethods)

    Metatables[proxy] = meta

    return meta
end

function Proxy:start()
    Output = self:Load("Deus.Output")

    local Symbol = self:Load("Deus.Symbol")

    SymbolIndex = Symbol.new("Index", true)
    SymbolNewIndex = Symbol.new("NewIndex", true)
end

return Proxy