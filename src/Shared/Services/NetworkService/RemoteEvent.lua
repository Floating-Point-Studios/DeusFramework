local RunService = game:GetService("RunService")

local Signal = shared.Deus.import("Deus.Signal")

local RemoteEvent = {}

function RemoteEvent.new(...)
    local creationArgs = {...}

    local self = {
        ClassName = "Deus/RemoteEvent"

        -- SendFilter: function arguments will be passed through before sending through event
        -- ReceiveFilter: function arguments will be passed throguh before sending through event
    }

    if RunService:IsServer() then
        local remoteEvent = Instance.new("RemoteEvent")
        remoteEvent.Name = creationArgs[1]
        remoteEvent.Parent = creationArgs[2]
        self._remoteEvent = remoteEvent

        self.OnServerEvent = Signal.new()
        remoteEvent.OnServerEvent:Connect(function(...)

            local receiveFilter = self.ReceiveFilter
            if receiveFilter then
                self.OnServerEvent:Fire(receiveFilter(...))
            else
                self.OnServerEvent:Fire(...)
            end

        end)
    else
        local remoteEvent = creationArgs[1]
        self._remoteEvent = remoteEvent

        self.OnClientEvent = Signal.new()
        remoteEvent.OnClientEvent:Connect(function(...)

            local receiveFilter = self.ReceiveFilter
            if receiveFilter then
                self.OnClientEvent:Fire(receiveFilter(...))
            else
                self.OnClientEvent:Fire(...)
            end

        end)
    end

    return setmetatable(self, {__index = RemoteEvent})
end

function RemoteEvent:FireServer(...)
    assert(RunService:IsClient(), "RemoteEvent can only fire server from client")

    local sendFilter = self.SendFilter
    if sendFilter then
        self._remoteEvent:FireServer(sendFilter(...))
    else
        self._remoteEvent:FireServer(...)
    end
end

function RemoteEvent:FireClient(player, ...)
    assert(RunService:IsServer(), "RemoteEvent can only fire client from server")

    local sendFilter = self.SendFilter
    if sendFilter then
        self._remoteEvent:FireClient(player, sendFilter(player, ...))
    else
        self._remoteEvent:FireClient(player, ...)
    end
end

function RemoteEvent:FireAllClients(...)
    assert(RunService:IsServer(), "RemoteEvent can only fire client from server")

    local sendFilter = self.SendFilter
    if sendFilter then
        self._remoteEvent:FireAllClients(sendFilter(nil, ...))
    else
        self._remoteEvent:FireAllClients(...)
    end
end

return RemoteEvent