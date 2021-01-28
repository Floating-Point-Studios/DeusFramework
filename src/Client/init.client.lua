local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DeusSettingsModule = script.Parent.Parent:FindFirstChild("DeusSettings")
local DeusSettings
if DeusSettingsModule and DeusSettingsModule:IsA("ModuleScript") then
    DeusSettings = require(DeusSettings)
end

local Deus = require(ReplicatedStorage:WaitForChild("Deus"))(DeusSettings)

function shared.Deus()
    return Deus
end

Deus:Register(script, "Deus")

if DeusSettings.PubliclyAccessibleLoader and not DeusSettings.AttachToShared then
    shared.Deus = nil
else
    function shared.Deus()
        shared.Deus = nil
        return Deus
    end
end

--[[
if Addons then
    for _,addon in pairs(Addons:GetChildren()) do
        Deus:Register(addon)
    end
end
--]]