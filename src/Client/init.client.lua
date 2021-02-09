local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DeusSettingsModule = ReplicatedStorage:WaitForChild("DeusSettings")
local DeusSettings
if DeusSettingsModule and DeusSettingsModule:IsA("ModuleScript") then
    DeusSettings = require(DeusSettingsModule)
end

local Deus
if script:IsDescendantOf(ReplicatedFirst) then
    Deus = require(script.Parent)
else
    Deus = require(ReplicatedStorage:WaitForChild("Deus"))
end

Deus:Register(script, "Deus")

if DeusSettings.AttachToShared then
    shared.Deus = Deus
end

--[[
Outsourced to Cardinal

if Addons then
    for _,addon in pairs(Addons:GetChildren()) do
        Deus:Register(addon)
    end
end
]]