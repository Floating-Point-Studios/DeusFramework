local Deus = shared.Deus
local Output = Deus:Load("Deus.Output")

local RemoteEvent = {}

function RemoteEvent:InvokeServer(internalAccess, ...)
    Output.assert(internalAccess, "Attempt to use internal method")
    return self.RBXEvent:InvokeServer(...)
end

function RemoteEvent:Listen(internalAccess, callback)
    Output.assert(callback, "Expected callback")
    function self.RBXEvent.OnClientInvoke(...)
        return callback(...)
    end
end

return RemoteEvent