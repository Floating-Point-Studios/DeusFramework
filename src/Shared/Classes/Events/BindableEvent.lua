local HttpService = game:GetService("HttpService")

local Deus = shared.Deus()

local BaseObject = Deus:Load("Deus.BaseObject")
local Output = Deus:Load("Deus.Output")

-- BindableEvents do not support userdata types made from newproxy() so instead we cache the payload and send a Uuid to retrieve the payload
local Cache = {}

return BaseObject.new(
    {
        ClassName = "Deus.BindableEvent",

        Methods = {
            Fire = function(self, internalAccess, ...)
                Output.assert(internalAccess, "Attempt to fire remote from externally")
                self.LastFiredTick = tick()
                local Uuid = HttpService:GenerateGUID(false)
                Cache[Uuid] = {...}
                self.Internal.DEUSOBJECT_Properties.RBXEvent:Fire(Uuid)
                wait()
                -- May not work with lag, may have to change
                Cache[Uuid] = nil
            end,

            Connect = function(self, internalAccess, func)
                return self.Internal.DEUSOBJECT_Properties.RBXEvent.Event:Connect(function(Uuid)
                    func(unpack(Cache[Uuid]))
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