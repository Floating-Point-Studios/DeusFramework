return shared.DeusFramework:Load("Deus/BaseClass").new("Deus/BaseObject",
    {

        Events = {"TestEvent1"};

        Internals = {
            __index = function(self, i)
                return self.Children[i]
            end;

            __newindex = function(self, i, v)
                self.Children[i] = v
                return true
            end;

            Children = {};
        };

        Methods = {
            Clone = function(self)
                print(self.TestEvent1)
                self.TestEvent1:Fire("uwu")
            end;

            Destroy = function(self)
                print("I am being destroyed!")
            end;
        };

        Properties = {
            TestProperty1 = true;
            Testproperty2 = "String";
            TestProperty3 = Vector3.new();
        };

        Constructor = function(self)
            
        end
    }
)