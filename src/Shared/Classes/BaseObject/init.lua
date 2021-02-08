--[[
    Objects that require permissions, object inheritance, events, replication across the client-server boundary, or attaching to Roblox instances via attributes
    are inherited from BaseObject. Objects that do not require any of this should be constructed from a basic metatable.

    Object properties can be referenced by their direct path when internally accessed. This is faster but not guaranteed to be supported in the case BaseObject
    or TableProxy are updated. Note the Changed event will not fire if edits are applied directly through this method.

    BaseObject = {
        ClassName = "",
            Direct: self.Internal.DEUSOBJECT_LockedTables.ReadOnlyProperties.ClassName

        Extendable = true,
            Direct: self.Internal.DEUSOBJECT_LockedTables.ReadOnlyProperties.Extendable

        Replicable = true,
            Direct: self.Internal.DEUSOBJECT_LockedTables.ReadOnlyProperties.Replicable

        Constructor = function(self)

        end,

        Methods = {},
            Direct: self.Internal.DEUSOBJECT_LockedTables.Methods

        Events = {},
            Direct: self.Internal.DEUSOBJECT_LockedTables.Events

        PrivateProperties = {},
            Direct: self.Internal.DEUSOBJECT_Properties

        PublicReadOnlyProperties = {},
            Direct: self.Internal.DEUSOBJECT_LockedTables.ReadOnlyProperties

        PublicReadAndWriteProperties = {},
            Direct: self.Internal.DEUSOBJECT_LockedTables.ReadAndWriteProperties
    }
]]

local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local Output
local Symbol
local TableProxy
local TableUtils
local InstanceUtils
local BindableEvent
local BlueprintMeta
local ObjectMeta

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
    if v ~= nil then
        return v
    end

    v = Events[i]
    if v ~= nil then
        if internalAccess then
            return v
        else
            return v.Proxy
        end
    end

    v = InternalProperties[i]
    if v ~= nil then
        Output.assert(internalAccess, "[DeusObject] [%s] Attempt to read internal property", ExternalReadOnlyProperties.ClassName)
        return v
    end

    v = ExternalReadOnlyProperties[i]
    if v ~= nil then
        return v
    end

    v = ExternalReadAndWriteProperties[i]
    if v ~= nil then
        return v
    end

    return nil
end

