local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

local Maid
local JSON
local Output
local Symbol
local TableUtils
local StringUtils
local InstanceUtils

local Object = {}

function Object:IsA(className)
    local object = self

    if className == "BaseObject" then
        return true
    end

    repeat
        if object.ClassName == className then
            return true
        end

        -- First 'object' will be an object, every 'object' afterwards is a ClassData
        if object.Superclass then
            object = object.Superclass
        else
            object = object.Metadata.Superclass
        end
    until object == "BaseObject"

    return false
end

-- Runs constructor again to reset the object, useful for re-using instead of destroying objects
function Object:Reconstruct(...)
    Output.assert(self:IsInternalAccess(), "Object can only be reconstructed with internal access")

    local constructor = self.Constructor
    if constructor then
        constructor(self, ...)
    else
        Output.Output.error("Object class '%s' does not have any constructor parameters", self.ClassName)
    end

    return self
end

function Object:Destroy()
    local deconstructor = self.Deconstructor
    if deconstructor then
        -- Deconstructor is allowed to return list of objects it wants destroyed
        for _,v in pairs(deconstructor(self) or {}) do
            Maid:GiveTask(v)
        end
    end

    local destroyedEvent = self.Internal.DEUSOBJECT_LockedTables.Events["Destroyed"]
    if destroyedEvent then
        destroyedEvent:Fire()
    end

    Maid:GiveTask(self)
    Maid:DoCleaning()
end

-- Fires an event of the object
function Object:FireEvent(eventName, ...)
    Output.assert(self:IsInternalAccess(), "Object events can only be fired with internal access")
    Output.assert(self.Internal.DEUSOBJECT_LockedTables.Events[eventName], "Event '%s' is not a valid member of '%s'", {eventName, self.ClassName})
    self.Internal.DEUSOBJECT_LockedTables.Events[eventName]:Fire(...)

    return self
end

-- Returns a ScriptSignalConnection for a specific property
function Object:GetPropertyChangedSignal(eventName, func)
    Output.assert(self.Internal.DEUSOBJECT_LockedTables.Events[eventName], "Event '%s' is not a valid member of '%s'", {eventName, self.ClassName})
    local event = Instance.new("BindableEvent")
    local proxySignal = event.Event:Connect(func)
    local mainSignal

    mainSignal = self.Internal.DEUSOBJECT_LockedTables.Events[eventName]:Connect(function(...)
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
    return self.Internal.DEUSOBJECT_LockedTables.Methods:GetKeys()
end

-- TODO: Check if this allows external access to fire events
function Object:GetEvents()
    return self.Internal.DEUSOBJECT_LockedTables.Events:GetKeys()
end

-- Returns all public properties
function Object:GetReadableProperties()
    return {TableUtils.unpack(self.Internal.DEUSOBJECT_LockedTables.ReadOnlyProperties:GetKeys(), self.Internal.DEUSOBJECT_LockedTables.ReadAndWriteProperties:GetKeys())}
end

-- Returns all public properties that can be edited without internal access
function Object:GetWritableProperties()
    return self.Internal.DEUSOBJECT_LockedTables.ReadAndWriteProperties:GetKeys()
end

-- Attempts to serialize the object
function Object:SerializeProperties()
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
    return StringUtils.hash(self:SerializeProperties())
end

local function cleanupPropertyReplication(self)
    local obj = self.ExternalReadOnly.DEUSOBJECT_ReadOnlyProperties.PropertyReplicationTarget
    CollectionService:RemoveTag(obj, "DeusObject")
    self.ExternalReadOnly.DEUSOBJECT_ReadOnlyProperties.PropertyReplicationTarget = nil

    for i in pairs(obj:GetAttributes()) do
        if i:sub(1, 5) == "DEUS_" then
            obj:SetAttribute(i, nil)
        end
    end
end

function Object:ReplicateProperties(obj)
    Output.assert(self:IsInternalAccess(), "Object replication can only be set internally")

    if obj then
        CollectionService:AddTag(obj, "DeusObject")
        self.ExternalReadOnly.DEUSOBJECT_ReadOnlyProperties.PropertyReplicationTarget = obj

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
                if self.ExternalReadOnly.DEUSOBJECT_ReadOnlyProperties.PropertyReplicationTarget == obj then
                    if attributeName:sub(1, 5) == "DEUS_" then
                        self[attributeName:sub(6)] = obj:GetAttribute(attributeName) or Symbol.new("None")
                    end
                else
                    scriptSignal:Disconnect()
                    cleanupPropertyReplication(self)
                end
            end)
        end
    else
        cleanupPropertyReplication(self)
    end

    return self
end

function Object:IsInternalAccess()
    return typeof(self) ~= "userdata"
end

function Object:start()
    Maid = self:Load("Deus.Maid")
    JSON = self:Load("Deus.JSON")
    Output = self:Load("Deus.Output")
    Symbol = self:Load("Deus.Symbol")
    TableUtils = self:Load("Deus.TableUtils")
    StringUtils = self:Load("Deus.StringUtils")
    InstanceUtils = self:Load("Deus.InstanceUtils")
end

return Object