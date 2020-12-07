local Deus = shared.DeusFramework

local RunService = game:GetService("RunService")

local Debug = Deus:Load("Deus/Debug")
local Symbol = Deus:Load("Deus/Symbol")

local SymbolNone = Symbol.new("nil")

local Metatables = {}

local function __index(self, i)
    Debug.assert(not Metatables[self], "Use ':GetValue()' when reading values")
    local values = rawget(self, "__values")
    Debug.assert(values[i], "Index '%s' was not found", i)
    return values[i]
end

local function __newindex(self, i, v)
    Debug.assert(not Metatables[self], "Use ':SetValue()' when writing values")
    local values = rawget(self, "__values")
    Debug.assert(values[i], "Index '%s' was not found", i)
    values[i] = v
end

local ReplicatedTable = {}

function ReplicatedTable.new(values)
    local self = newproxy(true)
    local metatable = getmetatable(self)

    metatable.__index = __index
    metatable.__newindex = __newindex
    metatable.__metatable = "[TableProxy] Locked metatable"

    metatable.__proxy = self

    metatable.__values = {}

    for i,v in pairs(values) do
        Debug.assert(type(i) == "string", "Index '%s' must be a string", i)
        if v == nil then
            v = SymbolNone
        end
        metatable.__values[i] = v
    end
    Metatables[self] = metatable

    return setmetatable(metatable, ReplicatedTable)
end

function ReplicatedTable:GetValue(i)
    self = Metatables[self] or self
end

function ReplicatedTable:SetValue(i, v)
    self = Metatables[self] or self
end

function ReplicatedTable:SetAuthority()
    Debug.assert(RunService:IsServer(), "Setting authority on ReplicatedTable cannot be done by client")
end

function ReplicatedTable:SetReplicationMode()
    Debug.assert(RunService:IsServer(), "Setting replication mode on ReplicatedTable cannot be done by client")
end

return ReplicatedTable