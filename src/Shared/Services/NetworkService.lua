local Deus = shared.Deus

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Debug = Deus:Load("Deus/Debug")
local RemoteEvent = Deus:Load("Deus/RemoteEvent")

local RemotesArray = {}
local RemotesFolder

local NetworkService = {}

function NetworkService.init()
    if RunService:IsClient() then

        RemotesFolder = ReplicatedStorage:WaitForChild("DEUS_NETWORKSERVICE_REMOTES")

        function NetworkService.fireServer(remoteName, ...)
            
        end

        function NetworkService.invokeServer(remoteName, ...)
            
        end

    else

        RemotesFolder = Instance.new("Folder")
        RemotesFolder.Name = "DEUS_NETWORKSERVICE_REMOTES"
        RemotesFolder.Parent = ReplicatedStorage

        function NetworkService.createRemoteEvent(name)
            
        end

        function NetworkService.createRemoteFunction(name)
            
        end

        function NetworkService.fireClient(remoteName, ...)
            
        end

        function NetworkService.fireClients(remoteName, ...)
            
        end

        function NetworkService.fireAllClients(remoteName, ...)
            
        end

        function NetworkService.fireNearbyClients(remoteName, ...)
            
        end

        function NetworkService.invokeClient(remoteName, ...)
            
        end

    end
end

return NetworkService