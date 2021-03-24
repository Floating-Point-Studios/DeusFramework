local HttpService = game:GetService("HttpService")

local Proxy
local Output

-- We use this BindableEvent to immediately spawn a new thread
local RBXBindableEvent = Instance.new("BindableEvent")
-- Roblox doesn't allow us to send proxies through events for some reason so we cache the arguments
local RBXEventArgs = {}

local BindableEvent = {}

function BindableEvent.new()
    return Proxy.new(
        {
            Connections = {},
            LastFired = 0,
        },
        {
            __index = BindableEvent
        }
    )
end

function BindableEvent:Connect(func)
    local connections = self.Connections
    local eventConnection = {
        EventId = HttpService:GenerateGUID(false),
        Connected = true
    }

    -- Simulate a connection signal
    function eventConnection:Disconnect()
        eventConnection.Connected = false
        table.remove(connections, table.find(connections, func))
    end

    table.insert(connections, func)

    return eventConnection
end

function BindableEvent:Wait()
    while true do
        local args = {RBXBindableEvent.Event:Wait()}
        if args[1] == self.EventId then
            return unpack(RBXEventArgs[args[3]])
        end
    end
end

-- Mimics a object without actually using one
function BindableEvent:Fire(...)
    Output.assert(typeof(self) == "table", "Attempt to fire event from externally", nil, 1)

    local argsId = HttpService:GenerateGUID(false)
    RBXEventArgs[argsId] = {...}

    -- If there are no connections to the event but :Wait() is called it will infinitely yield, this is the way around that
    if #self.Connections == 0 then
        RBXBindableEvent:Fire(self.EventId, nil, argsId)
    end

    for _,v in pairs(self.Connections) do
        RBXBindableEvent:Fire(self.EventId, v, argsId)
    end
    self.LastFired = tick()
end

function BindableEvent:start()
    Proxy = self:Load("Deus.Proxy")
    Output = self:Load("Deus.Output")
end

function BindableEvent:init()
    RBXBindableEvent.Event:Connect(function(_, func, argsId)
        if func then
            local args = RBXEventArgs[argsId]
            RBXEventArgs[argsId] = nil
            func(unpack(args))
        end
    end)
end

return BindableEvent