local Output

local Terrain = workspace:FindFirstChildWhichIsA("Terrain")

local TerrainRegion = {
    Name = "TerrainRegion",
    Methods = {},
    Metamethods = {},
}

function TerrainRegion:Constructor(...)
    local args = {...}
    local region

    if #args == 1 then
        region = args[1]
    elseif #args == 2 then
        local startVec3 = args[1]
        local endVec3 = args[2]

        region = Region3.new(
            Vector3.new(
                math.min(startVec3.X, endVec3.X),
                math.min(startVec3.Y, endVec3.Y),
                math.min(startVec3.Z, endVec3.Z)
            ),
            Vector3.new(
                math.max(startVec3.X, endVec3.X),
                math.max(startVec3.Y, endVec3.Y),
                math.max(startVec3.Z, endVec3.Z)
            )
        )
    else
        Output.error("Expected Region3 or 2 Vector3s as arguments", nil, 1)
    end

    self:ReadVoxels(region)
end

function TerrainRegion.Methods:Read(x, y, z)
    return self.MaterialArray[x][y][z], self.OccupancyArray[x][y][z]
end

function TerrainRegion.Methods:Write(x, y, z, material, occupancy)
    if material then
        self.MaterialArray[x][y][z] = material
    end
    if occupancy then
        self.OccupancyArray[x][y][z] = occupancy
    end
end

function TerrainRegion.Methods:WriteVoxels()
    Terrain:WriteVoxels(self.Region, 4, self.MaterialArray, self.OccupancyArray)
end

function TerrainRegion.Methods:ReadVoxels(region)
    if region then
        Output.assert(typeof(region == "Region3"), "Expected Region3 or nil as Argument #1, instead got %s", typeof(region), 1)
        self.Region = region
    end

    local materialArray, occupancyArray = Terrain:ReadVoxels(self.Region, 4)
    self.MaterialArray = materialArray
    self.OccupancyArray = occupancyArray
end

function TerrainRegion.Methods:CountCellsOfMaterial(material)
    if type(material) == "string" then
        material = Enum.Material[material]
    end
    Output.assert(typeof(material) == "EnumItem" and material.EnumType == Enum.Material, "Expected name of material as string or material EnumItem as Argument #1, instead got %s", typeof(material))

    local size = self.MaterialArray.Size
    local numCells = 0

    for x = 1, size.X do
        for y = 1, size.Y do
            for z = 1, size.Z do
                if self.MaterialArray[x][y][z] == material then
                    numCells += 1
                end
            end
        end
    end

    return numCells
end

function TerrainRegion.Methods:GetTotalOccupancyOfMaterial(material)
    if type(material) == "string" then
        material = Enum.Material[material]
    end
    Output.assert(typeof(material) == "EnumItem" and material.EnumType == Enum.Material, "Expected name of material as string or material EnumItem as Argument #1, instead got %s", typeof(material))

    local size = self.MaterialArray.Size
    local numOccupancy = 0

    for x = 1, size.X do
        for y = 1, size.Y do
            for z = 1, size.Z do
                if self.MaterialArray[x][y][z] == material then
                    numOccupancy += self.OccupancyArray[x][y][z]
                end
            end
        end
    end

    return numOccupancy
end

function TerrainRegion:start()
    Output = self:Load("Deus.Output")

    local None = self:Load("Deus.Symbol").new("None")

    self.PublicValues = {}

    self.ReadOnlyValues = {
        Region = None,
        MaterialArray = None,
        OccupancyArray = None
    }

    return self:Load("Deus.DataType").new(self)
end

return TerrainRegion