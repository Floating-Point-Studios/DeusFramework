-- TODO: Convert this to a DataType

local Pool = {
    ClassName = "Pool",
    Events = {}
}

-- Gets all the items from the pool and set itself to empty
function Pool:GetAll()
    local items = self.Items

    self.Items = {}

    return items
end

-- Gets an item from the pool, if one is not available runs the newItemFunc function provided in constructor
function Pool:Get()
    local item = self.Items[1]

    if item then
        table.remove(self.Items, 1)
        return item
    else
        return self.NewItemFunc()
    end
end

-- This should be run when done using the item to return it back to the pool
function Pool:Add(item)
    table.insert(self.Items, item)
end

function Pool:Constructor(newItemFunc)
    self.NewItemFunc = newItemFunc
end

-- Destroys everything in the pool
function Pool:Destructor()
    return self.Items
end

function Pool:start()
    self.Private = {
        NewItemFunc = self:Load("Deus.Symbol").get("None"),
        Items = {}
    }

    self.Readable = {}

    self.Writable = {}

    return self:Load("Deus.BaseObject").new(self)
end

return Pool