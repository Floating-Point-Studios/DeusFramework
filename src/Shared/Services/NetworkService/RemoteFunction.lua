local RunService = game:GetService("RunService")

local Signal = shared.Deus.import("Deus.Signal")

local RemoteFunction = {}

function RemoteFunction.new(name, parent)
    local self = {
        ClassName = "Deus/RemoteFunction"

        -- OnInvoke: callback function

        -- SendFilter: function arguments will be passed through before sending through event
        -- ReceiveFilter: function arguments will be passed throguh before sending through event
        -- ReturnFilter: function arguments will be passed through when returning or receiving a return
    }

    local remoteFunction = Instance.new("RemoteFunction")
    remoteFunction.Name = name
    remoteFunction.Parent = parent
    self._remoteFunction = remoteFunction

    if RunService:IsServer() then
        function remoteFunction.OnClientInvoke(...)
            local callback = self.OnInvoke
            if callback then
                local receiveFilter = self.ReceiveFilter
                local returnFilter = self.ReturnFilter
                local args

                if receiveFilter then
                    args = receiveFilter(...)
                else
                    args = ...
                end

                if returnFilter then
                    return returnFilter(callback(...))
                else
                    return callback(...)
                end
            end
            return false
        end
    else
        function remoteFunction.OnServerInvoke(...)
            local callback = self.Callback
            if callback then
                local receiveFilter = self.ReceiveFilter
                local returnFilter = self.ReturnFilter
                local args

                if receiveFilter then
                    args = receiveFilter(...)
                else
                    args = ...
                end

                if returnFilter then
                    return returnFilter(callback(...))
                else
                    return callback(...)
                end
            end
            return false
        end
    end

    return setmetatable(self, {__index = RemoteFunction})
end

function RemoteFunction:InvokeServer(...)
    assert(RunService:IsClient(), "RemoteFunction can only invoke server from client")

    local sendFilter = self.SendFilter
    if sendFilter then
        self._remoteFunction:InvokeServer(sendFilter(...))
    else
        self._remoteFunction:InvokeServer(...)
    end
end

function RemoteFunction:InvokeClient(player, ...)
    assert(RunService:IsServer(), "RemoteFunction can only invoke client from server")

    local sendFilter = self.SendFilter
    if sendFilter then
        self._remoteFunction:InvokeClient(player, sendFilter(player, ...))
    else
        self._remoteFunction:InvokeClient(player, ...)
    end
end

return RemoteFunction