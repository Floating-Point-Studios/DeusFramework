local require = shared.Setup()

local BindableEvent = {}

function BindableEvent.new()
    local self = setmetatable({}, BindableEvent)

    self._connections = {}
    self._lastFired = 0

    function self:Connect(callback)
        table.insert(self._connections, callback)
    end

    function self:Wait(timeout)
        timeout = timeout or 30
        local waitStarted = tick()
        repeat
            wait()
        until self._lastFired > waitStarted or tick() - timeout > waitStarted
    end

    function self:Fire(...)
        self._lastFired = tick()
        for _,callback in pairs(self._connections) do
            callback(...)
        end
    end
end

return BindableEvent