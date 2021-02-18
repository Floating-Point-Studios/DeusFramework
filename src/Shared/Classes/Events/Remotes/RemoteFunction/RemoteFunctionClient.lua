local Output

local RemoteFunction = {}

function RemoteFunction:InvokeServer(...)
    Output.assert(self:IsInternalAccess(), "Attempt to use internal method")
    return self.Internal.DEUSOBJECT_Properties.RBXEvent:InvokeServer(...)
end

function RemoteFunction:Listen(callback)
    Output.assert(callback, "Expected callback")
    function self.Internal.DEUSOBJECT_Properties.RBXEvent.OnClientInvoke(...)
        return callback(...)
    end
end

function RemoteFunction:start()
    Output = self:Load("Deus.Output")
end

return RemoteFunction