local CustomEnum = {}

local function __tostring(self)
    return ("Deus.Enumeration.%s.%s"):format(self.EnumType, self.Name)
end

function CustomEnum.new(enumItemName, enumType, enumValue)
    local enum = newproxy(true)
    local meta = getmetatable(enum)

    meta.__metatable = "[Enumeration] Locked metatable"
    meta.__tostring = __tostring
    meta.__index = {
        Name = enumItemName,
        EnumType = enumType,
        Value = enumValue
    }

    return enum
end

return CustomEnum