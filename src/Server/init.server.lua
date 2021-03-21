local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Setup server
local DeusCore = script.Parent.Deus

local DeusSettingsModule = script.Parent.Parent:FindFirstChild("DeusSettings")
local DeusSettings
if DeusSettingsModule and DeusSettingsModule:IsA("ModuleScript") then
    DeusSettings = require(DeusSettingsModule)
else
    DeusSettingsModule = DeusCore.Settings
    DeusSettings = require(DeusSettingsModule)
end

local Deus = require(DeusCore)

Deus:Register(script, "Deus")
Deus:Register(script.Parent.Shared, "Deus")

if Deus:IsPluginFramework() then
    -- We're a plugin so don't reparent stuff

    -- Server, client, and shared all run when used as plugin framework
    Deus:Register(script.Parent.Client, "Deus")
else
    if DeusSettings.AttachToShared then
        shared.Deus = Deus
    end

    DeusSettingsModule = DeusSettingsModule:Clone()
    DeusSettingsModule.Parent = ReplicatedStorage
    DeusSettingsModule.Name = "DeusSettings"

    -- Setup client
    local Client = script.Parent.Client
    script.Parent.Shared:Clone().Parent = Client

    Client.Parent = ReplicatedFirst
    DeusCore.Parent = ReplicatedStorage

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

            TestEZ.TestBootstrap:run(Specs.Server:GetDescendants(), nil, extraOptions)
            TestEZ.TestBootstrap:run(Specs.Shared:GetDescendants(), nil, extraOptions)
        end
    end
end