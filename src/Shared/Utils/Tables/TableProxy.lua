local Deus = shared.DeusFramework

local Debug = Deus:Load("Deus/Debug")

local Metatables = setmetatable({}, {__mode = "kv"})

local TableProxy = {}

local function __index(self, i)
    local isInternalAccess, metatable = TableProxy.isInternalAccess(self)

    local internals = metatable.__internals
    local externals = metatable.__externals

    local v = externals[i]
    if v then
        return v
    end

    v = internals[i]
    if v then
        Debug.assert(isInternalAccess, "[TableProxy] Cannot read Internal '%s' from externally", i)
        return v
    end

    Debug.error(2, "[TableProxy] Index '%s' was not found", i)
end

local function __newindex(self, i, v)
    local isInternalAccess, metatable = TableProxy.isInternalAccess(self)

    local internals = metatable.__internals
    local externals = metatable.__externals

    if externals[i] then
        externals[i] = v
        return true
    elseif internals[i] then
        Debug.assert(isInternalAccess, "[TableProxy] Cannot write to Internal '%s' from externally", i)
        internals[i] = v
        return true
    end

    Debug.error(2, "[TableProxy] Index '%s' was not found", i)
end

function TableProxy.new(internals, externals)
    local self = newproxy(true)
    local metatable = getmetatable(self)

    metatable.__index = __index
    metatable.__newindex = __newindex
    metatable.__metatable = "[TableProxy] Locked metatable"

    metatable.__internals = internals
    metatable.__externals = externals

    Metatables[self] = metatable

    return self, metatable
end

function TableProxy.isInternalAccess(self)
    local metatable = Metatables[self]
    if metatable then
        -- If metatable was found then 'self' provided was from external access
        return false, metatable
    else
        -- If metatable was not found 'self' provided was likely internal access
        return true, self
    end
end

return TableProxy