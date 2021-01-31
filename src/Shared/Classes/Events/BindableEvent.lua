local HttpService = game:GetService("HttpService")

local Deus = shared.Deus()

local BaseObject = Deus:Load("Deus.BaseObject")
local Output = Deus:Load("Deus.Output")

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

return BaseObject.new(
    {
        ClassName = "Deus.BindableEvent",

        Methods = {
            Fire = function(self, internalAccess, ...)
                Output.assert(internalAccess, "Attempt to fire remote from externally")
                self.LastFiredTick = tick()

                spawn(clearCache)

                local Uuid = HttpService:GenerateGUID(false)
                Cache[Uuid] = {...}

                self.Internal.DEUSOBJECT_Properties.RBXEvent:Fire(Uuid)
            end,

            Connect = function(self, internalAccess, func)
                return self.Internal.DEUSOBJECT_Properties.RBXEvent.Event:Connect(function(Uuid)
                    local payload = Cache[Uuid]
                    payload.LastAccessed = tick()

                    func(unpack(payload))
                end)
            end,

            Wait = function(self)
                return self.Internal.DEUSOBJECT_Properties.RBXEvent.Event:Wait()
            end
        },

        PublicReadOnlyProperties = {
            LastFiredTick = 0,
        },

        Constructor = function(self)
            self.Internal.DEUSOBJECT_Properties.RBXEvent = Instance.new("BindableEvent")
        end
    }
)