local Deus = shared.Deus

local TableUtils = Deus:Load("Deus.TableUtils")
local Output = Deus:Load("Deus.Output")

local Object = {}

function Object:FireEvent(internalAccess, eventName, ...)
    Output.assert(internalAccess, "Object events can only be fired with internal access")
    Output.assert(self.DEUSOBJECT_LockedTables.Events[eventName], "Event '%s' is not a valid member of '%s'", {eventName, self.ClassName})
    self.DEUSOBJECT_LockedTables.Events[eventName]:Fire(...)
end

function Object:GetMethods()
    return self.DEUSOBJECT_Methods:GetKeys()
end

function Object:GetEvents()
    return self.DEUSOBJECT_Events:GetKeys()
end

function Object:GetReadableProperties()
    return {TableUtils.unpack(self.DEUSOBJECT_ReadOnlyProperties:GetKeys(), self.DEUSOBJECT_ReadAndWriteProperties:GetKeys())}
end

function Object:GetWritableProperties()
    return self.DEUSOBJECT_ReadAndWriteProperties:GetKeys()
end

return Object