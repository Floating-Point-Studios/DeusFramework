local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DeusSettingsModule = ReplicatedStorage:WaitForChild("DeusSettings")
local DeusSettings
if DeusSettingsModule and DeusSettingsModule:IsA("ModuleScript") then
    DeusSettings = require(DeusSettingsModule)
end

local Deus = require(ReplicatedStorage:WaitForChild("Deus"))
--[[
if script:IsDescendantOf(ReplicatedFirst) then
    Deus = require(ReplicatedFirst:WaitForChild("Deus"))

    if not DeusSettings then
        DeusSettings = require(Deus.Settings)
    end
else
    Deus = require(ReplicatedStorage:WaitForChild("Deus"))
end
]]

Deus:Register(script, "Deus")

if DeusSettings.AttachToShared then
    shared.Deus = Deus
end

-- TestEZ Studio-Only Test
if game:GetService("RunService"):IsStudio() then
    local Specs = ReplicatedStorage:FindFirstChild("deus-specs")
    local TestEZ = ReplicatedStorage:FindFirstChild("TestEZ")
	if Specs and TestEZ then
        TestEZ = require(TestEZ)

        local extraOptions = {
            showTimingInfo = true,
            testNamePattern = nil,
            extraEnvironment = {
                Deus = Deus
            }
        }

        TestEZ.TestBootstrap:run(Specs.Client:GetDescendants(), nil, extraOptions)
        TestEZ.TestBootstrap:run(Specs.Shared:GetDescendants(), nil, extraOptions)
    end
end

--[[
Outsourced to Cardinal

if Addons then
    for _,addon in pairs(Addons:GetChildren()) do
        Deus:Register(addon)
    end
end
]]