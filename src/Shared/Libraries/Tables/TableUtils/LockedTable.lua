local Output
local TableUtils

local LockedTable = {}

function __index(self, i)
    local v = rawget(self, "Original")[i] or LockedTable[i]
    -- Output.assert(v, "'%s' does not exist in read-only table", i)
    return v
end

function __newindex(_, i)
    Output.error("Cannot modify '%s' in read-only table", i, 2)
end

function LockedTable:Copy()
    return TableUtils.deepCopy(self)
end

function LockedTable:GetKeys()
    return TableUtils.getKeys(self)
end

function LockedTable:GetValues()
    return TableUtils.getValues(self)
end

function LockedTable.new(tab)
    local proxy = newproxy(true)
    local meta = getmetatable(proxy)

    meta.__index = __index
    meta.__newindex = __newindex
    meta.__metatable = ("[%s] Requested metatable of read-only table is locked"):format(getfenv(2).script.Name)

    meta.Original = tab

    return proxy
end

function LockedTable.start()
    Output = LockedTable:Load("Deus.Output")
    TableUtils = LockedTable:Load("Deus.TableUtils")
end

return LockedTable