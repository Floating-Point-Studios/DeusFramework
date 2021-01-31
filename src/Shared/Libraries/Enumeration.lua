local Deus = shared.Deus()

local Output = Deus:Load("Deus.Output")
local TableUtils = Deus:Load("Deus.TableUtils")

local function __tostring(self)
    return ("Deus.Enumeration.%s.%s"):format(self.EnumType, self.Name)
end

local Enumeration = {}

Enumeration.__index = function(self, i)
    local v = rawget(Enumeration, i)
    if type(v) == "table" then
        return TableUtils.deepCopy(v)
    else
        return v
    end
end

function Enumeration.addEnumItem(enumName, enumItemName, value)
    local enum = Enumeration[enumName]
    local proxy = newproxy(true)
    local meta = getmetatable(proxy)

    meta.__metatable = "[Enumeration] Locked metatable"
    meta.__tostring = __tostring

    meta.Name = enumItemName
    meta.Value = value
    meta.EnumType = enumName

    enum[enumItemName] = proxy
    Enumeration[enumName] = enum

    return proxy
end

function Enumeration.addEnum(enumName, list)
    Output.assert(not Enumeration[enumName], "Name for enum '%s' is already in use", enumName)
    Enumeration[enumName] = {}

    for enumItemName, value in pairs(list) do
        Enumeration.addEnumItem(enumName, enumItemName, value)
    end

    return TableUtils.deepCopy(Enumeration[enumName])
end

return setmetatable(Enumeration, Enumeration)