local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local Output

local RemoteEvent = {
    ClassName = "Deus.RemoteEvent",
    Extendable = true,
    Replicable = true,
    Methods = {},
    Events = {}
}

function RemoteEvent:Constructor(name, parent)
    name = name or HttpService:GenerateGUID(false)

    local rbxevent = Instance.new("RemoteEvent")
    rbxevent.Name = name
    rbxevent.Parent = parent

    self.RBXEvent = rbxevent
end

function RemoteEvent:Deconstructor()
    self.RBXEvent:Destroy()
end

function RemoteEvent.Methods:Connect(func)
    if RunService:IsServer() then
        return self.RBXEvent.OnServerEvent:Connect(func)
    else
        return self.RBXEvent.OnClientEvent:Connect(func)
    end
end

function RemoteEvent.Methods:Fire(...)
    Output.assert(self:IsInternalAccess(), "Attempt to use internal method from externally", nil, 1)

    if RunService:IsServer() then
        self.RBXEvent:FireClient(...)
    else
        self.RBXEvent:FireServer(...)
    end
end

function RemoteEvent.Methods:FireAllClients(...)
    Output.assert(self:IsInternalAccess(), "Attempt to use internal method from externally", nil, 1)
    Output.assert(RunService:IsServer(), "Attempt to use server-only method on client", nil, 1)

    self.RBXEvent:FireAllClients(...)
end

function RemoteEvent.Methods:FireWhitelistedClients(players, ...)
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