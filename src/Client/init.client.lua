local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DeusSettingsModule = ReplicatedStorage:WaitForChild("DeusSettings")
local DeusSettings
if DeusSettingsModule and DeusSettingsModule:IsA("ModuleScript") then
    DeusSettings = require(DeusSettingsModule)
end

local Deus = require(ReplicatedStorage:WaitForChild("Deus"))

Deus:Register(script, "Deus")

if not DeusSettings.AttachToShared then
    shared.Deus = nil
end

--[[
if Addons then
    for _,addon in pairs(Addons:GetChildren()) do
        Deus:Register(addon)
    end
end
]]