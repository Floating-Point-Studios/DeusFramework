local Deus = shared.DeusFramework

local TableProxy = Deus:Load("Deus/TableProxy")
local TableUtils = Deus:Load("Deus/TableUtils")
local Signal = Deus:Load("Deus/Signal")
local Debug = Deus:Load("Deus/Debug")
local Symbol = Deus:Load("Deus/Symbol")

local function __index(self, i, isInternalAccess)
    local internals = rawget(self, "Internals")
    local externalReadOnly = rawget(self, "ExternalReadOnly")
    local externalReadAndWrite = rawget(self, "ExternalReadAndWrite")

    local className = externalReadOnly.ClassName
    -- local superclass = externalReadOnly.Superclass

    local fallbackIndex = internals.__index

    if isInternalAccess == nil then
        isInternalAccess = TableProxy.isInternalAccess(self)
    end

    local v = internals[i]
    if v ~= nil then
        Debug.assert(isInternalAccess, "[%s] Cannot read from Internal '%s' from externally", className, i)
        return v
    end

    v = externalReadOnly.Events[i]
    if v ~= nil then
        if isInternalAccess then
            return v
        else
            return v.__proxy
        end
    end

    v = externalReadOnly.Methods[i]
    if v ~= nil then
        return v
    end

    v = externalReadAndWrite.Properties[i]
    if v ~= nil then
        return v
    end

    v = rawget(self, i)
    if v ~= nil then
        Debug.assert(isInternalAccess, "[%s] Cannot read from Internal '%s' from externally", className, i)
        return v
    end

    --[[
    v = superclass.Methods[i]
    if v ~= nil then
        return v
    end
    --]]

    local fallbackIndexType = type(fallbackIndex)
    if fallbackIndexType == "function" then
        v = fallbackIndex(self, i, isInternalAccess)
        if v ~= nil then
            return v
        end
    elseif fallbackIndexType == "table" then
        v = fallbackIndex[i]
        if v ~= nil then
            return v
        end
    end

    Debug.error(2, "[%s] Index '%s' could not be found", className, i)
end

local function __newindex(self, i, v, isInternalAccess)
    -- Symbol for nil is used as if user attempts to write to this index again while it is nil it will error
    v = v or Symbol.new("nil")

    local internals = rawget(self, "Internals")
    local externalReadOnly = rawget(self, "ExternalReadOnly")
    local externalReadAndWrite = rawget(self, "ExternalReadAndWrite")

    local events = externalReadOnly.Events
    local methods = externalReadOnly.Methods
    local properties = externalReadAndWrite.Properties
    local className = externalReadOnly.ClassName

    local fallbackNewIndex = internals.__newindex

    if isInternalAccess == nil then
        isInternalAccess = TableProxy.isInternalAccess(self)
    end

    if internals[i] ~= nil then
        Debug.assert(isInternalAccess, "[%s] Cannot write to Internal '%s' from externally", className, i)
        internals[i] = v
        return true
    end

    -- Events shouldn't ever need to be written to but internal has permission to anyway
    if events[i] ~= nil then
        Debug.assert(isInternalAccess, "[%s] Cannot write to Event '%s' from externally", className, i)
        events[i] = v
        return true
    end

    if methods[i] ~= nil then
        Debug.assert(isInternalAccess, "[%s] Cannot write to Method '%s' from externally", className, i)
        methods[i] = v
        return true
    end

    if properties[i] ~= nil then
        properties[i] = v
        return true
    end

    if rawget(self, i) ~= nil then
        Debug.assert(isInternalAccess, "[%s] Cannot write to index '%s' from externally", className, i)
        rawset(self, i, v)
        return true
    end

    local fallbackNewIndexType = type(fallbackNewIndex)
    if fallbackNewIndexType == "function" then
        if fallbackNewIndex(self, i, v, isInternalAccess) then
            return true
        end
    elseif fallbackNewIndexType == "table" then
        if fallbackNewIndex[i] then
            fallbackNewIndex[i] = v
            return true
        end
    end

    Debug.error(2, "[%s] Index '%s' could not be found", className, i)
end

local function __tostring(self)
    return self.ClassName
end

local BaseClass = {}

function BaseClass.new(classData)
    local className = classData.ClassName or "Deus/UnnamedObject"
    local superclass = classData.Superclass
    local constructor = classData.Constructor

    classData.Events = classData.Events or {}
    classData.Internals = classData.Internals or {}
    classData.Methods = classData.Methods or {}
    classData.Properties = classData.Properties or {}

    if superclass then
        TableUtils.merge(classData.Events, superclass.Events)
        TableUtils.merge(classData.Internals, superclass.Internals)
        TableUtils.merge(classData.Methods, superclass.Methods)
        TableUtils.merge(classData.Properties, superclass.Properties)
    end

    function classData.new(...)
        local self, metatable = TableProxy.new(
            {
                __index = __index;
                __newindex = __newindex;

                Internals = TableUtils.shallowCopy(classData.Internals);

                ExternalReadOnly = {
                    ClassName = className;
                    Superclass = superclass;

                    Events = {};
                    Methods = classData.Methods;
                };

                ExternalReadAndWrite = {
                    Properties = TableUtils.shallowCopy(classData.Properties);
                };
            }
        )

        rawset(metatable, "__tostring", __tostring)
        rawset(metatable, "__proxy", self)

        for _,eventName in pairs(classData.Events) do
            local _,signalMetatable = Signal.new()
            metatable.ExternalReadOnly.Events[eventName] = signalMetatable
        end

        -- Wrapper to allow internal access to the functions
        for methodName, method in pairs(classData.Methods) do
            metatable.ExternalReadOnly.Methods[methodName] = function(...)
                method(metatable, TableUtils.sub({...}, 2))
            end
        end

        if constructor then
            constructor(metatable, ...)
        end

        setmetatable(metatable,
            {
                __index = __index;
                __newindex = __newindex;
            }
        )

        return self
    end

    function classData:Extend(classData)
        classData.Superclass = self
        return BaseClass.new(classData)
    end

    return setmetatable(classData, {__index = BaseClass})
end

return BaseClass