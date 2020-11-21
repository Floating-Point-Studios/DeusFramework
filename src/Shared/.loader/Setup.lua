local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ServerScriptService = game:GetService("ServerScriptService")

return function(deus, framework)
    local frameworkClient = framework:FindFirstChild("Client")
    local frameworkServer = framework:FindFirstChild("Server")
    local frameworkShared = framework:FindFirstChild("Shared")

    if frameworkShared then
        if frameworkClient then
            frameworkShared:Clone().Parent = frameworkClient
        end
        if frameworkServer then
            frameworkShared.Parent = frameworkServer
        end
    end

    if frameworkClient then
        frameworkClient.Parent = ReplicatedFirst
    end

    if frameworkServer then
        frameworkServer.Parent = ServerScriptService
    end

    return frameworkClient, frameworkServer, frameworkShared
end