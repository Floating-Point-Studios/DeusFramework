local Deus = shared.Deus()
local Output = Deus:Load("Deus.Output")

local RemoteEvent = {}

function RemoteEvent:InvokeClient(internalAccess, player, ...)
    Output.assert(internalAccess, "Attempt to use internal method")
    self.LastSendTick = tick()
    return self.Internal.DEUSOBJECT_Properties.RBXEvent:InvokeClient(player, ...)
end

function RemoteEvent:Listen(internalAccess, callback)
    Output.assert(callback, "Expected callback")
    function self.Internal.DEUSOBJECT_Properties.RBXEvent.OnServerInvoke(...)
        return callback(...)
    end
end

return RemoteEvent