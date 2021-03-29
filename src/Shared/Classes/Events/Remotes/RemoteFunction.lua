local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local Output

local RemoteFunction = {
    ClassName = "RemoteFunction",
    Events = {}
}

function RemoteFunction:Constructor(...)
    local args = {...}
    if RunService:IsServer() then
        -- args[1] = name
        -- args[2] = parent
        local name = args[1] or HttpService:GenerateGUID(false)

        local rbxevent = Instance.new("RemoteFunction")
        rbxevent.Name = name
        rbxevent.Parent = args[2]

        self.RBXEvent = rbxevent
    else
        -- args[1] = RemoteFunction
        self.RBXEvent = args[1]
    end
end

function RemoteFunction:Deconstructor()
    self.RBXEvent:Destroy()
end

function RemoteFunction:OnInvoke(func)
    Output.assert(self:IsInternalAccess(), "Attempt to use internal method from externally", nil, 1)

    if RunService:IsServer() then
        self.RBXEvent.OnServerInvoke = func
    else
        self.RBXEvent.OnClientInvoke = func
    end
end

function RemoteFunction:Invoke(...)
    Output.assert(self:IsInternalAccess(), "Attempt to use internal method from externally", nil, 1)

    if RunService:IsServer() then
        return self.RBXEvent:InvokeClient(...)
    else
        return self.RBXEvent:InvokeServer(...)
    end
end

function RemoteFunction:start()
    Output = self:Load("Deus.Output")

    local None = self:Load("Deus.Symbol").get("None")

    self.PrivateProperties = {
        RBXEvent = None
    }

    self.PublicReadOnlyProperties = {}

    self.PublicReadAndWriteProperties = {}

    return self:Load("Deus.BaseObject").new(self)
end

return RemoteFunction