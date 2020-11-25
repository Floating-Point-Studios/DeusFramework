local Deus = shared.DeusFramework

local BaseClass = Deus:Load("Deus/BaseClass")
local Maid = Deus:Load("Deus/Maid")

return BaseClass.new(
    {
        ClassName = "Deus/BaseObject";

        Superclass = nil;

        Constructor = function(self)
            self.Internals.Maid = Maid.new()
        end;

        Events = {"OnDestroy"};

        Internals = {};

        Methods = {
            Destroy = function(self)
                self.OnDestroy:Fire()
                self.Maid:DoCleaning()

                setmetatable(self, nil)
            end;
        };

        Properties = {}
    }
)