--[[
    For documentation refer to here:
    https://floating-point-studios.github.io/CardinalEngine/DeusFramework/Classes/baseObject/
]]

local HttpService = game:GetService("HttpService")

local Output
local Proxy
local TableUtils
local BindableEvent

-- Symbols
local None
local SymbolPrivateProperties
local SymbolReadOnlyProperties
local SymbolReadAndWriteProperties
local SymbolEvents
local SymbolMethods

local NewClassEvent
local NewObjectEvent
local BaseObjectSuperclass

local ClassList = {}

function __tostring(self)
    return ("[DeusObject] [%s] [%s]"):format(self.ClassName, self.ObjectId)
end

function __index(self, i)
    local internalAccess            = type(self) == "table"
    local v

    local PrivateProperties         = self[SymbolPrivateProperties]
    local ReadOnlyProperties        = self[SymbolReadOnlyProperties]
    local ReadAndWriteProperties    = self[SymbolReadAndWriteProperties]
    local Events                    = self[SymbolEvents]
    local Methods                   = self[SymbolMethods]

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

    v = PrivateProperties[i]
    if v ~= nil then
        Output.assert(internalAccess, "[DeusObject] [%s] Attempt to read internal property", ReadOnlyProperties.ClassName, 1)
        if v == None then
            return nil
        else
            return v
        end
    end

    v = ReadOnlyProperties[i]
    if v ~= nil then
        if v == None then
            return nil
        else
            return v
        end
    end

    v = ReadAndWriteProperties[i]
    if v ~= nil then
        if v == None then
            return nil
        else
            return v
        end
    end

    v = rawget(self, i)
    if internalAccess then
        return v
    end

    return nil
end

function __newindex(self, i, v)
    local internalAccess            = type(self) == "table"
    local oldv
    if v == nil then
        v = None
    end

    local PrivateProperties         = self[SymbolPrivateProperties]
    local ReadOnlyProperties        = self[SymbolReadOnlyProperties]
    local ReadAndWriteProperties    = self[SymbolReadAndWriteProperties]
    local Events                    = self[SymbolEvents]

    if Events[i] ~= nil then
        Output.error("Events cannot be modified after object creation", nil, 1)
        return false
    end

    oldv = PrivateProperties[i]
    if oldv ~= nil then
        Output.assert(internalAccess, "[DeusObject] [%s] Attempt to modify internal property", ReadOnlyProperties.ClassName, 1)
        PrivateProperties[i] = v
        return true
    end

    oldv = ReadOnlyProperties[i]
    if oldv ~= nil then
        Output.assert(internalAccess, "[DeusObject] [%s] Attempt to modify read-only property", ReadOnlyProperties.ClassName, 1)
        ReadOnlyProperties[i] = v
        if Events.Changed then
            Events.Changed:Fire(i, v, oldv)
        end
        return true
    end

    oldv = ReadAndWriteProperties[i]
    if oldv ~= nil then
        ReadAndWriteProperties[i] = v
        if Events.Changed then
            Events.Changed:Fire(i, v, oldv)
        end
        return true
    end

    return false
end

local BaseObject = {}

