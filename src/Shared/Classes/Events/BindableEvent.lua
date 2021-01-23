local Deus = shared.Deus

local BaseObject = Deus:Load("Deus.BaseObject")
local Output = Deus:Load("Deus.Output")

return BaseObject.new(
    {
        ClassName = "Deus.BindableEvent",

        Methods = {
            Fire = function(self, internalAccess, ...)
                Output.assert(internalAccess, "Attempt to fire remote from externally")
                self.RBXEvent:Fire(...)
            end,

            Connect = function(self, internalAccess, func)
                return self.RBXEvent.Event:Connect(func)
            end,

            Wait = function(self)
                return self.RBXEvent.Event:Wait()
            end
        },

        PublicReadOnlyProperties = {
            LastFired = 0,
        },

        Constructor = function(self)
            self.Internal.RBXEvent = Instance.new("BindableEvent")
        end
    }
)