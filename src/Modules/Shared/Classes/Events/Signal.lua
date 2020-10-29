local require = shared.DeusHook()

local RunService = game:GetService("RunService")

local BaseObject = require("BaseObject")
local Debugger = require("Debugger")

local Signal = setmetatable({}, BaseObject)
Signal.ClassName = "Deus/Signal"
Signal._lastFired = 0
Signal._connections = {}
Signal.__index = Signal

local Connection = setmetatable({}, BaseObject)
Connection.ClassName = "Deus/Connection"
Connection.Connected = true
Connection.__index = Connection

function Connection.new(func)
    local self = setmetatable(BaseObject.new({}), Connection)

    self._func = func

    return self
end

function Connection:Disconnect()
    self.Connected = false
    self:Destroy()
end

function Signal.new()
    local self = setmetatable(BaseObject.new({}), Signal)
    
	return self
end

function Signal:Connect(func)
    local SignalConnection = Connection.new(func)
    table.insert(self._connections, SignalConnection)
    return SignalConnection
end

function Signal:Wait(timeout)
    timeout = timeout or 30
    local waitStarted = tick()
    repeat
        RunService.Heartbeat:Wait()
        if tick() - timeout > waitStarted then
            Debugger.warn(("ScriptConnection Wait timed out after %s seconds"):format(timeout))
            return
        end
    until self._lastFired > waitStarted
end

function Signal:Fire(...)
    for i, connection in pairs(self._connections) do
        if connection.Connected then
            connection._func()
        else
            self._connections[i] = nil
        end
    end
end

return Signal