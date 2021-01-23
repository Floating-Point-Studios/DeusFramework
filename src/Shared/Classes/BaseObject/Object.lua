local Deus = shared.Deus

local TableUtils = Deus:Load("Deus.TableUtils")
local JSON = Deus:Load("Deus.JSON")
local Output = Deus:Load("Deus.Output")

local Object = {}

-- Fires an event of the object
function Object:FireEvent(internalAccess, eventName, ...)
    Output.assert(internalAccess, "Object events can only be fired with internal access")
    Output.assert(self.DEUSOBJECT_LockedTables.Events[eventName], "Event '%s' is not a valid member of '%s'", {eventName, self.ClassName})
    self.DEUSOBJECT_LockedTables.Events[eventName]:Fire(...)
end

-- Returns a ScriptSignalConnection for a specific property
function Object:GetPropertyChangedSignal(internalAccess, eventName, func)
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

return Object