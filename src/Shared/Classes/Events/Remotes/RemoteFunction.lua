local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local Output

local RemoteFunction = {
    ClassName = "Deus.RemoteFunction",
    Extendable = true,
    Replicable = true,
    Methods = {},
    Events = {}
}

function RemoteFunction:Constructor(name, parent)
    name = name or HttpService:GenerateGUID(false)

    local rbxevent = Instance.new("RemoteFunction")
    rbxevent.Name = name
    rbxevent.Parent = parent

    self.RBXEvent = rbxevent
end

function RemoteFunction:Deconstructor()
    self.RBXEvent:Destroy()
end

function RemoteFunction.Methods:OnInvoke(func)
    Output.assert(self:IsInternalAccess(), "Attempt to use internal method from externally", nil, 1)

    if RunService:IsServer() then
        self.RBXEvent.OnServerInvoke = func
    else
        self.RBXEvent.OnClientInvoke = func
    end
end

function RemoteFunction.Methods:Invoke(...)
    Output.assert(self:IsInternalAccess(), "Attempt to use internal method from externally", nil, 1)

    if RunService:IsServer() then
        return self.RBXEvent:InvokeClient(...)
    else
        return self.RBXEvent:InvokeServer(...)
    end
end

function RemoteFunction:start()
    Output = self:Load("Deus.Output")

    local None = self:Load("Deus.Symbol").new("None")

    self.PrivateProperties = {
        RBXEvent = None
    }

    self.PublicReadOnlyProperties = {}

    self.PublicReadAndWriteProperties = {}

    return self:Load("Deus.BaseObject").new(self)
end

return RemoteFunction