local Output
local TableUtils

local Enums = {}
local CustomEnum = require(script.Enum)

local Enumeration = {}

Enumeration.__index = function(_, i)
    local v

    v = Enums[i]
    if v then
        return TableUtils.deepCopy(v)
    end

    return rawget(Enumeration, i)
end

function Enumeration.addEnumItem(enumName, enumItemName, value)
    Output.assert(not Enums[enumName][enumItemName], "EnumItem name '%s' already in use", enumName, 1)

    local enum = CustomEnum.new(enumItemName, enumName, value)
    Enums[enumName][enumItemName] = enum
    return enum
end

function Enumeration.addEnum(enumName, list)
    Output.assert(not Enums[enumName], "Enum name '%s' already in use", enumName, 1)
    Output.assert(not Enumeration[enumName], "Enum name '%s' is reserved", enumName, 1)

    Enums[enumName] = {}

    for i,v in pairs(list) do
        Enumeration.addEnumItem(enumName, i, v)
    end

    Enumeration[enumName] = TableUtils.lock(Enums[enumName])

    return Enums[enumName]
end

function Enumeration.waitForEnum(enumName)
    local waitStart = tick()
    repeat wait() until Enums[enumName] or tick() - waitStart > 3

    local enum = Enums[enumName]
    Output.assert(enum, "Enum name '%s' could not be found", enumName, 1)
    return enum
end

Enumeration.add     = Enumeration.addEnum
Enumeration.addItem = Enumeration.addItem
Enumeration.wait    = Enumeration.waitForEnum

function Enumeration:start()
    Output = self:Load("Deus.Output")
    TableUtils = self:Load("Deus.TableUtils")
end

return setmetatable(Enumeration, Enumeration)