--!strict

local require = shared.DeusHook()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local Debugger = require("Debugger")
local EventDecoder = require("EventDecoderServer")
local RemoteEvent = require("RemoteEvent")
local RemoteFunction = require("RemoteFunction")

local EventList
local Remotes = {}
local Seeds = {}

local Network = {}

function Network.CreateRemoteEvent(RemoteName)
	local Remote = INSTANCE("RemoteEvent", RemoteName, nil, EventList)
	Remotes[RemoteName] = Remote
	local Signal = INSTANCE("Signal", nil, nil, nil)
	Network[RemoteName] = Signal
	Remote.OnServerEvent:connect(function(Player, Package)
		if Package == "SECCOMP" then
			Debugger.print("Exploiter Detected: ".. Player.Name)
		else
			local Data = Seeds[Player]
			Data.Events[Remote.Name].Seed = (Data.Events[Remote.Name].Seed + 1) % 1000
			local Args = DECRYPT(Data.Key, Data.Events[Remote.Name].Seed, Package)
			Signal:Fire(RemoteName, Player, unpack(Args))
		end
	end)
end

function Network.CreateRemoteFunction(RemoteName)
	local Remote = INSTANCE("RemoteFunction", RemoteName, nil, EventList)
	Remotes[RemoteName] = Remote
	local Signal = INSTANCE("Signal", nil, nil, nil)
	Network[RemoteName] = Signal
	function Remote.OnServerInvoke(Player, Package)
		if Package == "SECCOMP" then
			Debugger.print("Exploiter Detected: ".. Player.Name)
		else
			local Data = Seeds[Player]
			Data.Events[Remote.Name].Seed = (Data.Events[Remote.Name].Seed + 1) % 1000
			local Args = DECRYPT(Data.Key, Data.Events[Remote.Name].Seed, Package)
			return Signal:Fire(RemoteName, Player, unpack(Args))
		end
	end
end

function Network.FireClient(RemoteName, Player, ...)
	Remotes[RemoteName]:FireClient(Player, ...)
end

function Network.FireAllClients(RemoteName, ...)
	for _,Player in pairs(Players:GetPlayers()) do
		Remotes[RemoteName]:FireClient(Player, ...)
	end
end

function Network.FireAllOtherClients(RemoteName, IgnorePlayer, ...)
	for _,Player in pairs(Players:GetPlayers()) do
		if Player ~= IgnorePlayer then
			Remotes[RemoteName]:FireClient(Player, ...)
		end
	end
end

function Network.FireAllNearbyClients(RemoteName, Pos, Distance, ...)
	local Args = {...}
	for _,Player in pairs(Players:GetPlayers()) do
		pcall(function()
			if (Player.Character.HumanoidRootPart.Position - Pos).Magnitude < Distance then
				Remotes[RemoteName]:FireClient(Player, unpack(Args))
			end
		end)
	end
end

function Network.FireAllOtherNearbyClients(RemoteName, Pos, Distance, IgnorePlayer, ...)
	local Args = {...}
	for _,Player in pairs(Players:GetPlayers()) do
		if Player ~= IgnorePlayer then
			pcall(function()
				if (Player.Character.HumanoidRootPart.Position - Pos).Magnitude < Distance then
					Remotes[RemoteName]:FireClient(Player, unpack(Args))
				end
			end)
		end
	end
end

function Network.InvokeClient(RemoteName, Player, ...)
	return unpack(DECRYPT(Remotes[RemoteName]:FireClient(Player, ...)))
end

function Network.InvokeAllClients(RemoteName, ...)
	local PlayerReturns = {}
	for _,Player in pairs(Players:GetPlayers()) do
		PlayerReturns[Player] = DECRYPT(Remotes[RemoteName]:FireClient(Player, ...))
	end
	return PlayerReturns
end

function Network.Init()
	INSTANCE = Mainframe.Util.SmartInstance.new
	ENCRYPT = Mainframe.Util.Encoder.Encrypt
	DECRYPT = Mainframe.Util.Encoder.Decrypt
	
	EventList = INSTANCE("Folder", "Events", nil, ReplicatedStorage)
	local VerifyFunction = INSTANCE("RemoteFunction", "VerifyFunction", nil, ReplicatedStorage)
	function VerifyFunction.OnServerInvoke(Player)
		if not Seeds[Player] then
			local Package = {
				Key = HttpService:GenerateGUID(false),
				Events = {Ref = {}},
			}
			for RemoteName, Remote in pairs(Remotes) do
				Package.Events[RemoteName] = {Seed = math.random(0, 2048), Event = Remote} 
			end
			Seeds[Player] = Package
			return Package
		else
			Player:Kick("Exploiter") --idk how you even managed to fire this event twice
		end
	end
end

return Network