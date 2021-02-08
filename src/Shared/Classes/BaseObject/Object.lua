local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

local JSON
local Output
local Symbol
local TableUtils
local StringUtils
local InstanceUtils

local Object = {}

-- Fires an event of the object
function Object:FireEvent(internalAccess, eventName, ...)
    Output.assert(internalAccess, "Object events can only be fired with internal access")
    Output.assert(self.DEUSOBJECT_LockedTables.Events[eventName], "Event '%s' is not a valid member of '%s'", {eventName, self.ClassName})
    self.DEUSOBJECT_LockedTables.Events[eventName]:Fire(...)
end

-- Returns a ScriptSignalConnection for a specific property
function Object:GetPropertyChangedSignal(_, eventName, func)
    Output.assert(self.DEUSOBJECT_LockedTables.Events[eventName], "Event '%s' is not a valid member of '%s'", {eventName, self.ClassName})
    local event = Instance.new("BindableEvent")
    local proxySignal = event.Event:Connect(func)
    local mainSignal

    mainSignal = self.DEUSOBJECT_LockedTables.Events[eventName]:Connect(function(...)
        if proxySignal.Connected then
            event:Fire(...)
        else
            mainSignal:Disconnect()
            event:Destroy()
        end
    end)

    return proxySignal
end

function Object:GetMethods()
    return self.DEUSOBJECT_Methods:GetKeys()
end

function Object:GetEvents()
    return self.DEUSOBJECT_Events:GetKeys()
end

-- Returns all public properties
function Object:GetReadableProperties()
    return {TableUtils.unpack(self.DEUSOBJECT_ReadOnlyProperties:GetKeys(), self.DEUSOBJECT_ReadAndWriteProperties:GetKeys())}
end

-- Returns all public properties that can be edited without internal access
function Object:GetWritableProperties()
    return self.DEUSOBJECT_ReadAndWriteProperties:GetKeys()
end

-- Attempts to serialize the object
function Object:Serialize()
    return JSON.serialize(
        {
            ClassName = self.ClassName,
            PrivateProperties = self.Internal.DEUSOBJECT_Properties,
            ReadOnlyProperties = self.ExternalReadOnly.DEUSOBJECT_ReadOnlyProperties:Copy(),
            ReadAndWriteProperties = self.ExternalReadOnly.DEUSOBJECT_ReadAndWriteProperties:Copy()
        }
    )
end

function Object:Hash()
    return StringUtils.hash(self:Serialize())
end

local function cleanupReplication(self)
    local obj = self.ReplicationTarget
    CollectionService:RemoveTag(obj, "DeusObject")
    self.ReplicationTarget = nil

    for i in pairs(obj:GetAttributes()) do
        if i:sub(1, 5) == "DEUS_" then
            obj:SetAttribute(i, nil)
        end
    end
end

function Object:Replicate(internalAccess, obj)
    Output.assert(internalAccess, "Object replication can only be set internally")

    if obj then
        CollectionService:AddTag(obj, "DeusObject")
        self.ReplicationTarget = obj

        if RunService:IsServer() then
            obj:SetAttribute("DEUS_ClassName", self.ClassName)

            for i,v in pairs(self.Internal.DEUSOBJECT_Properties) do
                -- Objects store the symbol none due to not being able to store nil in a table, attributes cannot store symbols
                if v == nil then
                    v = Symbol.new("None")
                end

                if InstanceUtils.isTypeAttributeSupported(typeof(v)) then
                    obj:SetAttribute("DEUS_".. i, v)
                end
            end

            for i,v in pairs(self.ExternalReadOnly.DEUSOBJECT_ReadOnlyProperties:Copy()) do
                if v == nil then
                    v = Symbol.new("None")
                end

                if InstanceUtils.isTypeAttributeSupported(typeof(v)) then
                    obj:SetAttribute("DEUS_".. i, v)
                end
            end

            for i,v in pairs(self.ExternalReadOnly.DEUSOBJECT_ReadAndWriteProperties:Copy()) do
                if v == nil then
                    v = Symbol.new("None")
                end

                if InstanceUtils.isTypeAttributeSupported(typeof(v)) then
                    obj:SetAttribute("DEUS_".. i, v)
                end
            end
        else
            Output.assert(self.ClassName == obj:GetAttribute("DEUS_ClassName"), "Provided object is not a valid replication source")

            for i,v in pairs(obj:GetAttributes()) do
                if i:sub(1, 5) == "DEUS_" then
                    self[i:sub(6)] = v
                end
            end

            local scriptSignal
            scriptSignal = obj.AttributeChanged():Connect(function(attributeName)
                if self.ReplicationTarget == obj then
                    if attributeName:sub(1, 5) == "DEUS_" then
                        self[attributeName:sub(6)] = obj:GetAttribute(attributeName) or Symbol.new("None")
                    end
                else
                    scriptSignal:Disconnect()
                    cleanupReplication(self)
                end
            end)
        end
    else
        cleanupReplication(self)
    end
end

function Object.start()
    JSON = Object:Load("Deus.JSON")
    Output = Object:Load("Deus.Output")
    Symbol = Object:Load("Deus.Symbol")
    TableUtils = Object:Load("Deus.TableUtils")
    StringUtils = Object:Load("Deus.StringUtils")
    InstanceUtils = Object:Load("Deus.InstanceUtils")
end

return Object