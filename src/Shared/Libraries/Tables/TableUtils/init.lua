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

function TableUtils.isEmpty(tab)
    for _ in pairs(tab) do
        return false
    end
    return true
end

-- Behaves differently from table.create(), if the value is a empty table then the tables will not share the same memory address
function TableUtils.create(count, value)
    if type(value) == "table" and TableUtils.isEmpty(value) then
        local tab = {}
        for _ = 1, count do
            table.insert(tab, {})
        end
        return tab
    else
        return table.create(count, value)
    end
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
            table.insert(packedTab, v)
        end
    end
    return unpack(packedTab)
end

function TableUtils.remove(tab, index)
    if type(index) == "number" then
        tab[index] = nil
    else
        local i = table.find(tab, index)
        if i then
            table.remove(tab, i)
        end
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

-- Returns the sum of a array of numbers
function TableUtils.sum(tab)
    local sum = tab[1]
    for i = 2, #tab do
        sum += tab[i]
    end
    return sum
end

-- Returns the average of a array of numbers
function TableUtils.average(tab)
    return TableUtils.sum(tab) / #tab
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
                Output.error("'%s' is not a valid member of %s", {i, obj}, 2)
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
                Output.error("'%s' is not a valid member of %s", {i, obj}, 2)
            end
        end
    end
end

function TableUtils:start()
    Output = self:Load("Deus.Output")

    TableUtils.lock = self:WrapModule(script.LockedTable, true, true).new
end
return TableUtils