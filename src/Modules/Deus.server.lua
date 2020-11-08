local DeusServer = script.Parent.Server
local DeusClient = script.Parent.Client
local DeusShared = script.Parent.Shared

DeusShared:Clone().Parent = DeusServer
DeusShared.Parent = DeusClient

DeusServer.Parent = game:GetService("ServerScriptService")
DeusClient.Parent = game:GetService("ReplicatedFirst")

script:Destroy()