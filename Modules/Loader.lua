--!strict

local Deus = script.Parent

local DeusServer = Deus.Server
local DeusClient = Deus.Client
local DeusShared = Deus.Shared

DeusShared:Clone().Parent = DeusServer
DeusShared.Parent = DeusClient

local a = {}

return function(gameDirectory)
	local gameServer = gameDirectory.Server
	local gameClient = gameDirectory.Client
	local gameShared = gameDirectory.Shared
	
	DeusServer.Name = "Deus"
	DeusClient.Name = "Deus"
	
	DeusServer.Parent = gameServer
	DeusClient.Parent = gameClient
	
	gameShared:Clone().Parent = gameServer
	gameShared.Parent = gameClient
	
	gameServer.Parent = game:GetService("ServerScriptService")
	gameClient.Parent = game:GetService("ReplicatedFirst")
	
	Deus:Destroy()
	
	return DeusServer, DeusClient
end