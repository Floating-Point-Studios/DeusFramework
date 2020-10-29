local require = shared.DeusHook()

local BaseObject = require("BaseObject")

local RemoteFunction = setmetatable({}, BaseObject)
RemoteFunction.ClassName = "Deus/RemoteFunction"
RemoteFunction.__index = RemoteFunction

if game:GetService("RunService"):IsServer() then

    local Players = game:GetService("Players")

    -- Creates RemoteFunction with given name, parent, and callback
    function RemoteFunction.new(name, parent, func)
        local remoteFunction = Instance.new("RemoteFunction", parent)

        local self = setmetatable(BaseObject.new(remoteFunction), RemoteFunction)

        return self
    end

    -- Invokes single client
    function RemoteFunction:InvokeClient()
            
    end

    -- Invokes array of clients, if array not provided will invoke all players
    function RemoteFunction:InvokeClients()
        
    end

else

    function RemoteFunction.new(remoteFunction)
        local self = setmetatable(BaseObject.new(remoteFunction), RemoteFunction)

        return self
    end

    -- Fires event to server
    function RemoteFunction:InvokeServer(...)

    end

end

return RemoteFunction