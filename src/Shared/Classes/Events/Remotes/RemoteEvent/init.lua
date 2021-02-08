local RunService = game:GetService("RunService")

local BaseObject
local Output

local RemoteEventObjData = {
    ClassName = "Deus.RemoteEvent",

    PublicReadOnlyProperties = {
        LastSendTick = 0,
        LastReceiveTick = 0,
    },

    Constructor = function(self, ...)
        local args = {...}
        local remoteEvent
        if RunService:IsServer() then
            remoteEvent = Instance.new("RemoteEvent")
            remoteEvent.Name = args[2]
            remoteEvent.Parent = args[1]
            self.Internal.DEUSOBJECT_Properties.RBXEvent = remoteEvent

            remoteEvent.OnServerEvent:Connect(function()
                self.ExternalReadOnly.DEUSOBJECT_ReadOnlyProperties.LastReceiveTick = tick()
            end)
        else
            remoteEvent = args[1]
            Output.assert(remoteEvent, "Expected to be provided a RemoteEvent")
            self.Internal.DEUSOBJECT_Properties.RBXEvent = remoteEvent

            remoteEvent.OnClientEvent:Connect(function()
                self.ExternalReadOnly.DEUSOBJECT_ReadOnlyProperties.LastReceiveTick = tick()
            end)
        end
    end,
}

local RemoteEvent = {}

function RemoteEvent.start()
    BaseObject = RemoteEvent:Load("Deus.BaseObject")
    Output = RemoteEvent:Load("Deus.Output")

    return BaseObject.new(RemoteEventObjData)
end

function RemoteEvent.init()
    if RunService:IsServer() then
        RemoteEvent.Methods = RemoteEvent:WrapModule(script.RemoteEventServer)
    else
        RemoteEvent.Methods = RemoteEvent:WrapModule(script.RemoteEventClient)
    end
end

return RemoteEvent