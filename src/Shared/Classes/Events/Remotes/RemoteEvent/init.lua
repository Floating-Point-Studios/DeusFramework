local RunService = game:GetService("RunService")

local Deus = shared.Deus()

local BaseObject = Deus:Load("Deus.BaseObject")
local Output = Deus:Load("Deus.Output")

local RemoteEvent ={
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

if RunService:IsServer() then
    RemoteEvent.Methods = require(script.RemoteEventServer)
else
    RemoteEvent.Methods = require(script.RemoteEventClient)
end

return BaseObject.new(RemoteEvent)