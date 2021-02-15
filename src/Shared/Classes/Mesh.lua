local TableUtils
local Output

local Mesh = {}

Mesh.ClassName = "Deus.Mesh"

Mesh.Extendable = true

Mesh.Replicable = true

Mesh.Methods = {}

Mesh.Events = {}

Mesh.PrivateProperties = {}

Mesh.PublicReadOnlyProperties = {
    VerticesCount = 0,
    LinesCount = 0,
    Lines = {},
    Vertices = {},
    VerticesVec3 = {}
}

Mesh.PublicReadAndWriteProperties = {}

-- Creates a line from 2 VertexId's and returns the LineId
function Mesh.Methods:AddLine(_, vertexId1, vertexId2)
    local vertex1 = self.Vertices[vertexId1]
    local vertex2 = self.Vertices[vertexId2]

    Output.assert(vertex1, "VertexId '%s' is not a vertex", vertexId1)
    Output.assert(vertex2, "VertexId '%s' is not a vertex", vertexId2)

    self.LinesCount += 1

    local lineId = tostring(self.LinesCount)

    self.Lines[lineId] = {vertexId1, vertexId2}

    vertex1.Lines[vertexId2] = lineId
    vertex2.Lines[vertexId1] = lineId

    return lineId
end

-- Deletes a line from LineId
function Mesh.Methods:DeleteLine(lineId)
    local line = self.Lines[lineId]

    Output.assert(line, "LineId '%s' is not a line", lineId)

    local vertexId1 = line[1]
    local vertexId2 = line[2]
    local vertex1 = self.Vertices[vertexId1]
    local vertex2 = self.Vertices[vertexId2]

    vertex1.Lines[vertexId2] = nil
    vertex2.Lines[vertexId1] = nil

    self.Lines[lineId] = nil
end

-- Creates a new vertex and returns the VertexId
function Mesh.Methods:AddVertex(_, pos)
    Output.assert(not self.VerticesVec3[pos], "Vertex '%s' already exists", tostring(pos))

    self.VerticesCount += 1

    local vertex = {
        VertexId = tostring(self.VerticesCount),
        Position = pos,
        Lines = {}
    }

    self.Vertices[vertex.VertexId] = vertex
    self.VerticesVec3[pos] = vertex.VertexId

    return vertex.VertexId
end

-- Deletes a vertex from VertexId
function Mesh.Methods:DeleteVertex(_, vertexId)
    local vertex = self.Vertices[vertexId]

    Output.assert(vertex, "VertexId '%s' is not a vertex", vertexId)

    for _,lineId in pairs(vertex.Lines) do
        self:DeleteLine(lineId)
    end

    self.Vertices[vertexId] = nil
end

-- Sets the position of a vertex from the VertexId
function Mesh.Methods:SetVertexPosition(_, vertexId, pos)
    local vertex = self.Vertices[vertexId]

    Output.assert(vertex, "VertexId '%s' is not a vertex", vertexId)

    vertex.Position = pos
end

-- Deletes the line between 2 vertices given 2 VertexId's
function Mesh.Methods:UnlinkVertices(_, vertexId1, vertexId2)
    local vertex1 = self.Vertices[vertexId1]

    Output.assert(vertex1, "VertexId '%s' is not a vertex", vertexId1)

    self:DeleteLine(vertex1.Lines[vertexId2])
end

function Mesh.Methods:GetLinkedVertices(_, vertexId)
    local vertex = self.Vertices[vertexId]

    Output.assert(vertex, "VertexId '%s' is not a vertex", vertexId)

    return TableUtils.getKeys(vertex.Lines)
end

function Mesh.Methods:GetVertices()
    return TableUtils.getValues(self.Vertices)
end

function Mesh.Methods:GetLines()
    return TableUtils.getValues(self.Lines)
end

-- Returns all vertices in an array of Vector3's
function Mesh.Methods:GetVerticesAsVector3()
    local vertices = {}

    for _,vertex in pairs(self.Vertices) do
        table.insert(vertices, vertex.Position)
    end

    return vertices
end

-- Returns all lines in an array of arrays containing the start and end of the line as a Vector3
function Mesh.Methods:GetLinesAsVector3()
    local lines = {}

    for _,line in pairs(self.Lines) do
        table.insert(lines, {
            self.Vertices[line[1]].Position,
            self.Vertices[line[2]].Position,
        })
    end

    return lines
end

function Mesh.Methods:AddVector3(_, vec3)
    if type(vec3) == "number" then
        vec3 = Vector3.new(vec3, vec3, vec3)
    end

    for _,vertex in pairs(self.Vertices) do
        self:SetVertexPosition(vertex.VertexId, vertex.Position + vec3)
    end
end

function Mesh.Methods:MultiplyVector3(_, vec3)
    for _,vertex in pairs(self.Vertices) do
        self:SetVertexPosition(vertex.VertexId, vertex.Position * vec3)
    end
end

function Mesh.start()
    TableUtils = Mesh:Load("Deus.TableUtils")
    Output = Mesh:Load("Deus.Output")

    return Mesh:Load("Deus.BaseObject").new(Mesh)
end

return Mesh