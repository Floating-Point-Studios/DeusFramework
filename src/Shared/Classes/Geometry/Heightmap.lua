-- Returns a Deus.Mesh as the heightmap

local Mesh
local MathUtils
local TableUtils
local RaycastUtils

local Heightmap = {}

function Heightmap.generate(corner0, corner1, resolution, canCollideOnly, averageNilPoints)
    local mesh = Mesh.new()
    local minSize = Vector3.new(math.min(corner0.X, corner1.X), math.min(corner0.Y, corner1.Y), math.min(corner0.Z, corner1.Z))
    local maxSize = Vector3.new(math.max(corner0.X, corner1.X), math.max(corner0.Y, corner1.Y), math.max(corner0.Z, corner1.Z))
    local resX = MathUtils.snap(resolution, MathUtils.getFactors(maxSize.X - minSize.X))
    local resZ = MathUtils.snap(resolution, MathUtils.getFactors(maxSize.Z - minSize.Z))

    local raycastStartHeight = maxSize.Y
    local raycastEndHeight = minSize.Y
    local raycastLength = raycastStartHeight - minSize.Y

    local verticesPerRow = math.abs(maxSize.X - minSize.X) / resX + 1

    local correctionVertices = {}

    for x = minSize.X, maxSize.X, resX do
        local lastVertexId

        for z = minSize.Z, maxSize.Z, resZ do
            local pos
            local raycastResult

            if canCollideOnly then
                raycastResult = RaycastUtils.castCollideOnly(Vector3.new(x, raycastStartHeight, z), Vector3.new(0, -raycastLength, 0))
            else
                raycastResult = RaycastUtils.cast(Vector3.new(x, raycastStartHeight, z), Vector3.new(0, -raycastLength, 0))
            end

            if raycastResult then
                pos = raycastResult.Position
            else
                pos = Vector3.new(x, raycastEndHeight, z)
            end

            local vertexId = mesh:AddVertex(pos)
            if lastVertexId then
                mesh:AddLine(vertexId, lastVertexId)
            end

            if pos.Y == raycastEndHeight then
                table.insert(correctionVertices, vertexId)
            end

            if x > minSize.X then
                local previousRowVertexId = tostring(vertexId - verticesPerRow)
                if mesh.Vertices[previousRowVertexId] then
                    mesh:AddLine(vertexId, previousRowVertexId)
                end
            end

            lastVertexId = vertexId
        end
    end

    if averageNilPoints then
        for _,vertexId1 in pairs(correctionVertices) do
            local pos = mesh.Vertices[vertexId1].Position

            if vertexId1 == "1" then
                -- Special edge case for the first vertex
                mesh:SetVertexPosition(vertexId1, Vector3.new(pos.X, mesh.Vertices[tostring(verticesPerRow + 2)].Position.Y, pos.Z))
            else
                local totalHeight = {}

                for _,vertexId2 in pairs(mesh:GetLinkedVertices(vertexId1)) do
                    local height = mesh.Vertices[vertexId2].Position.Y
                    if height > minSize.Y then
                        table.insert(totalHeight, height)
                    end
                end

                mesh:SetVertexPosition(vertexId1, Vector3.new(pos.X, TableUtils.sum(totalHeight) / #totalHeight, pos.Z))
            end
        end
    end

    return mesh
end

function Heightmap.start()
    Mesh = Heightmap:Load("Deus.Mesh")
    MathUtils = Heightmap:Load("Deus.MathUtils")
    TableUtils = Heightmap:Load("Deus.TableUtils")
    RaycastUtils = Heightmap:Load("Deus.RaycastUtils")
end

return Heightmap