function __newindex(self, i, v, internalAccess)
    local oldv
    v = v or Symbol.new("None")

    local Internal = rawget(self, "Internal")
    local Methods = Internal.DEUSOBJECT_LockedTables.Methods
    local Events = Internal.DEUSOBJECT_LockedTables.Events
    local InternalProperties = Internal.DEUSOBJECT_Properties
    local ExternalReadOnlyProperties = Internal.DEUSOBJECT_LockedTables.ReadOnlyProperties
    local ExternalReadAndWriteProperties = Internal.DEUSOBJECT_LockedTables.ReadAndWriteProperties

    oldv = Methods[i]
    if oldv ~= nil then
        Output.assert(internalAccess, "[DeusObject] [%s] Attempt to modify internal property", ExternalReadOnlyProperties.ClassName)
        Methods[i] = v
        if Events.Changed then
            Events.Changed:Fire(i, v, oldv)
        end
        return true
    end

    if Events[i] ~= nil then
        Output.error("Events cannot be modified after object creation")
        return false
    end

    oldv = InternalProperties[i]
    if oldv ~= nil then
        Output.assert(internalAccess, "[DeusObject] [%s] Attempt to modify internal property", ExternalReadOnlyProperties.ClassName)
        InternalProperties[i] = v
        --[[
        if Events.Changed then
            Events.Changed:Fire(i, v, oldv)
        end
        ]]
        return true
    end

    oldv = ExternalReadOnlyProperties[i]
    if oldv ~= nil then
        Output.assert(internalAccess, "[DeusObject] [%s] Attempt to modify read-only property", ExternalReadOnlyProperties.ClassName)
        ExternalReadOnlyProperties[i] = v
        if Events.Changed then
            Events.Changed:Fire(i, v, oldv)
        end
        return true
    end

    oldv = ExternalReadAndWriteProperties[i]
    if oldv ~= nil then
        ExternalReadAndWriteProperties[i] = v
        if Events.Changed then
            Events.Changed:Fire(i, v, oldv)
        end
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
            -- Constructor = objData.Constructor,

            ClassName                       = objData.ClassName,

            Extendable                      = objData.Extendable or true,
            Replicable                      = objData.Replicable or true,

            Methods                         = objData.Methods or {},

            PublicReadAndWriteProperties    = objData.PublicReadAndWriteProperties or {},
            PublicReadOnlyProperties        = objData.PublicReadOnlyProperties or {},
            PrivateProperties               = objData.PrivateProperties or {},

            Events                          = objData.Events or {},

            new = function(...)
                local obj = {
                    __tostring  = __tostring,
                    __index     = __index,
                    __newindex  = __newindex,

                    Internal = {
                        DEUSOBJECT_Properties = TableUtils.deepCopy(objData.PrivateProperties or {}),
                        DEUSOBJECT_LockedTables = {
                            Events = {},
                        },
                    },

                    ExternalReadOnly = {
                        DEUSOBJECT_Methods                  = TableUtils.deepCopy(TableUtils.merge(ObjectMeta, objData.Methods or {})),
                        DEUSOBJECT_ReadOnlyProperties       = TableUtils.deepCopy(objData.PublicReadOnlyProperties or {}),
                        DEUSOBJECT_ReadAndWriteProperties   = TableUtils.deepCopy(objData.PublicReadAndWriteProperties or {}),
                        DEUSOBJECT_Events                   = TableUtils.shallowCopy(objData.Events or {}),
                    }
                }

                for methodName, method in pairs(obj.ExternalReadOnly.DEUSOBJECT_Methods) do
                    obj.ExternalReadOnly.DEUSOBJECT_Methods[methodName] = function(self, ...)
                        local internalAccess = false
                        if obj == self then
                            internalAccess = true
                        end
                        return method(obj, internalAccess, ...)
                    end
                end

                --[[
                -- Special exemption for objects that should not inherit base events
                if objData.ClassName ~= "Deus.BindableEvent" then
                    table.insert(obj.ExternalReadOnly.DEUSOBJECT_Events, "Changed")
                end
                --]]

                for _,eventName in pairs(obj.ExternalReadOnly.DEUSOBJECT_Events) do
                    local eventProxy, eventMeta = BindableEvent.new()
                    obj.Internal.DEUSOBJECT_LockedTables.Events[eventName] = eventMeta
                    obj.ExternalReadOnly.DEUSOBJECT_Events[eventName] = eventProxy
                end

                -- Properties inherited by all objects
                obj.ExternalReadOnly.DEUSOBJECT_ReadOnlyProperties.ClassName            = objData.ClassName
                obj.ExternalReadOnly.DEUSOBJECT_ReadOnlyProperties.Extendable           = objData.Extendable or true
                obj.ExternalReadOnly.DEUSOBJECT_ReadOnlyProperties.Replicable           = objData.Replicable or true
                obj.ExternalReadOnly.DEUSOBJECT_ReadOnlyProperties.ObjectId             = HttpService:GenerateGUID(false)
                obj.ExternalReadOnly.DEUSOBJECT_ReadOnlyProperties.TickCreated          = tick()
                obj.ExternalReadOnly.DEUSOBJECT_ReadOnlyProperties.ReplicationTarget    = Symbol.new("None")

                -- Allows editing of properties locked externally
                obj.Internal.DEUSOBJECT_LockedTables.Methods                            = obj.ExternalReadOnly.DEUSOBJECT_Methods
                obj.Internal.DEUSOBJECT_LockedTables.ReadOnlyProperties                 = obj.ExternalReadOnly.DEUSOBJECT_ReadOnlyProperties
                obj.Internal.DEUSOBJECT_LockedTables.ReadAndWriteProperties             = obj.ExternalReadOnly.DEUSOBJECT_ReadAndWriteProperties
                obj.Internal.DEUSOBJECT_LockedTables.Events                             = obj.ExternalReadOnly.DEUSOBJECT_Events

                -- Locks properties to be only readable externally
                obj.ExternalReadOnly.DEUSOBJECT_Methods                                 = TableUtils.lock(obj.Internal.DEUSOBJECT_LockedTables.Methods)
                obj.ExternalReadOnly.DEUSOBJECT_ReadOnlyProperties                      = TableUtils.lock(obj.Internal.DEUSOBJECT_LockedTables.ReadOnlyProperties)
                obj.ExternalReadOnly.DEUSOBJECT_ReadAndWriteProperties                  = TableUtils.lock(obj.Internal.DEUSOBJECT_LockedTables.ReadAndWriteProperties)
                obj.ExternalReadOnly.DEUSOBJECT_Events                                  = TableUtils.lock(obj.Internal.DEUSOBJECT_LockedTables.Events)

                obj = TableProxy.new(obj)

                if objData.Constructor then
                    objData.Constructor(obj, ...)
                end

                if obj.Changed then
                    if RunService:IsServer() then
                        obj.Changed:Connect(function(propertyName, newValue)
                            if newValue == Symbol.new("None") then
                                newValue = nil
                            end

                            local replicationTarget = obj.ReplicationTarget
                            if typeof(replicationTarget) == "Instance" and InstanceUtils.isTypeAttributeSupported(typeof(newValue)) then
                                replicationTarget:SetAttribute("DEUS_".. propertyName, newValue)
                            end
                        end)
                    end
                end

                return obj
            end
        },
        BlueprintMeta
    )
end

function BaseObject.getClassList()
    return TableUtils.shallowCopy(ClassList)
end

function BaseObject.start()
    Output = BaseObject:Load("Deus.Output")
    Symbol = BaseObject:Load("Deus.Symbol")
    TableProxy = BaseObject:Load("Deus.TableProxy")
    TableUtils = BaseObject:Load("Deus.TableUtils")
    InstanceUtils = BaseObject:Load("Deus.InstanceUtils")
    BindableEvent = BaseObject:Load("Deus.BindableEvent")
end

function BaseObject.init()
    BlueprintMeta = BaseObject:WrapModule(script.Blueprint)
    ObjectMeta = BaseObject:WrapModule(script.Object)
end

return BaseObject