local Deus = shared.Deus()

local BaseObject = Deus:Load("Deus.BaseObject")
local Output = Deus:Load("Deus.Output")

return BaseObject.new(
    {
        ClassName = "Deus.BindableEvent",

        Methods = {
            Fire = function(self, internalAccess, ...)
                Output.assert(internalAccess, "Attempt to fire remote from externally")
                self.LastFiredTick = tick()
                self.Internal.DEUSOBJECT_Properties.RBXEvent:Fire(...)
            end,

            Connect = function(self, internalAccess, func)
                return self.Internal.DEUSOBJECT_Properties.RBXEvent.Event:Connect(func)
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