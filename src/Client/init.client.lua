local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DeusSettingsModule = ReplicatedStorage:WaitForChild("DeusSettings")
local DeusSettings
if DeusSettingsModule and DeusSettingsModule:IsA("ModuleScript") then
    DeusSettings = require(DeusSettingsModule)
end

local Deus = require(ReplicatedStorage:WaitForChild("Deus"))(DeusSettings)

function shared.Deus()
    return Deus
end

Deus:Register(script, "Deus")

if not DeusSettings.AttachToShared then
    if DeusSettings.PubliclyAccessibleLoader then
        shared.Deus = nil
    else
        function shared.Deus()
            shared.Deus = nil
            return Deus
        end
    end
end

--[[
if Addons then
    for _,addon in pairs(Addons:GetChildren()) do
        Deus:Register(addon)
    end
end
]]