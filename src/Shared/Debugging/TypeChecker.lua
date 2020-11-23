local Enumeration = shared.DeusFramework:Load("Deus/Enumeration")

local DataTypes = Enumeration.DataTypes

local TypeChecker = {}

function TypeChecker.typeof(potentialType)
    local RBXType = type(potentialType)
    if RBXType == "nil" then

    elseif RBXType == "boolean" then

    elseif RBXType == "number" then
        if potentialType % 0 == 0 then
            -- Integer
            if potentialType > 0 then

            else

            end
        else
            -- Number (float)
            if potentialType > 0 then

            else
                
            end
        end
    elseif RBXType == "string" then

    elseif RBXType == "userdata" then

    elseif RBXType == "function" then

    elseif RBXType == "thread" then

    elseif RBXType == "table" then

    end
end

function TypeChecker.check(potentialType, acceptedTypes)
    
end

return TypeChecker