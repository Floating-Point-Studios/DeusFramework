-- TODO: Convert this to a DataType

local Pool = {}

Pool.ClassName = "Deus.Pool"

Pool.Extendable = true

Pool.Replicable = true

Pool.Methods = {}

Pool.Events = {}

-- Gets all the items from the pool and set itself to empty
function Pool.Methods:GetAll()
    local items = self.Items

    self.Items = {}

    return items
end

-- Gets an item from the pool, if one is not available runs the newItemFunc function provided in constructor
function Pool.Methods:Get()
    local item = self.Items[1]

    if item then
        table.remove(self.Items, 1)
        return item
    else
        return self.NewItemFunc()
    end
end

-- This should be run when done using the item to return it back to the pool
function Pool.Methods:Add(item)
    table.insert(self.Items, item)
end

function Pool:Constructor(newItemFunc)
    self.NewItemFunc = newItemFunc
end

-- Destroys everything in the pool
function Pool:Deconstructor()
    return self.Items
end

function Pool:start()
    self.PrivateProperties = {
        NewItemFunc = self:Load("Deus.Symbol").new("None"),
        Items = {}
    }

    self.PublicReadOnlyProperties = {}

    self.PublicReadAndWriteProperties = {}

    return self:Load("Deus.BaseObject").new(self)
end

return Pool