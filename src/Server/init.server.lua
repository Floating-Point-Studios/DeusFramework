local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- Setup server
local DeusCore = script.Parent.Deus
DeusCore.Parent = ReplicatedStorage

local Deus = require(DeusCore)
Deus:Register(script, "Deus")
Deus:Register(script.Parent.Shared, "Deus")

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

if ServerConfig then
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
            elseif addon:IsA("Script") then
                addon = addon:Clone()
                addon.Parent = ServerScriptService
                addon.Disabled = false
            elseif addon:IsA("LocalScript") then
                addon.Parent = ReplicatedFirst
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

-- Setup client

script.Parent.Client.Parent = ReplicatedFirst