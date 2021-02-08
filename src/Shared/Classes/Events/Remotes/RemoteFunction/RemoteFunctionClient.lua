local Output

local RemoteFunction = {}

function RemoteFunction:InvokeServer(internalAccess, ...)
    Output.assert(internalAccess, "Attempt to use internal method")
    return self.Internal.DEUSOBJECT_Properties.RBXEvent:InvokeServer(...)
end

function RemoteFunction:Listen(_, callback)
    Output.assert(callback, "Expected callback")
    function self.Internal.DEUSOBJECT_Properties.RBXEvent.OnClientInvoke(...)
        return callback(...)
    end
end

function RemoteFunction.start()
    Output = RemoteFunction:Load("Deus.Output")
end

return RemoteFunction