-- Custom implementation of Roblox signals
-- Allows setting OnConnect and OnDisconnect and fire when a connection is made or destroyed

local Signal = shared.Deus.import("Deus.BaseClass").new("Deus/Signal")

local Connection = shared.Deus.import("Deus.Connection")

function Signal.Constructor(self)
    self._connections = {}
    self._lastFired = 0

    -- self.OnConnect
    -- self.OnDisconnect
end

function Signal:Connect(func, ...)
    table.insert(self._connections, Connection.new(func, self))

    if self.OnConnect then
        self.OnConnect(func, ...)
    end
end

function Signal:Wait(timeout: number?)
    timeout = timeout or 30
    local waitStart = tick()
    repeat
        if tick() - waitStart > timeout then
            warn(("Signal Wait timed out after %s seconds"):format(timeout))
            break
        end
    until self._lastFired > waitStart
end

function Signal:Fire(...)
    for i, connection in pairs(self._connections) do
        if connection.Connected then
            connection._func(...)
        else
            self._connections[i] = nil
        end
    end
end

-- consistency with deprecated Roblox functions
Signal.connect = Signal.Connect
Signal.wait = Signal.wait

return Signal