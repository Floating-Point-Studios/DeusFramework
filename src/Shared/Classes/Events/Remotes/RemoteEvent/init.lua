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

function RemoteEvent:start()
    BaseObject = self:Load("Deus.BaseObject")
    Output = self:Load("Deus.Output")

    return BaseObject.new(RemoteEventObjData)
end

function RemoteEvent:init()
    if RunService:IsServer() then
        self.Methods = self:WrapModule(script.RemoteEventServer)

        RemoteEventObjData.Deconstructor = function(self)
            self.Internal.DEUSOBJECT_Properties.RBXEvent:Destroy()
        end
    else
        self.Methods = self:WrapModule(script.RemoteEventClient)
    end
end

return RemoteEvent