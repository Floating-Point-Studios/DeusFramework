local Output

local RemoteFunction = {}

function RemoteFunction:InvokeClient(internalAccess, player, ...)
    Output.assert(internalAccess, "Attempt to use internal method")
    self.LastSendTick = tick()
    return self.Internal.DEUSOBJECT_Properties.RBXEvent:InvokeClient(player, ...)
end

function RemoteFunction:Listen(callback)
    Output.assert(callback, "Expected callback")
    function self.Internal.DEUSOBJECT_Properties.RBXEvent.OnServerInvoke(...)
        return callback(...)
    end
end

function RemoteFunction.start()
    Output = RemoteFunction:Load("Deus.Output")
end

return RemoteFunction