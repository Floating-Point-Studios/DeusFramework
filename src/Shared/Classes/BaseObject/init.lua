local HttpService = game:GetService("HttpService")

local Deus = shared.Deus

local Output = Deus:Load("Deus.Output")
local TableProxy = Deus:Load("Deus.TableProxy")
local TableUtils = Deus:Load("Deus.TableUtils")

local BlueprintMeta = require(script.Blueprint)
local ObjectMeta = require(script.Object)

local ClassList = {}

function __tostring(self)
    return ("[DeusObject] [%s] [%s]"):format(self.ClassName, self.ObjectId)
end

function __index(self, i, internalAccess)
    local v

    local Internal = rawget(self, "Internal")
    local Methods = Internal.DEUSOBJECT_LockedTables.Methods
    local Events = Internal.DEUSOBJECT_LockedTables.Events
    local InternalProperties = Internal.DEUSOBJECT_Properties
    local ExternalReadOnlyProperties = Internal.DEUSOBJECT_LockedTables.ReadOnlyProperties
    local ExternalReadAndWriteProperties = Internal.DEUSOBJECT_LockedTables.ReadAndWriteProperties

    v = Methods[i]
    if v then
        return v
    end

    v = Events[i]
    if v then
        return v
    end

    v = InternalProperties[i]
    if v then
        Output.assert(internalAccess, "[DeusObject] [%s] Attempt to read internal property", ExternalReadOnlyProperties.ClassName)
        return v
    end

    v = ExternalReadOnlyProperties[i]
    if v then
        return v
    end

    v = ExternalReadAndWriteProperties[i]
    if v then
        return v
    end

    return nil
end

function __newindex(self, i, v, internalAccess)
    local Internal = rawget(self, "Internal")
    local Methods = Internal.DEUSOBJECT_LockedTables.Methods
    local Events = Internal.DEUSOBJECT_LockedTables.Events
    local InternalProperties = Internal.DEUSOBJECT_Properties
    local ExternalReadOnlyProperties = Internal.DEUSOBJECT_LockedTables.ReadOnlyProperties
    local ExternalReadAndWriteProperties = Internal.DEUSOBJECT_LockedTables.ReadAndWriteProperties

    if Methods[i] then
        Output.assert(internalAccess, "[DeusObject] [%s] Attempt to modify internal property", ExternalReadOnlyProperties.ClassName)
        Methods[i] = v
        return true
    end

    if Events[i] then
        Output.assert(internalAccess, "[DeusObject] [%s] Attempt to modify internal property", ExternalReadOnlyProperties.ClassName)
        Events[i] = v
        return true
    end

    if InternalProperties[i] then
        Output.assert(internalAccess, "[DeusObject] [%s] Attempt to modify internal property", ExternalReadOnlyProperties.ClassName)
        InternalProperties[i] = v
        return true
    end

    if ExternalReadOnlyProperties[i] then
        Output.assert(internalAccess, "[DeusObject] [%s] Attempt to modify read-only property", ExternalReadOnlyProperties.ClassName)
        ExternalReadOnlyProperties[i] = v
        return true
    end

    if ExternalReadAndWriteProperties[i] then
        ExternalReadAndWriteProperties[i] = v
        return true
    end

    return false
end

local BaseObject = {}

function BaseObject.new(objData)
    objData.ClassName = objData.ClassName or ("Deus.UnnamedObject [%s]"):format(HttpService:GenerateGUID(false))

    table.insert(ClassList, objData.ClassName)

    return setmetatable(
        {
            Constructor = objData.Constructor,

            ClassName = objData.ClassName,

            Methods = objData.Methods or {},

            PublicReadAndWriteProperties = objData.PublicReadAndWriteProperties or {},

            PublicReadOnlyProperties = objData.PublicReadOnlyProperties or {},

            PrivateProperties = objData.PrivateProperties or {},

            Events = objData.Events or {},

            new = function()
                local obj = {
                    __tostring = __tostring,
                    __index = __index,
                    __newindex = __newindex,

                    Internal = {
                        DEUSOBJECT_Properties = TableUtils.deepCopy(objData.PrivateProperties or {}),
                        DEUSOBJECT_LockedTables = {},
                    },

                    ExternalReadOnly = {
                        DEUSOBJECT_Methods = TableUtils.deepCopy(TableUtils.merge(ObjectMeta, objData.Methods or {})),
                        DEUSOBJECT_ReadOnlyProperties = TableUtils.deepCopy(objData.PublicReadOnlyProperties or {}),
                        DEUSOBJECT_ReadAndWriteProperties = TableUtils.deepCopy(objData.PublicReadAndWriteProperties or {}),
                        DEUSOBJECT_Events = {},
                    }
                }

                for methodName, method in pairs(obj.ExternalReadOnly.DEUSOBJECT_Methods) do
                    obj.ExternalReadOnly.DEUSOBJECT_Methods[methodName] = function(...)
                        method(obj, ...)
                    end
                end

                for _,eventName in pairs(obj.ExternalReadOnly.DEUSOBJECT_Events) do
                    -- todo: add events
                end

                obj.ExternalReadOnly.DEUSOBJECT_ReadOnlyProperties.ClassName = objData.ClassName
                obj.ExternalReadOnly.DEUSOBJECT_ReadOnlyProperties.ObjectId = HttpService:GenerateGUID(false)
                obj.ExternalReadOnly.DEUSOBJECT_ReadOnlyProperties.TickCreated = tick()
                obj.ExternalReadOnly.DEUSOBJECT_ReadOnlyProperties.IsReplicated = false
                obj.ExternalReadOnly.DEUSOBJECT_ReadOnlyProperties.NetworkOwner = nil

                obj.Internal.DEUSOBJECT_LockedTables.Methods = obj.ExternalReadOnly.DEUSOBJECT_Methods
                obj.Internal.DEUSOBJECT_LockedTables.ReadOnlyProperties = obj.ExternalReadOnly.DEUSOBJECT_ReadOnlyProperties
                obj.Internal.DEUSOBJECT_LockedTables.ReadAndWriteProperties = obj.ExternalReadOnly.DEUSOBJECT_ReadAndWriteProperties
                obj.Internal.DEUSOBJECT_LockedTables.Events = obj.ExternalReadOnly.DEUSOBJECT_Events

                obj.ExternalReadOnly.DEUSOBJECT_Methods = TableUtils.lock(obj.Internal.DEUSOBJECT_LockedTables.Methods)
                obj.ExternalReadOnly.DEUSOBJECT_ReadOnlyProperties = TableUtils.lock(obj.Internal.DEUSOBJECT_LockedTables.ReadOnlyProperties)
                obj.ExternalReadOnly.DEUSOBJECT_ReadAndWriteProperties = TableUtils.lock(obj.Internal.DEUSOBJECT_LockedTables.ReadAndWriteProperties)
                obj.ExternalReadOnly.DEUSOBJECT_Events = TableUtils.lock(obj.Internal.DEUSOBJECT_LockedTables.Events)

                obj = TableProxy.new(obj)

                return obj.Proxy
            end
        },
        BlueprintMeta
    )
end

function BaseObject.getClassList()
    return TableUtils.shallowCopy(ClassList)
end

return BaseObject