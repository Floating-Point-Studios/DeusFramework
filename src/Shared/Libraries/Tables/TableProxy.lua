-- Based on RoStrap

local Deus = shared.Deus

local Output = Deus:Load("Deus.Output")
local Symbol = Deus:Load("Deus.Symbol")

local Metatables = setmetatable({}, {__mode = "kv"})

local TableProxy = {}

local function __index(self, i)
    local isInternalAccess = TableProxy.isInternalAccess(self)

    if not isInternalAccess then
        self = Metatables[self]
    end

    local fallbackIndex = rawget(self, "FallbackIndex")

    local v = rawget(self, "Internals")[i]
    if v ~= nil then
        Output.assert(isInternalAccess, "[TableProxy] Internal '%s' cannot be read from externally", i)
        return v
    end

    v = rawget(self, "ExternalReadOnly")[i]
    if v ~= nil then
        return v
    end

    v = rawget(self, "ExternalReadAndWrite")[i]
    if v ~= nil then
        return v
    end

    v = rawget(self, i)
    if v ~= nil then
        Output.assert(isInternalAccess, "[TableProxy] Index '%s' cannot be read from externally", i)
        return v
    end

    local fallbackIndexType = type(fallbackIndex)
    if fallbackIndexType == "function" then
        v = fallbackIndex(self, i, isInternalAccess)
        if v ~= nil then
            return v
        end
    elseif fallbackIndexType == "table" then
        v = fallbackIndex[i]
        if v ~= nil then
            return v
        end
    end

    Output.error(2, "[TableProxy] Index '%s' was not found", i)
end

local function __newindex(self, i, v)
    -- Symbol for nil is used as if user attempts to write to this index again while it is nil it will error
    v = v or Symbol.new("nil")

    local isInternalAccess = TableProxy.isInternalAccess(self)

    if not isInternalAccess then
        self = Metatables[self]
    end

    local internals = rawget(self, "Internals")
    local externalReadOnly = rawget(self, "ExternalReadOnly")
    local externalReadAndWrite = rawget(self, "ExternalReadAndWrite")
    local fallbackNewIndex = rawget(self, "FallbackNewIndex")

    if internals[i] ~= nil then
        Output.assert(isInternalAccess, "[TableProxy] Internal '%s' cannot be written to from externally", i)
        internals[i] = v
        return true
    end

    if externalReadOnly[i] ~= nil then
        Output.assert(isInternalAccess, "[TableProxy] ExternalReadOnly '%s' cannot be written to from externally", i)
        externalReadOnly[i] = v
        return true
    end

    if externalReadAndWrite[i] ~= nil then
        externalReadAndWrite[i] = v
        return true
    end

    if rawget(self, i) ~= nil then
        Output.assert(isInternalAccess, "[TableProxy] Index '%s' cannot be written to externally", i)
        rawset(self, i, v)
        return true
    end

    local fallbackNewIndexType = type(fallbackNewIndex)
    if fallbackNewIndexType == "function" then
        if fallbackNewIndex(self, i, v, isInternalAccess) then
            return true
        end
    elseif fallbackNewIndexType == "table" then
        if fallbackNewIndex[i] then
            fallbackNewIndex[i] = v
            return true
        end
    end

    Output.error(2, "[TableProxy] Index '%s' was not found", i)
end

-- @param tableData.Internals: read/write from internal access
-- @param tableData.ExternalReadOnly: read from external and read/write from internal access
-- @param tableData.ExternalReadAndWrite: read/write from external and read/write from internal access
-- @param tableData.__index: fallback index function of default index function is unable to find index
-- @param tableData.__newindex: fallback newindex function of default newindex function is unable to find index
function TableProxy.new(tableData)
    local self = newproxy(true)
    local metatable = getmetatable(self)

    metatable.__index = __index
    metatable.__newindex = __newindex
    metatable.__metatable = "[TableProxy] Locked metatable"

    metatable.__proxy = self

    metatable.Internals = tableData.Internals or {}
    metatable.ExternalReadOnly = tableData.ExternalReadOnly or {}
    metatable.ExternalReadAndWrite = tableData.ExternalReadAndWrite or {}

    metatable.FallbackIndex = tableData.__index
    metatable.FallbackNewIndex = tableData.__newindex

    Metatables[self] = metatable

    setmetatable(metatable,
        {
            __index = __index;
            __newindex = __newindex;
        }
    )

    return self, metatable
end

function TableProxy.isInternalAccess(self)
    if Metatables[self] then
        -- If metatable was found then 'self' provided was from external access
        return false
    else
        -- If metatable was not found 'self' provided was likely internal access
        return true
    end
end

return TableProxy