-- TODO: Refactor to new class convention

local HttpService = game:GetService("HttpService")

local Output

local BindableEvents = setmetatable({}, {__mode = "v"})
-- BindableEvents do not support userdata types made from newproxy() so instead we cache the payload and send a Uuid to retrieve the payload
local Cache = {}

function clearCache()
    local time = tick()
    for i,v in pairs(Cache) do
        if v.LastAccessed and time - v.LastAccessed > 0.5 then
            Cache[i] = nil
        end
    end
end

local BindableEvent = {}

BindableEvent.ClassName = "Deus.BindableEvent"

BindableEvent.Extendable = true

BindableEvent.Replicable = true

BindableEvent.Methods = {}

BindableEvent.Events = {}

function BindableEvent.Methods:Fire(...)
    Output.assert(self:IsInternalAccess(), "Attempt to fire remote from externally")
    self.LastFiredTick = tick()

    spawn(clearCache)

    local Uuid = HttpService:GenerateGUID(false)
    Cache[Uuid] = {...}

    self.RBXEvent:Fire(Uuid)
end

function BindableEvent.Methods:Connect(func)
    if not self:IsInternalAccess() then
        self = BindableEvents[self]
    end

    return self.RBXEvent.Event:Connect(function(Uuid)
        local payload = Cache[Uuid]
        payload.LastAccessed = tick()

        func(unpack(payload))
    end)
end

function BindableEvent.Methods:Wait()
    if not self:IsInternalAccess() then
        self = BindableEvents[self]
    end

    return self.RBXEvent.Event:Wait()
end

function BindableEvent:Constructor()
    BindableEvents[self.Proxy] = self
    self.RBXEvent = Instance.new("BindableEvent")
end

function BindableEvent:Deconstructor()
    BindableEvents[self.Proxy] = nil
    self.RBXEvent:Destroy()
end

function BindableEvent:start()
    Output = self:Load("Deus.Output")

    self.PrivateProperties = {
        RBXEvent = self:Load("Deus.Symbol").new("None")
    }

    self.PublicReadOnlyProperties = {}

    self.PublicReadAndWriteProperties = {}

    return self:Load("Deus.BaseObject").new(self)
end

return BindableEvent