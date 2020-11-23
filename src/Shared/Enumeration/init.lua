local Deus = shared.DeusFramework

local TableUtils = Deus:Load("Deus/TableUtils")
local Debugging = Deus:Load("Deus/Debug")

local Enumeration = {}

function Enumeration.getEnum(str)
    for _,enumItemArray in pairs(Enumeration) do
        local v = enumItemArray[str]
        if v then
            return v
        end
    end
    Debugging.error(2, "[Enum] Enumeration '%s' was not found", str)
end

function Enumeration.init()
    for _,enumItem in pairs(script:GetChildren()) do
        local enumItemName = enumItem.Name
        local enumItemArray = require(enumItem)

        for i,v in pairs(enumItemArray) do
            enumItemArray[i] = TableUtils.lock(
                {
                    Name = i;
                    Value = v;
                    EnumType = enumItemArray;
                }
            )
        end

        Enumeration[enumItemName] = enumItemArray
    end
end

return Enumeration