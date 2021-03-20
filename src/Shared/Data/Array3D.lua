local Output

local Array3D = {
    Name = "Array3D",
    Methods = {},
    Metamethods = {}
}

function Array3D.Metamethods.__index(self, i)
    if type(i) == "number" and i <= self.Size.X then
        return self.Raw[i]
    end
end

function Array3D:Constructor(x, y, z)
    self.Size = Vector3.new(x, y, z)

    for x0 = 1, x do
        self.Raw[x0] = {}
        for y0 = 1, y do
            self.Raw[x0][y0] = {}
        end
    end
end

function Array3D.Methods:Multiset(x0, y0, z0, x1, y1, z1, v)
    Output.assert(x0 >= 1 and x0 <= self.Size.X, "Argument #1 is out of bounds", nil, 1)
    Output.assert(y0 >= 1 and y0 <= self.Size.Y, "Argument #2 is out of bounds", nil, 1)
    Output.assert(z0 >= 1 and z0 <= self.Size.Z, "Argument #3 is out of bounds", nil, 1)
    Output.assert(x1 >= 1 and x1 <= self.Size.X, "Argument #4 is out of bounds", nil, 1)
    Output.assert(y1 >= 1 and y1 <= self.Size.Y, "Argument #5 is out of bounds", nil, 1)
    Output.assert(z1 >= 1 and z1 <= self.Size.Z, "Argument #6 is out of bounds", nil, 1)

    for x = x0, x1 do
        for y = y0, y1 do
            self[x][y] = v
        end
    end
end

function Array3D:start()
    Output = self:Load("Deus.Output")

    self.PublicValues = {}

    self.ReadOnlyValues = {
        Size = Vector3.new(),
        Raw = {}
    }

    return self:Load("Deus.DataType").new(self)
end

return Array3D