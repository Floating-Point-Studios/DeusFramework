local Deus = shared.DeusFramework

local TableProxy = Deus:Load("Deus/TableProxy")
local Output = Deus:Load("Deus/Output")

local SignalMetatables = {}

local Signal = {}

function Signal.new()
    local self, metatable = TableProxy.new(
        {
            -- Have to use the __index property to handle methods due to this being an implementation used by BaseClass
            __index = Signal;

            Internals = {
                Event = Instance.new("BindableEvent")
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
    Output.assert(TableProxy.isInternalAccess(self), "[Signal] Cannot fire signal from externally")

    self.Internals.Event:Fire(...)
    self.ExternalReadOnly.LastFired = tick()
end

function Signal:Connect(func)
    return self.Internals.Event:Connect(func)
end

function Signal:Wait()
    local waitStart = tick()
    self.Internals.Event:Wait()
    return tick() - waitStart
end

return Signal