local BaseEnum = {}

function BaseEnum.new(enumArray)
    for i,v in pairs(enumArray) do
        if type(v) == "table" then

            BaseEnum.new(v)

        else

            local enum = newproxy(true)
            local metatable = getmetatable(enum)

            metatable.__metatable = "[EnumItem] Locked metatable"

            metatable.__name = i
            metatable.__value = v

            enumArray[i] = enum

        end
    end

    return enumArray
end

return BaseEnum