local Output

local None

local Array2D = {}

Array2D.ClassName = "Deus.Array2D"

Array2D.Extendable = true

Array2D.Replicable = true

Array2D.Methods = {}

Array2D.Events = {}

function Array2D.Methods:Set(x, y, v)
    x = math.floor(x)
    y = math.floor(y)

    local size = self.Size
    Output.assert(x >= 1 and x <= size.X, "X %s is out of range 1-%s", {x, size.X})
    Output.assert(y >= 1 and y <= size.Y, "Y %s is out of range 1-%s", {y, size.Y})


    if v == nil then
        self.Array[x][y] = None
        return
    end
    self.Array[x][y] = v
end

function Array2D.Methods:Get(x, y)
    x = math.floor(x)
    y = math.floor(y)

    local size = self.Size
    Output.assert(x >= 1 and x <= size.X, "X %s is out of range 1-%s", {x, size.X})
    Output.assert(y >= 1 and y <= size.Y, "Y %s is out of range 1-%s", {y, size.Y})

    local v = self.Array[x][y]

    if v == None then
        return nil
    end

    return v
end

function Array2D.Methods:Multiset(x0, y0, x1, y1, v)
    x0 = math.floor(x0)
    y0 = math.floor(y0)
    x1 = math.floor(x1)
    y1 = math.floor(y1)

    local size = self.Size
    Output.assert(x0 >= 1, "X0 %s is out of range 1-%s", {x0, size.X})
    Output.assert(y0 >= 1, "Y0 %s is out of range 1-%s", {y1, size.X})
    Output.assert(x1 <= size.X, "X1 %s is out of range 1-%s", {x1, size.X})
    Output.assert(y1 <= size.Y, "Y1 %s is out of range 1-%s", {y1, size.Y})

    if v == nil then
        v = None
    end

    for x = x0, x1 do
        for y = y0, y1 do
            self.Array[x][y] = v
        end
    end
end

function Array2D:Constructor(sizeX, sizeY, v)
    if v == nil then
        v = None
    end

    self.Array = table.create(sizeX, table.create(sizeY, v))
    self.Size = Vector2.new(sizeX, sizeY)
end

function Array2D:start()
    Output = self:Load("Deus.Output")

    None = self:Load("Deus.Symbol").new("None")

    self.PrivateProperties = {
        Array = None
    }

    self.PublicReadOnlyProperties = {
        Size = Vector2.new()
    }

    self.PublicReadAndWriteProperties = {}

    return self:Load("Deus.BaseObject").new(self)
end

return Array2D