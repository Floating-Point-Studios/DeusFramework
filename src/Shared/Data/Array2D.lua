local Output

local Array2D = {
    Name = "Array2D",
    Methods = {},
    Metamethods = {}
}

function Array2D.Metamethods.__index(self, i)
    if type(i) == "number" and i <= self.Size.X then
        return self.Raw[i]
    end
end

function Array2D:Constructor(x, y)
    self.Size = Vector2.new(x, y)

    for x0 = 1, x do
        self.Raw[x0] = {}
    end
end

function Array2D.Methods:Multiset(x0, y0, x1, y1, v)
    Output.assert(x0 >= 1 and x0 <= self.Size.X, "Argument #1 is out of bounds", nil, 1)
    Output.assert(y0 >= 1 and y0 <= self.Size.Y, "Argument #2 is out of bounds", nil, 1)
    Output.assert(x1 >= 1 and x1 <= self.Size.X, "Argument #3 is out of bounds", nil, 1)
    Output.assert(y1 >= 1 and y1 <= self.Size.Y, "Argument #4 is out of bounds", nil, 1)

    for x = x0, x1 do
        for y = y0, y1 do
            self[x][y] = v
        end
    end
end

function Array2D:start()
    Output = self:Load("Deus.Output")

    self.PublicValues = {}

    self.ReadOnlyValues = {
        Size = Vector2.new(),
        Raw = {}
    }

    return self:Load("Deus.DataType").new(self)
end

return Array2D