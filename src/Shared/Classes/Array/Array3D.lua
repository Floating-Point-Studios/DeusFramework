local Output

local None

local Array3D = {}

Array3D.ClassName = "Deus.Array3D"

Array3D.Extendable = true

Array3D.Replicable = true

Array3D.Methods = {}

Array3D.Events = {}

function Array3D.Methods:Set(x, y, z, v)
    x = math.floor(x)
    y = math.floor(y)
    z = math.floor(z)

    local size = self.Size
    Output.assert(x >= 1 and x <= size.X, "X %s is out of range 1-%s", {x, size.X})
    Output.assert(y >= 1 and y <= size.Y, "Y %s is out of range 1-%s", {y, size.Y})
    Output.assert(z >= 1 and z <= size.Z, "Z %s is out of range 1-%s", {z, size.Z})


    if v == nil then
        self.Array[x][y][z] = None
        return
    end
    self.Array[x][y][z] = v
end

function Array3D.Methods:Get(x, y, z)
    x = math.floor(x)
    y = math.floor(y)
    z = math.floor(y)

    local size = self.Size
    Output.assert(x >= 1 and x <= size.X, "X %s is out of range 1-%s", {x, size.X})
    Output.assert(y >= 1 and y <= size.Y, "Y %s is out of range 1-%s", {y, size.Y})
    Output.assert(z >= 1 and z <= size.Z, "Z %s is out of range 1-%s", {z, size.Z})

    local v = self.Array[x][y][z]

    if v == None then
        return nil
    end

    return v
end

function Array3D.Methods:Multiset(x0, y0, z0, x1, y1, z1, v)
    x0 = math.floor(x0)
    y0 = math.floor(y0)
    z0 = math.floor(z0)
    x1 = math.floor(x1)
    y1 = math.floor(y1)
    z1 = math.floor(z1)

    local size = self.Size
    Output.assert(x0 >= 1, "X0 %s is out of range 1-%s", {x0, size.X})
    Output.assert(y0 >= 1, "Y0 %s is out of range 1-%s", {y0, size.Y})
    Output.assert(z0 >= 1, "Z0 %s is out of range 1-%s", {z0, size.Z})
    Output.assert(x1 <= size.X, "X1 %s is out of range 1-%s", {x1, size.X})
    Output.assert(y1 <= size.Y, "Y1 %s is out of range 1-%s", {y1, size.Y})
    Output.assert(z1 <= size.Z, "Z1 %s is out of range 1-%s", {z1, size.Z})

    if v == nil then
        v = None
    end

    for x = x0, x1 do
        for y = y0, y1 do
            for z = z0, z1 do
                self.Array[x][y][z] = v
            end
        end
    end
end

function Array3D:Constructor(sizeX, sizeY, sizeZ, v)
    if v == nil then
        v = None
    end

    self.Array = table.create(sizeX, table.create(sizeY, table.create(sizeZ, v)))
    self.Size = Vector3.new(sizeX, sizeY, sizeZ)
end

function Array3D:start()
    Output = self:Load("Deus.Output")

    None = self:Load("Deus.Symbol").new("None")

    self.PrivateProperties = {
        Array = None
    }

    self.PublicReadOnlyProperties = {
        Size = Vector3.new()
    }

    self.PublicReadAndWriteProperties = {}

    return self:Load("Deus.BaseObject").new(self)
end

return Array3D