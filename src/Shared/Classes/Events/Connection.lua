local Connection = {}

function Connection.new(func, signal)
    local self = {
        _func = func,
        _signal = signal,

        Connected = true,
    }
    return setmetatable(self, {__index = Connection})
end

function Connection:Disconnect()
    self.Connected = false

    local OnDisconnect = self._signal.OnDisconnect
    if OnDisconnect then
        OnDisconnect(self._func)
    end

    self._func = nil
end

Connection.disconnect = Connection.Disconnect

return Connection