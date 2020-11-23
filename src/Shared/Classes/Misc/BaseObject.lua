local Deus = shared.DeusFramework

local BaseClass = Deus:Load("Deus/BaseClass")
local Maid = Deus:Load("Deus/Maid")

return BaseClass.new("Deus/BaseObject",
    {
        Events = {};

        Internals = {};

        Methods = {
            Destroy = function(self)
                self.Maid:DoCleaning()

                setmetatable(self, nil)
            end;
        };

        Properties = {
            TestProperty1 = true;
            Testproperty2 = "String";
            TestProperty3 = Vector3.new();
        };

        Constructor = function(self)
            self.__internals.Maid = Maid.new()
        end
    }
)