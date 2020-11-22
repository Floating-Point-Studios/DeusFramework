local Deus = shared.DeusFramework

local RunService = game:GetService("RunService")

local TableProxy = Deus:Load("Deus/TableProxy")
local Debug = Deus:Load("Deus/Debug")

local Connection = require(script.Connection)

local Signal = {}

function Signal.new()
    local self, metatable = TableProxy.new(
        {
            Connections = setmetatable({}, {__mode = "kv"});
        },
        {
            LastFired = 0;
        }
    )

    metatable.__index = Signal

    return self
end

function Signal:Fire(...)
    local isInternalAccess, metatable = TableProxy.isInternalAccess(self)
    Debug.assert(isInternalAccess, "[Signal] Cannot fire event externally")

    for _,connection in pairs(metatable.__internals.Connections) do
        connection.Func(...)
    end
end

function Signal:Connect(func)
    local _,metatable = TableProxy.isInternalAccess(self)
    local connectionProxy, connectionMetatable = Connection.new(func)

    table.insert(metatable.__internals.Connections, connectionMetatable)

    return connectionProxy
end

function Signal:Wait(timeout)
    timeout = timeout or 30

    local _,metatable = TableProxy.isInternalAccess(self)

    local waitStart = tick()
    repeat
        RunService.Heartbeat:Wait()
        if tick() - waitStart > timeout then
            Debug.warn("Event wait timed out after %s seconds", timeout)
            break
        end
    until metatable.__externals.LastFired > waitStart

    return
end

return Signal