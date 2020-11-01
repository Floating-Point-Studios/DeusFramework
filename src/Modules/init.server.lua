local DeusServer = script.Server
local DeusClient = script.Client
local DeusShared = script.Shared

DeusShared:Clone().Parent = DeusServer
DeusShared.Parent = DeusClient

DeusServer.Parent = game:GetService("ServerScriptService")
DeusClient.Parent = game:GetService("ReplicatedFirst")

script:Destroy()