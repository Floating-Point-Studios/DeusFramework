local Deus = shared.DeusFramework

local Debug = Deus:Load("Deus/Debug")

local Metatables = setmetatable({}, {__mode = "kv"})

local TableProxy = {}

local function __index(self, i)
    local isInternalAccess = TableProxy.isInternalAccess(self)

    if not isInternalAccess then
        self = Metatables[self]
    end

    local v = self.__internals[i]
    if v then
        if isInternalAccess then
            return v
        else
            Debug.error(2, "[TableProxy] Index '%s' cannot be accessed from externally", i)
        end
    end

    v = self.__externalReadOnly[i]
    if v then
        return v
    end

    v = self.__externalReadAndWrite[i]
    if v then
        return v
    end

    v = self.__fallbackIndex(self, i, isInternalAccess)
    if v then
        return v
    end

    Debug.error(2, "[TableProxy] Index '%s' was not found", i)
end

local function __newindex(self, i, v)
    local isInternalAccess = TableProxy.isInternalAccess(self)

    if not isInternalAccess then
        self = Metatables[self]
    end

    local Internals = self.__internals
    local ExternalReadOnly = self.__externalReadOnly
    local ExternalReadAndWrite = self.__externalReadAndWrite

    if Internals[i] then
        if isInternalAccess then
            Internals[i] = v
            return true
        else
            Debug.error(2, "[TableProxy] Index '%s' cannot be written to from externally", i)
        end
    end

    if ExternalReadOnly[i] then
        ExternalReadOnly[i] = v
        return true
    end

    if ExternalReadAndWrite[i] then
        ExternalReadAndWrite[i] = v
        return true
    end

    if self.__fallbackNewIndex(self, i, v, isInternalAccess) then
        return true
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

    metatable.__internals = tableData.Internals or {}
    metatable.__externalReadOnly = tableData.ExternalReadOnly or {}
    metatable.__externalReadAndWrite = tableData.ExternalReadAndWrite or {}

    metatable.__fallbackIndex = tableData.__index
    metatable.__fallbackNewIndex = tableData.__newindex

    Metatables[self] = metatable

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