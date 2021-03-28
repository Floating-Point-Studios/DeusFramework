local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local Output

local RemoteEvent = {
    ClassName = "RemoteEvent",
    Events = {}
}

function RemoteEvent:Constructor(...)
    local args = {...}
    if RunService:IsServer() then
        -- args[1] = name
        -- args[2] = parent
        local name = args[1] or HttpService:GenerateGUID(false)

        local rbxevent = Instance.new("RemoteEvent")
        rbxevent.Name = name
        rbxevent.Parent = args[2]

        self.RBXEvent = rbxevent
    else
        -- args[1] = RemoteEvent
        self.RBXEvent = args[1]
    end
end

function RemoteEvent:Deconstructor()
    self.RBXEvent:Destroy()
end

function RemoteEvent:Connect(func)
    if RunService:IsServer() then
        return self.RBXEvent.OnServerEvent:Connect(func)
    else
        return self.RBXEvent.OnClientEvent:Connect(func)
    end
end

function RemoteEvent:Fire(...)
    Output.assert(self:IsInternalAccess(), "Attempt to use internal method from externally", nil, 1)

    if RunService:IsServer() then
        self.RBXEvent:FireClient(...)
    else
        self.RBXEvent:FireServer(...)
    end
end

function RemoteEvent:FireAllClients(...)
    Output.assert(self:IsInternalAccess(), "Attempt to use internal method from externally", nil, 1)
    Output.assert(RunService:IsServer(), "Attempt to use server-only method on client", nil, 1)

    self.RBXEvent:FireAllClients(...)
end

function RemoteEvent:FireWhitelistedClients(players, ...)
    Output.assert(self:IsInternalAccess(), "Attempt to use internal method from externally", nil, 1)
    Output.assert(RunService:IsServer(), "Attempt to use server-only method on client", nil, 1)

    local rbxevent = self.RBXEvent
    for _,player in pairs(players) do
        rbxevent:FireClient(player, ...)
    end
end

function RemoteEvent:start()
    Output = self:Load("Deus.Output")

    local None = self:Load("Deus.Symbol").new("None")

    self.PrivateProperties = {
        RBXEvent = None
    }

    self.PublicReadOnlyProperties = {}

    self.PublicReadAndWriteProperties = {}

    return self:Load("Deus.BaseObject").new(self)
end

return RemoteEvent