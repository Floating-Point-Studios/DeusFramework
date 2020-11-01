local Connection = {}

function Connection.new(func)
    local self = {
        Connected = true,
        _func = func,
    }
    return setmetatable(self, {__index = Connection})
end

function Connection:Disconnect()
    self.Connected = false
    self._func = nil
end

return Connection