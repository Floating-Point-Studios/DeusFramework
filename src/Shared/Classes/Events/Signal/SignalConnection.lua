local Deus = shared.DeusFramework

local TableProxy = Deus:Load("Deus/TableProxy")

local ConnectionMetatables = setmetatable({}, {__mode = "kv"})

local Connection = {}

function Connection.new(func)
    local self, metatable = TableProxy.new(
        {
            __type = "RBXScriptConnection";
            __index = Connection;

            ExternalReadOnly = {
                Connected = true;
                Func = func;
            };
        }
    )

    ConnectionMetatables[self] = metatable

    return self
end

function Connection:Disconnect()
    self = ConnectionMetatables[self]
    self.Connected = false
    self.Func = nil
end

return Connection