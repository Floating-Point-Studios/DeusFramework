local HttpService = game:GetService("HttpService")

local Output
local Proxy
local TableUtils
local BindableEvent

-- Symbols
local None
local SymbolPrivateProps
local SymbolReadableProps
local SymbolWritableProps
local SymbolEvents
local SymbolMethods

local NewClassEvent
local NewObjectEvent
local BaseObjectSuperclass

local ClassList = {}
local ObjectMetatables = setmetatable({}, {__mode = "kv"})

function __tostring(self)
    return ("[DeusObject] [%s] [%s]"):format(self.ClassName, self.ObjectId)
end

function __index(self, i)
    local internalAccess = type(self) == "table"
    local v

    local PrivateProps  = self[SymbolPrivateProps]
    local ReadableProps = self[SymbolReadableProps]
    local WritableProps = self[SymbolWritableProps]
    local Events        = self[SymbolEvents]
    local Methods       = self[SymbolMethods]

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

    v = PrivateProps[i]
    if v ~= nil then
        Output.assert(internalAccess, "[DeusObject] [%s] Attempt to read internal property", ReadableProps.ClassName, 1)
        if v == None then
            return nil
        else
            return v
        end
    end

    v = ReadableProps[i]
    if v ~= nil then
        if v == None then
            return nil
        else
            return v
        end
    end

    v = WritableProps[i]
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
    local internalAccess = type(self) == "table"
    local oldv
    if v == nil then
        v = None
    end

    local PrivateProps  = self[SymbolPrivateProps]
    local ReadableProps = self[SymbolReadableProps]
    local WritableProps = self[SymbolWritableProps]
    local Events        = self[SymbolEvents]

    if Events[i] ~= nil then
        Output.error("Events cannot be modified after object creation", nil, 1)
        return false
    end

    local translator = self.Translator

    oldv = PrivateProps[i]
    if oldv ~= nil then
        Output.assert(internalAccess, "[DeusObject] [%s] Attempt to modify internal property", ReadableProps.ClassName, 1)

        PrivateProps[i] = v

        if translator then
            if translator(ObjectMetatables[self] or self, i, v, oldv) == false then
                PrivateProps[i] = oldv
            end
        end

        return true
    end

    oldv = ReadableProps[i]
    if oldv ~= nil then
        Output.assert(internalAccess, "[DeusObject] [%s] Attempt to modify read-only property", ReadableProps.ClassName, 1)

        ReadableProps[i] = v

        if translator then
            if translator(ObjectMetatables[self] or self, i, v, oldv) == false then
                PrivateProps[i] = oldv
            end
        end

        return true
    end

    oldv = WritableProps[i]
    if oldv ~= nil then
        WritableProps[i] = v

        if translator then
            if translator(ObjectMetatables[self] or self, i, v, oldv) == false then
                PrivateProps[i] = oldv
            end
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
            if type(v) == "function" and i ~= "Constructor" and i ~= "Destructor" and i ~= "Translator" then
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
        ClassName   = objData.ClassName,

        Extendable  = objData.Extendable or true,
        Superclass  = objData.Superclass or "BaseObject",

        Methods     = TableUtils.lock(objData.Methods), -- Methods table cannot be edited even with internal access

        Constructor = objData.Constructor,
        Destructor  = objData.Destructor or objData.Deconstructor, -- Backwards compatability
        Translator  = objData.Translator
    }

    local classData = {
        new = function(...)
            local obj = {
                -- Backwards compatability
                Private     = TableUtils.deepCopy(objData.Private or objData.PrivateProperties or {}),
                Readable    = TableUtils.deepCopy(objData.Readable or objData.PublicReadOnlyProperties or {}),
                Writable    = TableUtils.deepCopy(objData.Writable or objData.PublicReadAndWriteProperties or {}),
                Events      = TableUtils.shallowCopy(objData.Events or {}),
            }

            -- Create events
            for _,eventName in pairs(obj.Events) do
                obj.Events[eventName] = BindableEvent.new()
            end

            -- Read-only properties inherited by all objects
            obj.Readable.ObjectId           = HttpService:GenerateGUID(false):sub(1, 8) -- Only use first 8 characters to save memory
            obj.Readable.TickCreated        = tick()
            obj.Readable.Alive              = true

            -- Inherit class metadata
            setmetatable(obj.Readable, {__index = metadata})

            obj = Proxy.new(
                {
                    [SymbolPrivateProps]    = obj.Private,
                    [SymbolReadableProps]   = obj.Readable,
                    [SymbolWritableProps]   = obj.Writable,
                    [SymbolEvents]          = obj.Events,
                    [SymbolMethods]         = metadata.Methods
                },
                {
                    __index                 = __index,
                    __newindex              = __newindex,
                    __tostring              = __tostring
                }
            )

            if objData.Constructor then
                objData.Constructor(obj, ...)
            end

            ObjectMetatables[obj.Proxy] = obj

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
        ClassName   = objData.ClassName,
        Superclass  = objData.Superclass,
        Methods     = {},
        Writable    = {},
        Constructor = objData.Constructor,
        Destructor  = objData.Destructor or objData.Deconstructor, -- Backwards compatability
        Translator  = objData.Translator
    }

    for i,v in pairs(objData) do
        -- Check the index isn't a object configuration
        if not parsedObjData[i] then
            -- Check if index is a method or property
            if type(v) == "function" and i ~= "Constructor" and i ~= "Destructor" and i ~= "Translator" then
                parsedObjData.Methods[i] = v
            else
                parsedObjData.Writable[i] = v
            end
        end
    end

    return BaseObject.new(parsedObjData)
end

function BaseObject.getClassList()
    return TableUtils.shallowCopy(ClassList)
end

function BaseObject:start()
    Output                      = self:Load("Deus.Output")
    Proxy                       = self:Load("Deus.Proxy")
    TableUtils                  = self:Load("Deus.TableUtils")
    BindableEvent               = self:Load("Deus.BindableEvent")

    local Symbol                = self:Load("Deus.Symbol")
    None                        = Symbol.get("None")
    SymbolPrivateProps          = Symbol.new("PrivateProps")
    SymbolReadableProps         = Symbol.new("ReadableProps")
    SymbolWritableProps         = Symbol.new("WritableProps")
    SymbolEvents                = Symbol.new("Events")
    SymbolMethods               = Symbol.new("Methods")

    BaseObjectSuperclass = self:WrapModule(
        script.Object,
        true,
        true,
        {
            SymbolPrivateProps  = SymbolPrivateProps,
            SymbolReadableProps = SymbolReadableProps,
            SymbolWritableProps = SymbolWritableProps,
            SymbolEvents        = SymbolEvents,
            SymbolMethods       = SymbolMethods,
            ObjectMetatables    = ObjectMetatables
        }
    )

    NewClassEvent               = BindableEvent.new()
    NewObjectEvent              = BindableEvent.new()

    self.NewClass               = NewClassEvent.Proxy
    self.NewObject              = NewObjectEvent.Proxy
end

return BaseObject