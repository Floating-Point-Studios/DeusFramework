local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteEvent
local RemoteFunction
local Output

local RemotesFolder
local RemoteEvents = {}
local RemoteFunctions = {}

local NetworkService = {}

function NetworkService:ListenRemoteEvent(remoteName, listener)
    local remote = RemoteEvents[remoteName]
    if not remote then
        RemotesFolder:WaitForChild(remoteName, 5)
    end

    Output.assert(remote, "RemoteEvent '%s' could not be found", remoteName)
    return remote:Listen(listener)
end

function NetworkService:ListenRemoteFunction(remoteName, listener)
    local remote = RemoteFunctions[remoteName]
    if not remote then
        RemotesFolder:WaitForChild(remoteName, 5)
    end

    Output.assert(remote, "RemoteFunction '%s' could not be found", remoteName)
    return remote:Listen(listener)
end

function NetworkService.getRemoteEvent(remoteName)
    local remote = RemoteEvents[remoteName]
    if not remote then
        RemotesFolder:WaitForChild(remoteName, 5)
    end

    Output.assert(remote, "RemoteEvent '%s' could not be found", remoteName)
    return remote
end

function NetworkService.getRemoteFunction(remoteName)
    local remote = RemoteFunctions[remoteName]
    if not remote then
        RemotesFolder:WaitForChild(remoteName, 5)
    end

    Output.assert(remote, "RemoteFunction '%s' could not be found", remoteName)
    return remote
end

function NetworkService.start()
    RemoteEvent = NetworkService:Load("Deus.RemoteEvent")
    RemoteFunction = NetworkService:Load("Deus.RemoteFunction")
    Output = NetworkService:Load("Deus.Output")

    if RunService:IsServer() then
        RemotesFolder = Instance.new("Folder")
        RemotesFolder.Name = "DEUSNetworkServiceRemotes"
        RemotesFolder.Parent = ReplicatedStorage

        function NetworkService.makeRemoteEvent(remoteName)
            local remote = RemoteEvent.new(RemotesFolder, remoteName)
            table.insert(RemoteEvents, remote)
            return remote
        end

        function NetworkService.makeRemoteFunction(remoteName)
            local remote = RemoteFunction.new(RemotesFolder, remoteName)
            table.insert(RemoteFunctions, remote)
            return remote
        end
    else
        RemotesFolder = ReplicatedStorage:WaitForChild("DEUSNetworkServiceRemotes")

        local function registerRemote(remote)
            if remote:IsA("RemoteEvent") then
            RemoteEvents[remote.Name] = RemoteEvent.new(remote)
            elseif remote:IsA("RemoteFunction") then
                RemoteFunctions[remote.Name] = RemoteFunction.new(remote)
            end
        end

        for _,remote in pairs(RemotesFolder:GetChildren()) do
            registerRemote(remote)
        end

        RemotesFolder.ChildAdded:Connect(function(remote)
            registerRemote(remote)
        end)
    end
end

return NetworkService