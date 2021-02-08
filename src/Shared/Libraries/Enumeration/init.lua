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
    Enums[enumName][enumItemName] = CustomEnum.new(enumItemName, enumName, value)
end

function Enumeration.addEnum(enumName, list)
    Output.assert(not Enums[enumName], "Enum name '%s' already in use", enumName)

    Enums[enumName] = {}

    for i,v in pairs(list) do
        Enumeration.addEnumItem(enumName, i, v)
    end

    return Enums[enumName]
end

function Enumeration.waitForEnum(enumName)
    local waitStart = tick()
    repeat wait() until Enums[enumName] or tick() - waitStart > 3

    local enum = Enums[enumName]
    Output.assert(enum, "Enum name '%s' could not be found", enumName)
    return enum
end

function Enumeration.start()
    Output = Enumeration:Load("Deus.Output")
    TableUtils = Enumeration:Load("Deus.TableUtils")
end

return setmetatable(Enumeration, Enumeration)