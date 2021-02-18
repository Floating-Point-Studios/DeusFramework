local Output

local RemoteFunction = {}

function RemoteFunction:InvokeClient(player, ...)
    Output.assert(self:IsInternalAccess(), "Attempt to use internal method")
    self.LastSendTick = tick()
    return self.Internal.DEUSOBJECT_Properties.RBXEvent:InvokeClient(player, ...)
end

function RemoteFunction:Listen(callback)
    Output.assert(callback, "Expected callback")
    function self.Internal.DEUSOBJECT_Properties.RBXEvent.OnServerInvoke(...)
        return callback(...)
    end
end

function RemoteFunction:start()
    Output = self:Load("Deus.Output")
end

return RemoteFunction