local Output

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

    local Internal = rawget(self, "Internal")
    local ExternalReadOnly = rawget(self, "ExternalReadOnly")
    local ExternalReadAndWrite = rawget(self, "ExternalReadAndWrite")

    if Internal then
        v = Internal[i]
        if v ~= nil then
            if internalAccess then
                return v
            else
                Output.error("Attempt to read internal property")
            end
        end
    end

    if ExternalReadOnly then
        v = ExternalReadOnly[i]
        if v ~= nil then
            return v
        end
    end

    if ExternalReadAndWrite then
        v = ExternalReadAndWrite[i]
        if v ~= nil then
            return v
        end
    end

    v = rawget(self, "Index")(self, i, internalAccess)
    if v ~= nil then
        return v
    end

    return nil
end

function TableProxy.__newindex(self, i, v)
    local internalAccess = TableProxy.IsInternalAccess(self)
    if not internalAccess then
        self = Metatables[self]
    end

    local Internal = rawget(self, "Internal")
    local ExternalReadOnly = rawget(self, "ExternalReadOnly")
    local ExternalReadAndWrite = rawget(self, "ExternalReadAndWrite")
    local NewIndex = rawget(self, "NewIndex")

    if Internal and Internal[i] ~= nil then
        if internalAccess then
            Internal[i] = v
            return true
        else
            Output.error("Attempt to modify internal property")
        end
    end

    if ExternalReadOnly and ExternalReadOnly[i] ~= nil then
        ExternalReadOnly[i] = v
        return true
    end

    if ExternalReadAndWrite and ExternalReadAndWrite[i] ~= nil then
        ExternalReadAndWrite[i] = v
        return true
    end

    if NewIndex(self, i, v, internalAccess) then
        return true
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
    metatable.Index = tableData.__index
    metatable.NewIndex = tableData.__newindex

    metatable.Internal = tableData.Internal
    metatable.ExternalReadOnly = tableData.ExternalReadOnly
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

--[[
function TableProxy:AddFallbackIndex(index)
    Output.assert(self:IsInternalAccess(), "Attempt to modify internal property")
    Output.assert(type(index) == "function", "Expected 'function' got '%s'", type(index))
    table.insert(self.FallbackIndexes, index)
end

function TableProxy:SetFallbackIndexes(indexes)
    Output.assert(self:IsInternalAccess(), "Attempt to modify internal property")
    Output.assert(type(indexes) == "table", "Expected 'table' got '%s'", type(indexes))
    self.FallbackIndexes = indexes
end

function TableProxy:AddFallbackNewIndexes(newindex)
    Output.assert(self:IsInternalAccess(), "Attempt to modify internal property")
    Output.assert(type(newindex) == "function", "Expected 'function' got '%s'", type(newindex))
    table.insert(self.FallbackIndexes, newindex)
end

function TableProxy:SetFallbackNewIndexes(newindexes)
    Output.assert(self:IsInternalAccess(), "Attempt to modify internal property")
    Output.assert(type(newindexes) == "table", "Expected 'table' got '%s'", type(newindexes))
    self.FallbackIndexes = newindexes
end
]]

function TableProxy:start()
    Output = self:Load("Deus.Output")
end

return TableProxy