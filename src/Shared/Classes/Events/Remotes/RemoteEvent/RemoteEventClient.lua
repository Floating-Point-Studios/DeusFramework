local Output

local RemoteEvent = {}

function RemoteEvent:FireServer(internalAccess, ...)
    Output.assert(internalAccess, "Attempt to use internal method")
    self.LastSendTick = tick()
    self.Internal.DEUSOBJECT_Properties.RBXEvent:FireServer(...)
end

function RemoteEvent:Listen(_, func)
    return self.Internal.DEUSOBJECT_Properties.RBXEvent.OnClientEvent:Connect(func)
end

function RemoteEvent.start()
    Output = RemoteEvent:Load("Deus.Output")
end

return RemoteEvent