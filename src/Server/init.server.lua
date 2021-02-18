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

if DeusSettings.AttachToShared then
    shared.Deus = Deus
end

--[[
local InstanceUtils = Deus:Load("Deus.InstanceUtils")

-- Setup client config
local ServerConfig = ServerStorage:FindFirstChild("DeusConfig")
local ClientConfig = InstanceUtils.make(
    {
        "Folder",
        {
            Name = "DeusConfig"
        },
        nil,
        {
            "Folder",
            {
                Name = "Addons"
            }
        }
    }
)
]]

--[[
if DeusSettingsModule then
    Outsourced to CardinalEngine

    local deusSettings = ServerConfig:FindFirstChild("Settings")
    if deusSettings then
        deusSettings:Clone().Parent = ClientConfig
        Deus:SetSettings(deusSettings)
    end

    local addons = ServerConfig:FindFirstChild("Addons")
    if addons then
        for _,addon in pairs(addons:GetChildren()) do
            if addon:IsA("ModuleScript") then
                addon:Clone().Parent = ClientConfig.Addons
                Deus:Register(addon)
            elseif addon:IsA("LocalScript") then
                addon.Parent = ReplicatedFirst
                addon.Disabled = false
            elseif addon:IsA("Script") then
                addon = addon:Clone()
                addon.Parent = ServerScriptService
                addon.Disabled = false
            else
                local serverAddon = InstanceUtils.findFirstChildNoCase(addon, "server")
                local clientAddon = InstanceUtils.findFirstChildNoCase(addon, "client")
                local sharedAddon = InstanceUtils.findFirstChildNoCase(addon, "shared")

                local finalizedAddon
                if clientAddon or sharedAddon then
                    finalizedAddon = InstanceUtils.make(
                        {
                            "Folder",
                            {
                                Name = addon.Name
                            },
                            ClientConfig.Addons
                        }
                    )
                end

                if serverAddon then
                    Deus:Register(serverAddon)
                end

                if clientAddon then
                    clientAddon:Clone().Parent = ReplicatedFirst
                end

                if sharedAddon then
                    sharedAddon:Clone().Parent = finalizedAddon
                    Deus:Register(sharedAddon)
                end
            end
        end
    end
    ClientConfig.Parent = ReplicatedStorage
end
]]

DeusSettingsModule = DeusSettingsModule:Clone()
DeusSettingsModule.Parent = ReplicatedStorage
DeusSettingsModule.Name = "DeusSettings"

-- Setup client
local Client = script.Parent.Client
script.Parent.Shared:Clone().Parent = Client

Client.Parent = ReplicatedFirst
DeusCore.Parent = ReplicatedStorage