function BaseObject.new(objData)
    objData.ClassName = objData.ClassName or ("UnnamedObject [%s]"):format(HttpService:GenerateGUID(false):sub(1, 8))

    if not objData.Methods then
        local methods = {}

        for i, v in pairs(objData) do
            if type(v) == "function" and i ~= "Constructor" and i ~= "Deconstructor" then
                methods[i] = v
            end
        end

        objData.Methods = methods
    end

    local superclass = objData.Superclass
    if superclass then
        Output.assert(superclass.Extendable, "Superclass %s is not extendable", superclass.ClassName, 1)
        setmetatable(objData.Methods, {__index = superclass.Methods})
    else
        setmetatable(objData.Methods, {__index = BaseObjectSuperclass})
    end

    table.insert(ClassList, objData.ClassName)

    local metadata = {
        ClassName                   = objData.ClassName,

        Extendable                  = objData.Extendable or true,
        Superclass                  = objData.Superclass or "BaseObject",

        Methods                     = TableUtils.lock(objData.Methods), -- Methods table cannot be edited even with internal access

        Constructor                 = objData.Constructor,
        Deconstructor               = objData.Deconstructor
    }

    local classData = {
        new = function(...)
            local obj = {
                PrivateProperties       = TableUtils.deepCopy(objData.PrivateProperties or {}),
                ReadOnlyProperties      = TableUtils.deepCopy(objData.PublicReadOnlyProperties or {}),
                ReadAndWriteProperties  = TableUtils.deepCopy(objData.PublicReadAndWriteProperties or {}),
                Events                  = TableUtils.shallowCopy(objData.Events or {}),
            }

            -- Create events
            for _,eventName in pairs(obj.Events) do
                obj.Events[eventName] = BindableEvent.new()
            end

            -- Read-only properties inherited by all objects
            obj.ReadOnlyProperties.ObjectId                     = HttpService:GenerateGUID(false):sub(1, 8) -- Only use first 8 characters to save memory
            obj.ReadOnlyProperties.TickCreated                  = tick()
            obj.ReadOnlyProperties.IsDead                       = false

            -- Inherit class metadata
            setmetatable(obj.ReadOnlyProperties, {__index = metadata})

            obj = Proxy.new(
                {
                    [SymbolPrivateProperties]       = obj.PrivateProperties,
                    [SymbolReadOnlyProperties]      = obj.ReadOnlyProperties,
                    [SymbolReadAndWriteProperties]  = obj.ReadAndWriteProperties,
                    [SymbolEvents]                  = obj.Events,
                    [SymbolMethods]                 = metadata.Methods
                },
                {
                    __index                         = __index,
                    __newindex                      = __newindex,
                    __tostring                      = __tostring
                }
            )

            if objData.Constructor then
                objData.Constructor(obj, ...)
            end

            -- Due to ObjectService being moved to Cardinal this event is now how Cardinal detects when a new object is created
            NewObjectEvent:Fire(obj.Proxy)

            return obj
        end
    }

    -- Set ClassData metatable
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
            if type(v) == "function" and i ~= "Constructor" and i ~= "Deconstructor" then
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
    Output                                              = self:Load("Deus.Output")
    Proxy                                               = self:Load("Deus.Proxy")
    TableUtils                                          = self:Load("Deus.TableUtils")
    BindableEvent                                       = self:Load("Deus.BindableEvent")

    local Symbol                                        = self:Load("Deus.Symbol")
    None                                                = Symbol.new("None")
    SymbolPrivateProperties                             = Symbol.new("PrivateProperties", true)
    SymbolReadOnlyProperties                            = Symbol.new("ReadOnlyProperties", true)
    SymbolReadAndWriteProperties                        = Symbol.new("ReadAndWriteProperties", true)
    SymbolEvents                                        = Symbol.new("Events", true)
    SymbolMethods                                       = Symbol.new("Methods", true)

    BaseObjectSuperclass.SymbolPrivateProperties        = SymbolPrivateProperties
    BaseObjectSuperclass.SymbolReadOnlyProperties       = SymbolReadOnlyProperties
    BaseObjectSuperclass.SymbolReadAndWriteProperties   = SymbolReadAndWriteProperties
    BaseObjectSuperclass.SymbolEvents                   = SymbolEvents
    BaseObjectSuperclass.SymbolMethods                  = SymbolMethods

    NewClassEvent                                       = BindableEvent.new()
    NewObjectEvent                                      = BindableEvent.new()

    self.NewClass                                       = NewClassEvent.Proxy
    self.NewObject                                      = NewObjectEvent.Proxy
end

function BaseObject:init()
    BaseObjectSuperclass = self:WrapModule(script.Object, true, true)
end

return BaseObject