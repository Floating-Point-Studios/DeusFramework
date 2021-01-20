local Deus = shared.Deus

local Output = Deus:Load("Deus.Output")

local Metatables = setmetatable({}, {__mode = "v"})

local function __tostring()
    return "[TableProxy] Locked Metatable"
end

local TableProxy = {}

function TableProxy.__index(self, i)
    local v
    local internalAccess = TableProxy.IsInternalAccess(self)
    if not internalAccess then
        self = Metatables[self]
    end

    v = self.Internal[i]
    if v then
        if internalAccess then
            return v
        else
            Output.error("Attempt to read internal property")
        end
    end

    v = self.ExternalReadOnly[i]
    if v then
        return v
    end

    v = self.ExternalReadAndWrite[i]
    if v then
        return v
    end

    for _,fallbackIndex in pairs(self.FallbackIndexes) do
        v = fallbackIndex(self, i)
        if v then
            return v
        end
    end

    return nil
end

function TableProxy.__newindex(self, i, v)
    local internalAccess = TableProxy.IsInternalAccess(self)
    if not internalAccess then
        self = Metatables[self]
    end

    if self.Internal[i] then
        if internalAccess then
            self.Internal[i] = v
            return true
        else
            Output.error("Attempt to modify internal property")
        end
    end

    if self.ExternalReadOnly[i] then
        self.ExternalReadOnly[i] = v
        return true
    end

    if self.ExternalReadAndWrite[i] then
        self.ExternalReadAndWrite[i] = v
        return true
    end

    for _,fallbackNewIndex in pairs(self.FallbackNewIndexes) do
        if fallbackNewIndex(self, i, v) then
            return true
        end
    end

    return false
end

function TableProxy.new(tableData)
    local proxy = newproxy(true)
    local metatable = getmetatable(proxy)

    metatable.__metatable = "[TableProxy] Locked Metatable"
    metatable.__index = TableProxy.__index
    metatable.__newindex = TableProxy.__newindex
    metatable.__tostring = tableData.__tostring or __tostring

    metatable.Proxy = proxy
    metatable.FallbackIndexes = {tableData.__index}
    metatable.FallbackNewIndexes = {tableData.__newindex}

    metatable.Internal = tableData.Internal or {}
    metatable.ExternalReadOnly = tableData.ExternalReadOnly or {}
    metatable.ExternalReadAndWrite = tableData.ExternalReadAndWrite

    Metatables[proxy] = metatable

    return setmetatable(metatable, TableProxy)
end

function TableProxy:IsInternalAccess()
    if type(self) == "userdata" then
        return false
    elseif type(self) == "table" then
        if rawget(self, "Proxy") == self then
            return false
        else
            return true
        end
    end
    return false
end

function TableProxy:AddFallbackIndex(index)
    Output.assert(self:IsInternalAccess(), "Attempt to modify internal property")
    table.insert(self.FallbackIndexes, index)
end

function TableProxy:SetFallbackIndexes(indexes)
    Output.assert(self:IsInternalAccess(), "Attempt to modify internal property")
    self.FallbackIndexes = indexes
end

function TableProxy:AddFallbackNewIndexes(newindex)
    Output.assert(self:IsInternalAccess(), "Attempt to modify internal property")
    table.insert(self.FallbackIndexes, newindex)
end

function TableProxy:SetFallbackNewIndexes(newindexes)
    Output.assert(self:IsInternalAccess(), "Attempt to modify internal property")
    self.FallbackIndexes = newindexes
end

return TableProxy