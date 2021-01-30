local Deus = shared.Deus()
local Output = Deus:Load("Deus.Output")

local RemoteEvent = {}

function RemoteEvent:FireServer(internalAccess, ...)
    Output.assert(internalAccess, "Attempt to use internal method")
    self.LastSendTick = tick()
    self.Internal.DEUSOBJECT_Properties.RBXEvent:FireServer(...)
end

function RemoteEvent:Listen(internalAccess, func)
    return self.Internal.DEUSOBJECT_Properties.RBXEvent.OnClientEvent:Connect(func)
end

return RemoteEvent