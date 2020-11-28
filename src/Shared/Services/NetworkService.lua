local Deus = shared.Deus

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local RemoteEvent = Deus:Load("Deus/RemoteEvent")
local RemoteFunction = Deus:Load("Deus/RemoteEvent")

-- Allows support for a RemoteEvent and RemoteFunction to share the same name
local RemoteEvents = {}
local RemoteFunctions = {}

local OnRemoteEventAdded
local OnRemoteFunctionAdded

-- Client only function to add remotes
local function registerRemote(RBXRemote)
    if RBXRemote:IsA("RemoteEvent") then
        local remote = RemoteEvent.new(RBXRemote)
        RemoteEvents[RBXRemote.Name] = remote

        if OnRemoteEventAdded then
            OnRemoteEventAdded(remote)
        end
    elseif RBXRemote:IsA("RemoteFunction") then
        local remote = RemoteEvent.new(RBXRemote)
        RemoteEvents[RBXRemote.Name] = remote

        if OnRemoteEventAdded then
            OnRemoteEventAdded(remote)
        end
    end
end

local NetworkService = {}

-- Useful for applying settings such as filters to remotes when added
function NetworkService.onRemoteEventAdded(callback)
    OnRemoteEventAdded = callback

    if callback then
        for _,remote in pairs(RemoteEvents) do
            callback(remote)
        end
    end
end

function NetworkService.onRemoteFunctionAdded(callback)
    OnRemoteFunctionAdded = callback

    if callback then
        for _,remote in pairs(RemoteFunctions) do
            callback(remote)
        end
    end
end

function NetworkService.init()
    if RunService:IsClient() then

        local RemotesFolder = ReplicatedStorage:WaitForChild("DEUS_NETWORKSERVICE_REMOTES")

        function NetworkService.fireServer(remoteName, ...)
            RemoteEvents[remoteName]:Fire(...)
        end

        function NetworkService.invokeServer(remoteName, ...)
            return RemoteEvents[remoteName]:Invoke(...)
        end

        for _,remote in pairs(RemotesFolder:GetChildren()) do
            registerRemote(remote)
        end

        RemotesFolder.ChildAdded:Connect(function(remote)
            registerRemote(remote)
        end)
    else

        local RemotesFolder = Instance.new("Folder")
        RemotesFolder.Name = "DEUS_NETWORKSERVICE_REMOTES"
        RemotesFolder.Parent = ReplicatedStorage

        function NetworkService.createRemoteEvent(remoteName)
            local remoteEvent = RemoteEvent.new()
            remoteEvent.Name = remoteName
            remoteEvent.Parent = RemotesFolder

            RemoteEvents[remoteName] = remoteEvent

            if OnRemoteEventAdded then
                OnRemoteEventAdded(remoteEvent)
            end
        end

        function NetworkService.createRemoteFunction(remoteName, callback)
            local remoteFunction = RemoteFunction.new()
            remoteFunction.Name = remoteName
            remoteFunction.Parent = RemotesFolder

            RemoteFunctions[remoteName] = remoteFunction

            if callback then
                remoteFunction:Connect(callback)
            end

            if OnRemoteFunctionAdded then
                OnRemoteFunctionAdded(remoteFunction)
            end
        end

        function NetworkService.fireClient(remoteName, player, ...)
            RemoteEvents[remoteName]:Fire(player, ...)
        end

        function NetworkService.fireClients(remoteName, players, ...)
            local remote = RemoteEvents[remoteName]
            for _,player in pairs(players) do
                remote:Fire(player, ...)
            end
        end

        function NetworkService.fireAllClients(remoteName, ...)
            local remote = RemoteEvents[remoteName]
            for _,player in pairs(Players:GetPlayers()) do
                remote:Fire(player, ...)
            end
        end

        function NetworkService.fireNearbyClients(remoteName, pos, radius, ...)
            local remote = RemoteEvents[remoteName]
            local args = {...}
            for _,player in pairs(Players:GetPlayers()) do
                pcall(function()
                    if (player.Character.PrimaryPart.Position - pos).Magnitude <= radius then
                        remote:Fire(player, unpack(args))
                    end
                end)
            end
        end

        function NetworkService.invokeClient(remoteName, player, ...)
            return RemoteFunctions[remoteName]:Invoke(player, ...)
        end

    end
end

return NetworkService