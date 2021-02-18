local Output

local RemoteEvent = {}

function RemoteEvent:FireServer(...)
    Output.assert(self:IsInternalAccess(), "Attempt to use internal method")
    self.LastSendTick = tick()
    self.Internal.DEUSOBJECT_Properties.RBXEvent:FireServer(...)
end

function RemoteEvent:Listen(func)
    return self.Internal.DEUSOBJECT_Properties.RBXEvent.OnClientEvent:Connect(func)
end

function RemoteEvent:start()
    Output = self:Load("Deus.Output")
end

return RemoteEvent