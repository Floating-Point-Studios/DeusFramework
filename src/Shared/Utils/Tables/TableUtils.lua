local Deus = shared.DeusFramework

local Debug = Deus:Load("Deus/Debug")

local TableUtils = {}

function TableUtils.shallowCopy(tab)
    local copy = {}
    for i, v in pairs(tab) do
        copy[i] = v
    end
    return copy
end

function TableUtils.deepCopy(tab)
    local copy = {}
    for i, v in pairs(tab) do
        if type(v) == "table" then
            v = TableUtils.DeepCopy(v)
        end
        copy[i] = v
    end
    return copy
end

function TableUtils.getKeys(tab)
    local keys = {}
    for i in pairs(tab) do
        table.insert(keys, i)
    end
    return keys
end

function TableUtils.getValues(tab)
    local values = {}
    for _,v in pairs(tab) do
        table.insert(values, v)
    end
    return values
end

-- Merges dictionaries together, for merging arrays use {TableUtils.unpack(...)}
function TableUtils.merge(tab1, ...)
    for _,tab2 in pairs({...}) do
        for i,v in pairs(tab2) do
            tab1[i] = v
        end
    end
    return tab1
end

-- Allows unpacking of multiple tables
function TableUtils.unpack(tab1, ...)
    for _,tab2 in pairs({...}) do
        for _,v in pairs(tab2) do
            table.insert(tab1, v)
        end
    end
    return tab1
end

function TableUtils.lock(tab)
    local userdata = newproxy(true)
    local metatable = getmetatable(userdata)

    function metatable:__index(i)
        local v = tab[i]
        Debug.assert(v, "'%s' does not exist in read-only table", i)
        return v
    end

    function metatable:__newindex(i, v)
        Debug.error(2, "Cannot modify '%s' in read-only table", i)
    end

    metatable.__metatable = ("[%s] Requested metatable of read-only table is locked"):format(getfenv(2).script.Name)

    return userdata
end

return TableUtils