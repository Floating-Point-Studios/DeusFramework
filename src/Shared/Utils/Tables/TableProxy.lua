-- Based on RoStrap

local Deus = shared.DeusFramework

local Debug = Deus:Load("Deus/Debug")

local Metatables = setmetatable({}, {__mode = "kv"})

local TableProxy = {}

local function __index(self, i)
    local isInternalAccess = TableProxy.isInternalAccess(self)

    if not isInternalAccess then
        self = Metatables[self]
    end

    local fallbackIndex = rawget(self, "__fallbackIndex")

    local v = rawget(self, "__internals")[i]
    if v ~= nil then
        Debug.assert(isInternalAccess, "[TableProxy] Internal '%s' cannot be read from externally", i)
        return v
    end

    v = rawget(self, "__externalReadOnly")[i]
    if v ~= nil then
        return v
    end

    v = rawget(self, "__externalReadAndWrite")[i]
    if v ~= nil then
        return v
    end

    if type(fallbackIndex) == "function" then
        v = fallbackIndex(self, i, isInternalAccess)
        if v ~= nil then
            return v
        end
    elseif type(fallbackIndex) == "table" then
        v = fallbackIndex[i]
        if v ~= nil then
            return v
        end
    end

    Debug.error(2, "[TableProxy] Index '%s' was not found", i)
end

local function __newindex(self, i, v)
    local isInternalAccess = TableProxy.isInternalAccess(self)

    if not isInternalAccess then
        self = Metatables[self]
    end

    local internals = rawget(self, "__internals")
    local externalReadOnly = rawget(self, "__externalReadOnly")
    local externalReadAndWrite = rawget(self, "__externalReadAndWrite")
    local fallbackNewIndex = rawget(self, "__fallbackNewIndex")

    if internals[i] then
        Debug.assert(isInternalAccess, "[TableProxy] Internal '%s' cannot be written to from externally", i)
        internals[i] = v
        return true
    end

    if externalReadOnly[i] then
        Debug.assert(isInternalAccess, "[TableProxy] ExternalReadOnly '%s' cannot be written to from externally", i)
        externalReadOnly[i] = v
        return true
    end

    if externalReadAndWrite[i] then
        externalReadAndWrite[i] = v
        return true
    end

    if type(fallbackNewIndex) == "function" then
        if fallbackNewIndex(self, i, isInternalAccess) then
            return true
        end
    elseif type(fallbackNewIndex) == "table" then
        if fallbackNewIndex[i] then
            fallbackNewIndex[i] = v
            return true
        end
    end

    Debug.error(2, "[TableProxy] Index '%s' was not found", i)
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

    metatable.__internals = tableData.Internals or {}
    metatable.__externalReadOnly = tableData.ExternalReadOnly or {}
    metatable.__externalReadAndWrite = tableData.ExternalReadAndWrite or {}

    metatable.__fallbackIndex = tableData.__index
    metatable.__fallbackNewIndex = tableData.__newindex

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