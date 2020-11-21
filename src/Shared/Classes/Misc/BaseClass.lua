-- Based on RoStrap

local Deus = shared.DeusFramework

local TableUtils = Deus:Load("Deus/TableUtils")
local Signal = Deus:Load("Deus/Signal")
local Debug = Deus:Load("Deus/Debug")

local Metatables = setmetatable({}, {__mode = "kv"})

local function filter(self)
    local internalAccess = false
    local metatable = Metatables[self]
    if not metatable then
        internalAccess = true
    end
    return internalAccess, metatable or self
end

local function __index(self, i)
    local internalAccess, self = filter(self)

    local v = self.Events[i] or self.Methods[i] or self.Properties[i]
    if v then
        return v
    else
        v = self.Internals[i]
        if v then
            Debug.assert(internalAccess, "[%s] Cannot read Internal '%s' from externally", self.Internals.ClassName, i)
            return v
        end
    end

    if self.__superclass then
        return self.__superclass[i]
    end
end

local function __newindex(self, i, v)
    local internalAccess, self = filter(self)

    if self.Events[i] then
        Debug.assert(internalAccess, "[%s] Cannot write to Event '%s' from externally", self.Internals.ClassName, i)
        self.Events[i] = v
    elseif self.Internals[i] then
        Debug.assert(internalAccess, "[%s] Cannot write to Internal '%s' from externally", self.Internals.ClassName, i)
        self.Internals[i] = v
    elseif self.Methods[i] then
        Debug.assert(internalAccess, "[%s] Cannot write Method '%s' from externally", self.Internals.ClassName, i)
        self.Methods[i] = v
    elseif self.Properties[i] then
        self.Properties[i] = v
    else
        Debug.error(2, "[%s] Index '%s' was not found", self.Internals.ClassName, i)
    end
end

local function __tostring(self)
    local _,self = filter(self)
    return self.Internals.ClassName
end

local BaseClass = {}

function BaseClass.new(className, classData, superclass)
    classData.ClassName = className
    classData.Superclass = superclass

    if superclass then
        TableUtils.merge(classData.Events, superclass.Events)
        TableUtils.merge(classData.Internals, superclass.Internals)
        TableUtils.merge(classData.Methods, superclass.Methods)
        TableUtils.merge(classData.Properties, superclass.Properties)
    end

    function classData.new()
        local self = newproxy(true)
        local metatable = getmetatable(self)

        metatable.__index = __index
        metatable.__newindex = __newindex
        metatable.__tostring = __tostring
        metatable.__metatable = ("[%s] Locked metatable"):format(classData.ClassName)

        metatable.__class = {
            Events = {};
            Internals = classData.Internals;
            Methods = classData.Methods;
            Properties = TableUtils.shallowCopy(classData.Properties)
        }
        metatable.__superclass = classData.Superclass

        for _,eventName in pairs(classData.Events) do
            metatable.__class.Events[eventName] = Signal.new()
        end

        Metatables[self] = metatable

        return self
    end

    return TableUtils.lock(setmetatable(classData, {__index = BaseClass}))
end

return BaseClass