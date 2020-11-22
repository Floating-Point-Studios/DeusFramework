-- Based on RoStrap

local Deus = shared.DeusFramework

local TableProxy = Deus:Load("Deus/TableProxy")
local TableUtils = Deus:Load("Deus/TableUtils")
local Signal = Deus:Load("Deus/Signal")
local Debug = Deus:Load("Deus/Debug")

local function __index(self, i)
    local isInternalAccess, metatable = TableProxy.isInternalAccess(self)

    local events = metatable.__externals.Events
    local internals = metatable.__internals
    local methods = metatable.__externals.Methods
    local properties = metatable.__externals.Properties
    local superclass = metatable.__internals.Superclass

    local v = events[i] or methods[i] or properties[i]
    if v then
        return v
    end

    v = internals[i]
    if v then
        Debug.assert(isInternalAccess, "[%s] Cannot read Internal '%s' from externally", internals.ClassName, i)
        return v
    end

    if superclass then
        return superclass[i]
    end
end

local function __newindex(self, i, v)
    local isInternalAccess, metatable = TableProxy.isInternalAccess(self)

    local events = metatable.__externals.Events
    local internals = metatable.__internals
    local methods = metatable.__externals.Methods
    local properties = metatable.__externals.Properties

    if events[i] then
        Debug.assert(isInternalAccess, "[%s] Cannot write to Event '%s' from externally", internals.ClassName, i)
        events[i] = v
    elseif internals[i] then
        Debug.assert(isInternalAccess, "[%s] Cannot write to Internal '%s' from externally", internals.ClassName, i)
        internals[i] = v
    elseif methods[i] then
        Debug.assert(isInternalAccess, "[%s] Cannot write Method '%s' from externally", internals.ClassName, i)
        methods[i] = v
    elseif properties[i] then
        properties[i] = v
    else
        Debug.error(2, "[%s] Index '%s' was not found", self.Internals.ClassName, i)
    end
end

local function __tostring(self)
    local _,metatable = TableProxy.isInternalAccess(self)
    return metatable.__internals.ClassName
end

local BaseClass = {}

function BaseClass.new(className, classData, superclass)
    if superclass then
        TableUtils.merge(classData.Events, superclass.Events)
        TableUtils.merge(classData.Internals, superclass.Internals)
        TableUtils.merge(classData.Methods, superclass.Methods)
        TableUtils.merge(classData.Properties, superclass.Properties)
    end

    classData.Internals.ClassName = className
    classData.Internals.Superclass = superclass

    function classData.new()
        local self, metatable = TableProxy.new(
            TableUtils.shallowCopy(classData.Internals),
            {
                Events = {};
                Methods = {};
                Properties = TableUtils.shallowCopy(classData.Properties);
            }
        )

        metatable.__index = __index
        metatable.__newindex = __newindex
        metatable.__tostring = __tostring

        setmetatable(metatable,
            {
                __index = __index;
                __newindex = __newindex;
            }
        )

        for _,eventName in pairs(classData.Events) do
            metatable.__externals.Events[eventName] = Signal.new()
        end

        -- Wrapper to allow internal access to the functions
        for methodName, method in pairs(classData.Methods) do
            metatable.__externals.Methods[methodName] = function(...)
                method(metatable, ...)
            end
        end

        return self
    end

    return setmetatable(classData, {__index = BaseClass})
end

return BaseClass