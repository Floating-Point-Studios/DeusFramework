local RunService = game:GetService("RunService")

local BaseObject
local Output

local RemoteFunctionObjData = {
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

local RemoteFunction = {}

function RemoteFunction.start()
    BaseObject = RemoteFunction:Load("Deus.BaseObject")
    Output = RemoteFunction:Load("Deus.Output")

    return BaseObject.new(RemoteFunctionObjData)
end

function RemoteFunction.init()
    if RunService:IsServer() then
        RemoteFunctionObjData.Methods = RemoteFunction:WrapModule(script.RemoteFunctionServer, true, true)
    else
        RemoteFunctionObjData.Methods = RemoteFunction:WrapModule(script.RemoteFunctionClient, true, true)
    end
end

return RemoteFunction