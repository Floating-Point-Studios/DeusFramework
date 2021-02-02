local RunService = game:GetService("RunService")

local Deus = shared.Deus()

local BaseObject = Deus:Load("Deus.BaseObject")
local Output = Deus:Load("Deus.Output")

local RemoteFunction = {
    ClassName = "Deus.RemoteFunction",

    Constructor = function(self, ...)
        local args = {...}
        local remoteFunction
        if RunService:IsServer() then
            remoteFunction = Instance.new("RemoteFunction")
            remoteFunction.Name = args[2]
            remoteFunction.Parent = args[1]
            self.Internal.DEUSOBJECT_Properties.RBXEvent = remoteFunction
        else
            remoteFunction = args[1]
            Output.assert(remoteFunction, "Expected to be provided a RemoteFunction")
            self.Internal.DEUSOBJECT_Properties.RBXEvent = remoteFunction
        end
    end
}

if RunService:IsServer() then
    RemoteFunction.Methods = require(script.RemoteFunctionServer)
else
    RemoteFunction.Methods = require(script.RemoteFunctionClient)
end

return BaseObject.new(RemoteFunction)