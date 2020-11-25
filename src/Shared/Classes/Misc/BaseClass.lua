local Deus = shared.DeusFramework

local TableProxy = Deus:Load("Deus/TableProxy")
local TableUtils = Deus:Load("Deus/TableUtils")
local Signal = Deus:Load("Deus/Signal")
local Debug = Deus:Load("Deus/Debug")
local TypeChecker = Deus:Load("Deus/TypeChecker")

local function __index(self, i, isInternalAccess)
    local internals = rawget(self, "__internals")
    local externalReadOnly = rawget(self, "__externalReadOnly")
    local externalReadAndWrite = rawget(self, "__externalReadAndWrite")

    local className = externalReadOnly.ClassName
    local superclass = externalReadOnly.Superclass

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

    v = superclass[i]
    if v ~= nil then
        return v
    end

    if type(fallbackIndex) == "function" then
        v = fallbackIndex(self, i, isInternalAccess)
        if v ~= nil then
            return v
        end
    elseif type(fallbackIndex) == "table" then
        v = fallbackIndex[i]
        if v ~= nil then
            return v
        end
    end

    Debug.error(2, "[%s] Index '%s' could not be found", className, i)
end

local function __newindex(self, i, v, isInternalAccess)
    local internals = rawget(self, "__internals")
    local externalReadOnly = rawget(self, "__externalReadOnly")
    local externalReadAndWrite = rawget(self, "__externalReadAndWrite")

    local events = externalReadOnly.Events
    local methods = externalReadOnly.Methods
    local properties = externalReadAndWrite.Properties
    local className = externalReadOnly.ClassName

    local fallbackNewIndex = internals.__newindex

    if isInternalAccess == nil then
        isInternalAccess = TableProxy.isInternalAccess(self)
    end

    if internals[i] then
        Debug.assert(isInternalAccess, "[%s] Cannot write to Internal '%s' from externally", className, i)
        internals[i] = v
        return
    end

    -- Events shouldn't ever need to be written to but internal has permission to anyway
    if events[i] then
        Debug.assert(isInternalAccess, "[%s] Cannot write to Event '%s' from externally", className, i)
        events[i] = v
        return
    end

    if methods[i] then
        Debug.assert(isInternalAccess, "[%s] Cannot write to Method '%s' from externally", className, i)
        methods[i] = v
        return
    end

    if properties[i] then
        properties[i] = v
        return
    end

    if type(fallbackNewIndex) == "function" then
        if fallbackNewIndex(self, i, isInternalAccess) then
            return
        end
    elseif type(fallbackNewIndex) == "table" then
        if fallbackNewIndex[i] then
            fallbackNewIndex[i] = v
            return
        end
    end

    Debug.error(2, "[%s] Index '%s' could not be found", className, i)
end

local function __tostring(self)
    return self.ClassName
end

local BaseClass = {}

function BaseClass.new(className, classData, superclass)
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

    function classData.new()
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

        for _,eventName in pairs(classData.Events) do
            local _,signalMetatable = Signal.new()
            metatable.__externalReadOnly.Events[eventName] = signalMetatable
        end

        -- Wrapper to allow internal access to the functions
        for methodName, method in pairs(classData.Methods) do
            metatable.__externalReadOnly.Methods[methodName] = function(...)
                method(metatable, ...)
            end
        end

        if constructor then
            constructor(metatable)
        end

        setmetatable(metatable,
            {
                __index = __index;
                __newindex = __newindex;
            }
        )

        return self
    end

    return setmetatable(classData, {__index = BaseClass})
end

return BaseClass