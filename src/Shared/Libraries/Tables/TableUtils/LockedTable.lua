local Output
local TableUtils

local LockedTables = setmetatable({}, {__mode = "v"})

local LockedTable = {}

function __index(self, i)
    local v = LockedTables[self][i] or LockedTable[i]
    -- Output.assert(v, "%s does not exist in read-only table", i)
    return v
end

function __newindex(_, i)
    Output.error("Cannot modify %s in read-only table", i, 2)
end

function LockedTable:Copy()
    return TableUtils.deepCopy(LockedTables[self])
end

function LockedTable:GetKeys()
    return TableUtils.getKeys(LockedTables[self])
end

function LockedTable:GetValues()
    return TableUtils.getValues(LockedTables[self])
end

function LockedTable.new(tab)
    local proxy = newproxy(true)
    local meta = getmetatable(proxy)

    meta.__index = __index
    meta.__newindex = __newindex
    meta.__metatable = ("[%s] Requested metatable of read-only table is locked"):format(getfenv(2).script.Name)

    LockedTables[proxy] = tab

    return proxy
end

function LockedTable:start()
    Output = self:Load("Deus.Output")
    TableUtils = self:Load("Deus.TableUtils")
end

return LockedTable