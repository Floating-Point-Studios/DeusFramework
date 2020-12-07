local Deus = shared.DeusFramework

local TableUtils = Deus:Load("Deus/TableUtils")

local Enumeration = {}

function Enumeration.addEnum(enumItemName, enumItemArray)
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

function Enumeration.init()
    for _,enumItem in pairs(script:GetChildren()) do
        Enumeration.addEnum(enumItem.Name, require(enumItem))
    end
end

return Enumeration