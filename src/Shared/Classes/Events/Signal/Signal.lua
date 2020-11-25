local Deus = shared.DeusFramework

local RunService = game:GetService("RunService")

local TableProxy = Deus:Load("Deus/TableProxy")
local Debug = Deus:Load("Deus/Debug")
local Connection = Deus:Load("Deus/SignalConnection")

local SignalMetatables = {}

local Signal = {}

function Signal.new()
    local self, metatable = TableProxy.new(
        {
            -- Have to use the __index property to handle methods due to this being an implementation used by BaseClass
            __index = Signal;

            Internals = {
                Connections = setmetatable({}, {__mode = "kv"});
            };

            ExternalReadOnly = {
                LastFired = 0;
            };
        }
    )

    SignalMetatables[self] = metatable

    return self, metatable
end

function Signal:Fire(...)
    Debug.assert(TableProxy.isInternalAccess(self), "[Signal] Cannot fire signal from externally")
    for _,connection in pairs(self.Internals.Connections) do
        -- [TO-DO] Run functions on new thread once parallel Luau is released
        if connection.Connected then
            connection.Func(...)
        end
    end
    self.ExternalReadOnly.LastFired = tick()
end

function Signal:Connect(func)
    if not TableProxy.isInternalAccess(self) then
        self = SignalMetatables[self]
    end

    local connectionProxy, connectionMetatable = Connection.new(func)
    table.insert(self.Internals.Connections, connectionMetatable)

    return connectionProxy
end

function Signal:Wait(timeout)
    timeout = timeout or 30

    local waitStart = tick()
    repeat
        RunService.Heartbeat:Wait()
        if tick() - waitStart > timeout then
            Debug.warn("Event wait timed out after %s seconds", timeout)
            break
        end
    until self.ExternalReadOnly.LastFired > waitStart

    return
end

return Signal