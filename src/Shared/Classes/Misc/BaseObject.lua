local import = shared.DeusFramework:Import

return import("Deus/BaseClass").new("Deus/BaseObject", {

    Events = {"TestEvent1"};

    Internals = {
        __index = function(self, i)
            return self.Children[i]
        end;

        __newindex = function(self, i, v)
            self.Children[i] = v
        end;

        Children = {};
    };

    Methods = {
        Clone = function(self)
            print("I am being cloned!")
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
})