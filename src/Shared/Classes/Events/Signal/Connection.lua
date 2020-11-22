local Deus = shared.DeusFramework

local TableProxy = Deus:Load("Deus/TableProxy")

local Connection = {}

function Connection.new(func)
    local self, metatable = TableProxy.new(
        {
            Func = func;
        },
        {
            Connected = true;
        }
    )

    metatable.__index = Connection

    return self, metatable
end

function Connection:Disconnect()
    local _,metatable = TableProxy.isInternalAccess(self)
    metatable.__internals.Func = nil
    metatable.__externals.Connected = false
end

return Connection