local Output

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
            v = TableUtils.deepCopy(v)
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
function TableUtils.merge(...)
    local mergedTab = {}
    for _,tab in pairs({...}) do
        for i,v in pairs(tab) do
            mergedTab[i] = v
        end
    end
    return mergedTab
end

-- Allows unpacking of multiple tables
function TableUtils.unpack(...)
    local packedTab = {}
    for _,tab in pairs({...}) do
        for _,v in pairs(tab) do
            table.insert(tab, v)
        end
    end
    return unpack(packedTab)
end

function TableUtils.remove(tab, index)
    if type(index) == "number" then
        tab[index] = nil
    else
        table.remove(tab, table.find(tab, index))
    end
end

function TableUtils.sub(tab, indexStart, indexEnd)
    indexEnd = indexEnd or #tab
    local output = {}

    for i = indexStart, indexEnd do
        table.insert(output, tab[i])
    end

    return output
end

-- Returns the sum of a table of numbers
function TableUtils.sum(tab)
    local sum = 0
    for _,v in pairs(tab) do
        sum += v
    end
    return sum
end

function TableUtils.lock(tab)
    local proxy = newproxy(true)
    local meta = getmetatable(proxy)

    function meta.__index(_, i)
        print(i)
        local v = tab[i]
        -- Output.assert(v, "'%s' does not exist in read-only table", i)
        return v
    end

    function meta.__newindex(_, i)
        Output.error(2, "Cannot modify '%s' in read-only table", i)
    end

    function meta:Copy()
        return TableUtils.deepCopy(tab)
    end

    function meta:GetKeys()
        return TableUtils.getKeys(tab)
    end

    function meta:GetValues()
        return TableUtils.getValues(tab)
    end

    meta.__metatable = ("[%s] Requested metatable of read-only table is locked"):format(getfenv(2).script.Name)

    return meta
end

-- ALlows setting an instance to __index of a metatable
function TableUtils.instanceAsIndex(obj)
    return function(self, i)
        local v = rawget(self, i)
        if v then
            return v
        else
            local success, v = pcall(function()
                return obj[i]
            end)

            if success then
                return v
            else
                Output.error(2, "'%s' is not a valid member of %s", i, obj)
            end
        end
    end
end

-- ALlows setting an instance to __newindex of a metatable
function TableUtils.instanceAsNewIndex(obj)
    return function(self, i, v)
        if rawget(self, i) then
            rawset(self, i, v)
            return
        else
            local success = pcall(function()
                obj[i] = v
            end)

            if success then
                return v
            else
                Output.error(2, "'%s' is not a valid member of %s", i, obj)
            end
        end
    end
end

function TableUtils.start()
    Output = TableUtils:Load("Deus.Output")
end

return TableUtils