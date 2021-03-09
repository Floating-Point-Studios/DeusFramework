-- TODO: Refactor to use 'Proxy'

--[[
    For documentation refer to here:
    https://floating-point-studios.github.io/CardinalEngine/DeusFramework/Classes/baseObject/
]]

local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local Output
local Symbol
local Proxy
local TableUtils
local InstanceUtils
local BindableEvent
-- local ObjectService

local NewClassEvent
local NewObjectEvent
local BaseObjectSuperclass

local ClassList = {}

function __tostring(self)
    return ("[DeusObject] [%s] [%s]"):format(self.ClassName, self.ObjectId)
end

function __index(self, i)
    local internalAccess = type(self) == "table"
    local v

    local Internal = self.Internal
    -- local Methods = Internal.DEUSOBJECT_LockedTables.Methods
    local Events = Internal.DEUSOBJECT_LockedTables.Events
    local InternalProperties = Internal.DEUSOBJECT_Properties
    local ExternalReadOnlyProperties = Internal.DEUSOBJECT_LockedTables.ReadOnlyProperties
    local ExternalReadAndWriteProperties = Internal.DEUSOBJECT_LockedTables.ReadAndWriteProperties

    local Methods = self.ExternalReadOnly.DEUSOBJECT_Methods

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

function __newindex(self, i, v)
    local internalAccess = type(self) == "table"
    local oldv
    if v == nil then
        v = Symbol.new("None") 
    end

    local Internal = self.Internal
    -- local Methods = Internal.DEUSOBJECT_LockedTables.Methods
    local Events = Internal.DEUSOBJECT_LockedTables.Events
    local InternalProperties = Internal.DEUSOBJECT_Properties
    local ExternalReadOnlyProperties = Internal.DEUSOBJECT_LockedTables.ReadOnlyProperties
    local ExternalReadAndWriteProperties = Internal.DEUSOBJECT_LockedTables.ReadAndWriteProperties

    --[[
    No more editing methods after object is created

    oldv = Methods[i]
    if oldv ~= nil then
        Output.assert(internalAccess, "[DeusObject] [%s] Attempt to modify internal property", ExternalReadOnlyProperties.ClassName)
        Methods[i] = v
        if Events.Changed then
            Events.Changed:Fire(i, v, oldv)
        end
        return true
    end
    ]]

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
    objData.ClassName   = objData.ClassName or ("Deus.UnnamedObject [%s]"):format(HttpService:GenerateGUID(false):sub(1, 8))
    objData.Methods     = objData.Methods or {}

    local superclass = objData.Superclass
    if superclass then
        Output.assert(superclass.Extendable, "Superclass '%s' is not extendable", superclass.ClassName)
        setmetatable(objData.Methods, {__index = superclass.Methods})
    else
        setmetatable(objData.Methods, {__index = BaseObjectSuperclass})
    end

    table.insert(ClassList, objData.ClassName)

    local metadata = {
        ClassName                   = objData.ClassName,

        Extendable                  = objData.Extendable or true,
        Replicable                  = objData.Replicable or true,
        Superclass                  = objData.Superclass or "BaseObject",

        Methods                     = TableUtils.lock(objData.Methods), -- Methods table cannot be edited even with internal access

        Constructor                 = objData.Constructor,
        Deconstructor               = objData.Deconstructor
    }

    local classData = {
        -- Constructor = objData.Constructor,

        -- metadata                        = metadata,

        PublicReadAndWriteProperties    = objData.PublicReadAndWriteProperties or {},
        PublicReadOnlyProperties        = objData.PublicReadOnlyProperties or {},
        PrivateProperties               = objData.PrivateProperties or {},

        Events                          = objData.Events or {},

        new = function(...)
            local obj = {
                --[[
                __tostring  = __tostring,
                __index     = __index,
                __newindex  = __newindex,
                ]]

                Internal = {
                    DEUSOBJECT_Properties = TableUtils.deepCopy(objData.PrivateProperties or {}),
                    DEUSOBJECT_LockedTables = {
                        Events = {},
                    },
                },

                ExternalReadOnly = {
                    DEUSOBJECT_Methods                  = metadata.Methods,
                    DEUSOBJECT_ReadOnlyProperties       = TableUtils.deepCopy(objData.PublicReadOnlyProperties or {}),
                    DEUSOBJECT_ReadAndWriteProperties   = TableUtils.deepCopy(objData.PublicReadAndWriteProperties or {}),
                    DEUSOBJECT_Events                   = TableUtils.shallowCopy(objData.Events or {}),
                }
            }

            --[[
            -- Wrap methods
            for methodName, method in pairs(obj.ExternalReadOnly.DEUSOBJECT_Methods) do
                obj.ExternalReadOnly.DEUSOBJECT_Methods[methodName] = function(self, ...)
                    local internalAccess = false
                    if obj == self then
                        internalAccess = true
                    end
                    return method(obj, internalAccess, ...)
                end
            end
            ]]

            --[[
            -- Special exemption for objects that should not inherit base events
            if objData.ClassName ~= "Deus.BindableEvent" then
                table.insert(obj.ExternalReadOnly.DEUSOBJECT_Events, "Changed")
            end
            ]]

            -- Add events
            for _,eventName in pairs(obj.ExternalReadOnly.DEUSOBJECT_Events) do
                local eventProxy, eventMeta = BindableEvent.new()
                obj.Internal.DEUSOBJECT_LockedTables.Events[eventName] = eventMeta
                obj.ExternalReadOnly.DEUSOBJECT_Events[eventName] = eventProxy
            end

            -- Read-only properties inherited by all objects
            -- obj.ExternalReadOnly.DEUSOBJECT_ReadOnlyProperties.ClassName            = objData.ClassName
            -- obj.ExternalReadOnly.DEUSOBJECT_ReadOnlyProperties.Extendable           = objData.Extendable or true
            -- obj.ExternalReadOnly.DEUSOBJECT_ReadOnlyProperties.Replicable           = objData.Replicable or true
            obj.ExternalReadOnly.DEUSOBJECT_ReadOnlyProperties.ObjectId                     = HttpService:GenerateGUID(false):sub(1, 8) -- Only use first 8 characters to save memory
            obj.ExternalReadOnly.DEUSOBJECT_ReadOnlyProperties.TickCreated                  = tick()
            obj.ExternalReadOnly.DEUSOBJECT_ReadOnlyProperties.PropertyReplicationTarget    = Symbol.new("None")
            obj.ExternalReadOnly.DEUSOBJECT_ReadOnlyProperties.IsDead                       = false

            -- Allows editing of properties locked externally
            -- obj.Internal.DEUSOBJECT_LockedTables.Methods                            = obj.ExternalReadOnly.DEUSOBJECT_Methods
            obj.Internal.DEUSOBJECT_LockedTables.ReadOnlyProperties                 = obj.ExternalReadOnly.DEUSOBJECT_ReadOnlyProperties
            obj.Internal.DEUSOBJECT_LockedTables.ReadAndWriteProperties             = obj.ExternalReadOnly.DEUSOBJECT_ReadAndWriteProperties
            obj.Internal.DEUSOBJECT_LockedTables.Events                             = obj.ExternalReadOnly.DEUSOBJECT_Events

            -- Locks properties to be only readable externally
            -- obj.ExternalReadOnly.DEUSOBJECT_Methods                                 = TableUtils.lock(obj.Internal.DEUSOBJECT_LockedTables.Methods)
            obj.ExternalReadOnly.DEUSOBJECT_ReadOnlyProperties                      = TableUtils.lock(obj.Internal.DEUSOBJECT_LockedTables.ReadOnlyProperties)
            obj.ExternalReadOnly.DEUSOBJECT_ReadAndWriteProperties                  = TableUtils.lock(obj.Internal.DEUSOBJECT_LockedTables.ReadAndWriteProperties)
            obj.ExternalReadOnly.DEUSOBJECT_Events                                  = TableUtils.lock(obj.Internal.DEUSOBJECT_LockedTables.Events)

            -- Inherit class metadata
            setmetatable(obj.Internal.DEUSOBJECT_LockedTables.ReadOnlyProperties, {__index = metadata})

            obj = Proxy.new(
                obj,
                {
                    __index = __index,
                    __newindex = __newindex,
                    __tostring = __tostring
                }
            )

            if objData.Constructor then
                objData.Constructor(obj, ...)
            end

            if obj.Changed then
                if RunService:IsServer() then
                    obj.Changed:Connect(function(propertyName, newValue)
                        if newValue == Symbol.new("None") then
                            newValue = nil
                        end

                        local propertyReplicationTarget = obj.PropertyReplicationTarget
                        if typeof(propertyReplicationTarget) == "Instance" and InstanceUtils.isTypeAttributeSupported(typeof(newValue)) then
                            propertyReplicationTarget:SetAttribute("DEUS_".. propertyName, newValue)
                        end
                    end)
                end
            end

            -- ObjectService:TrackObject(obj)

            -- Due to ObjectService being moved to Cardinal this event is now how Cardinal detects when a new object is created
            NewObjectEvent:Fire(obj.Proxy)

            return obj
        end
    }

    -- Set classData metatable
    classData = setmetatable(classData, {__index = metadata})

    -- Fire NewClass event (we cannot fire for the first class which is BindableEvent)
    if NewClassEvent then
        NewClassEvent:Fire(TableUtils.lock(classData))
    end

    return classData
