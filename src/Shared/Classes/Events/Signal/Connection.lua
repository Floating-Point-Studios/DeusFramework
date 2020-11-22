local Deus = shared.DeusFramework

local TableProxy = Deus:Load("Deus/TableProxy")

local ConnectionMetatables = setmetatable({}, {__mode = "kv"})

local Connection = {}

function Connection.new(func)
    local self, metatable = TableProxy.new(
        {
            __index = Connection;

            Internals = {
                Connected = true;
                Func = func;
            };
        }
    )

    ConnectionMetatables[self] = metatable

    return self, metatable
end

function Connection:Disconnect()
    self = ConnectionMetatables[self]
    self.Connected = false
    self.Func = nil
end

return Connection