local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Deus = require(ReplicatedStorage:WaitForChild("Deus"))

Deus:Register(script, "Deus")

local DeusConfig = ReplicatedStorage:WaitForChild("DeusConfig")

local DeusSettings = DeusConfig:FindFirstChild("Settings")
local Addons = DeusConfig:FindFirstChild("Addons")

if DeusSettings then
    Deus:SetSettings(DeusSettings)
end

if Addons then
    for _,addon in pairs(Addons:GetChildren()) do
        Deus:Register(addon)
    end
end