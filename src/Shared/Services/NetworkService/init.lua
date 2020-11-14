local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local RemoteEvent = require(script.RemoteEvent)
local RemoteFunction = require(script.RemoteFunction)

local NetworkService = {}

local RemotesFolder

function NetworkService.Init()
    if RunService:IsServer() then
        RemotesFolder = Instance.new("Folder")
        RemotesFolder.Name = "DeusNetworkServiceRemotes"
        RemotesFolder.Parent = ReplicatedStorage
    else
        RemotesFolder = ReplicatedStorage:WaitForChild("DeusNetworkServiceRemotes")
    end
end

local Remotes = {}

function NetworkService.createRemoteEvent(remoteName)
    assert(RunService:IsServer(), "createRemoteEvent can only be run on the Server")

    local remote = RemoteEvent.new(remoteName, RemotesFolder)
    Remotes[remoteName] = remote

    return remote
end

function NetworkService.createRemoteFunction(remoteName)
    assert(RunService:IsServer(), "createRemoteFunction can only be run on the Server")

    local remote = RemoteFunction.new(remoteName, RemotesFolder)
    Remotes[remoteName] = remote

    return remote
end

function NetworkService.listen(remoteName, func)
    local remote = Remotes[remoteName]

    if RunService:IsServer() then
        -- Listen to client events
        if remote.ClassName == "Deus/RemoteEvent" then
            return remote.OnClientEvent:Connect(func)
        else
            remote.OnInvoke = func
        end
    else
        -- Listen to server events
        if remote.ClassName == "Deus/RemoteEvent" then
            return remote.OnServerEvent:Connect(func)
        else
            remote.OnInvoke = func
        end
    end
end

function NetworkService.fireServer(remoteName, ...)
    Remotes[remoteName]:FireServer(...)
end

function NetworkService.fireClient(remoteName, player, ...)
    Remotes[remoteName]:FireClient(player, ...)
end

function NetworkService.fireClients(remoteName, players, ...)
    if players then
        local remote = Remotes[remoteName]
        local args = ...
        for _,player in pairs(players) do
            spawn(function()
                remote:FireClient(player, args)
            end)
        end
    else
        Remotes[remoteName]:FireAllClients(Players:GetPlayers(), ...)
    end
end

function NetworkService.fireNearbyClients(remoteName, pos, distance, ...)
    local remote = Remotes[remoteName]
    local args = ...
    for _,player in pairs(Players:GetPlayers()) do
        spawn(function()
            pcall(function()
                if (player.Character.HumanoidRootPart.Position - pos).Magnitude <= distance then
                    remote:FireClient(player, args)
                end
            end)
        end)
    end
end

function NetworkService.invokeServer(remoteName, ...)
    return Remotes[remoteName]:invokeServer(...)
end

function NetworkService.invokeClient(remoteName, player, ...)
    return Remotes[remoteName]:InvokeClient(player, ...)
end

return NetworkService