end

-- Creates a class without events, methods are automatically setup, and all properties are set to Public Read & Write
function BaseObject.newSimple(objData)
    local parsedObjData = {
        ClassName                       = objData.ClassName,
        Superclass                      = objData.Superclass,
        Methods                         = {},
        PublicReadAndWriteProperties    = {},
        Constructor                     = objData.Constructor,
        Deconstructor                   = objData.Deconstructor
    }

    for i,v in pairs(objData) do
        -- Check the index isn't a object configuration
        if not parsedObjData[i] then
            -- Check if index is a method or property
            if type(v) == "function" then
                parsedObjData.Methods[i] = v
            else
                parsedObjData.PublicReadAndWriteProperties[i] = v
            end
        end
    end

    return BaseObject.new(parsedObjData)
end

function BaseObject.getClassList()
    return TableUtils.shallowCopy(ClassList)
end

function BaseObject:start()
    Output = self:Load("Deus.Output")
    Symbol = self:Load("Deus.Symbol")
    Proxy = self:Load("Deus.Proxy")
    TableUtils = self:Load("Deus.TableUtils")
    InstanceUtils = self:Load("Deus.InstanceUtils")
    BindableEvent = self:Load("Deus.BindableEvent")
    -- ObjectService = self:Load("Deus.ObjectService")

    NewClassEvent = BindableEvent.new()
    NewObjectEvent = BindableEvent.new()

    self.NewClass = NewClassEvent.Proxy
    self.NewObject = NewObjectEvent.Proxy
end

function BaseObject:init()
    BaseObjectSuperclass = self:WrapModule(script.Object, true, true)
end

return BaseObject