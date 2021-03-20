local Output

local Metatables = setmetatable({}, {__mode = "v"})

local function __index(self, i)
    self = Metatables[self]

    local v = self[i]
    if v then
        return v
    end

    -- Check if proxy has a custom __index set
    local customIndex = self.Index
    if customIndex then
        if type(customIndex) == "function" then
            return self.Index(self, i)
        else
            return customIndex[i]
        end
    end
end

local function __newindex(self, i, v)
    self = Metatables[self]

    if self[i] then
        self[i] = v
        return true
    end

    -- Check if proxy has a custom __newindex set
    if self.NewIndex then
        return self.NewIndex(self, i, v)
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

    meta.__metatable    = metamethods.__metatable or "[Proxy] Locked Metatable"
    meta.__index        = __index
    meta.__newindex     = __newindex
    meta.__tostring     = metamethods.__tostring or __tostring

    meta.__call         = metamethods.__call
    meta.__concat       = metamethods.__concat
    meta.__unm          = metamethods.__unm
    meta.__add          = metamethods.__add
    meta.__sub          = metamethods.__sub
    meta.__mul          = metamethods.__mul
    meta.__div          = metamethods.__div
    meta.__mod          = metamethods.__mod
    meta.__pow          = metamethods.__pow
    meta.__eq           = metamethods.__eq
    meta.__lt           = metamethods.__lt
    meta.__le           = metamethods.__le
    meta.__len          = metamethods.__len

    meta.Index          = metamethods.__index
    meta.NewIndex       = metamethods.__newindex

    meta.Proxy          = proxy

    for i,v in pairs(values) do
        Output.assert(meta[i] == nil, "Index '%s' is reserved in Proxy", i, 1)
        meta[i] = v
    end

    setmetatable(meta, metamethods)

    Metatables[proxy] = meta

    return meta
end

function Proxy:start()
    Output = self:Load("Deus.Output")
end

return Proxy