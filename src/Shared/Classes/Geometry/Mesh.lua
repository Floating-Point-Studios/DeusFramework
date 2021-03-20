local TableUtils
local Output

local Mesh = {}

Mesh.ClassName = "Deus.Mesh"

Mesh.Extendable = true

Mesh.Replicable = true

Mesh.Methods = {}

Mesh.Events = {}

-- These do not actually count the number of faces, lines, or vertices, they are used internally for Id assignment, use #TableUtils.getKeys() for counting
Mesh.PrivateProperties = {
    -- FacesCount = 0,
    LinesCount = 0,
    VerticesCount = 0,
}

Mesh.PublicReadOnlyProperties = {
    -- Faces = {},
    Lines = {},
    Vertices = {},
    VerticesVec3 = {}
}

Mesh.PublicReadAndWriteProperties = {}

--[[
-- Creates a face from VertexId's
function Mesh.Methods:AddFace(...)
    self.FacesCount += 1

    local faceId = tostring(self.FacesCount)

    self.Faces[faceId] = {}

    self:AddVerticesToFace(faceId, ...)
end

-- Deletes a face given the FaceId
function Mesh.Methods:DeleteFace(faceId)
    local face = self.Faces[faceId]

    Output.assert(faceId, "FaceId '%s' is not a face", faceId)

    for _,vertexId in pairs(face) do
        TableUtils.remove(self.Vertices[vertexId].Faces, faceId)
    end

    self.Faces[faceId] = nil
end

-- Adds vertices to a face
function Mesh.Methods:AddVerticesToFace(faceId, ...)
    local face = self.Faces[faceId]

    Output.assert(faceId, "FaceId '%s' is not a face", faceId)

    for _,vertexId in pairs(...) do
        local vertex = self.Vertices[vertexId]

        Output.assert(vertex, "VertexId '%s' is not a vertex", vertexId)

        table.insert(face, vertexId)
        table.insert(vertex.Faces, faceId)
    end
end
]]

-- Creates a line from 2 VertexId's and returns the LineId
function Mesh.Methods:AddLine(vertexId1, vertexId2)
    local vertex1
    local vertex2

    if type(vertexId1) == "number" then
        vertexId1 = tostring(vertexId1)
        vertex1 = self.Vertices[vertexId1]
    elseif type(vertexId1) == "string" then
        vertex1 = self.Vertices[vertexId1]
    elseif typeof(vertex1) == "Vector3" then
        vertex1 = self.VerticesVec3[vertexId1]
    end

    if type(vertexId2) == "number" then
        vertexId2 = tostring(vertexId2)
        vertex2 = self.Vertices[vertexId2]
    elseif type(vertexId2) == "string" then
        vertex2 = self.Vertices[vertexId2]
    elseif typeof(vertexId2) == "Vector3" then
        vertex2 = self.VerticesVec3[vertexId2]
    end

    Output.assert(vertex1, "VertexId '%s' is not a vertex", tostring(vertexId1), 1)
    Output.assert(vertex2, "VertexId '%s' is not a vertex", tostring(vertexId2), 1)

    if vertexId1 == vertexId2 then
        -- Same vertices provided for both arguments
        return
    end

    local lineId = vertex1.Lines[vertexId2] or vertex2.Lines[vertexId1]
    if lineId then
        -- The line already exists
        return lineId
    end

    self.LinesCount += 1

    lineId = tostring(self.LinesCount)

    self.Lines[lineId] = {vertexId1, vertexId2}

    vertex1.Lines[vertexId2] = lineId
    vertex2.Lines[vertexId1] = lineId

    return lineId
end

-- Deletes a line from LineId
function Mesh.Methods:DeleteLine(lineId)
    lineId = tostring(lineId)
    local line = self.Lines[lineId]

    Output.assert(line, "LineId '%s' is not a line", lineId, 1)

    local vertexId1 = line[1]
    local vertexId2 = line[2]
    local vertex1 = self.Vertices[vertexId1]
    local vertex2 = self.Vertices[vertexId2]

    vertex1.Lines[vertexId2] = nil
    vertex2.Lines[vertexId1] = nil

    self.Lines[lineId] = nil
end

-- Creates a new vertex and returns the VertexId
function Mesh.Methods:AddVertex(pos)
    Output.assert(typeof(pos) == "Vector3", "'%s' is not a Vector3", pos, 1)

    local vertexId = self.VerticesVec3[pos]
    if vertexId then
        return vertexId
    end

    self.VerticesCount += 1

    local vertex = {
        VertexId = tostring(self.VerticesCount),
        Position = pos,
        --Faces = {},
        Lines = {}
    }

    self.Vertices[vertex.VertexId] = vertex
    self.VerticesVec3[pos] = vertex.VertexId

    return vertex.VertexId
end

-- Deletes a vertex from VertexId
function Mesh.Methods:DeleteVertex(vertexId)
    vertexId = tostring(vertexId)
    local vertex = self.Vertices[vertexId]

    Output.assert(vertex, "VertexId '%s' is not a vertex", vertexId, 1)

    for _,lineId in pairs(vertex.Lines) do
        self:DeleteLine(lineId)
    end

    --[[
    for _,faceId in pairs(vertex.Faces) do
        self:DeleteFace(faceId)
    end
    ]]

    self.Vertices[vertexId] = nil
end

-- Always merges vertex 2 into vertex 1
function Mesh.Methods:MergeVertices(vertexId1, vertexId2)
    vertexId1 = tostring(vertexId1)
    vertexId2 = tostring(vertexId2)

    local vertex1 = self.Vertices[vertexId1]
    local vertex2 = self.Vertices[vertexId2]

    Output.assert(vertex1, "VertexId '%s' is not a vertex", vertexId1, 1)
    Output.assert(vertex2, "VertexId '%s' is not a vertex", vertexId2, 1)

    for vertexId in pairs(vertex2.Lines) do
        self:AddLine(vertexId, vertexId1)
    end

    self:DeleteVertex(vertexId2)
end

-- Sets the position of a vertex from the VertexId
function Mesh.Methods:SetVertexPosition(vertexId, pos)
    vertexId = tostring(vertexId)

    local vertex = self.Vertices[vertexId]

    Output.assert(vertex, "VertexId '%s' is not a vertex", vertexId, 1)
    Output.assert(typeof(pos) == "Vector3", "'%s' is not a Vector3", pos, 1)

    vertex.Position = pos
end

-- Deletes the line between 2 vertices given 2 VertexId's
function Mesh.Methods:UnlinkVertices(vertexId1, vertexId2)
    vertexId1 = tostring(vertexId1)
    vertexId2 = tostring(vertexId2)

    local vertex1 = self.Vertices[vertexId1]

    Output.assert(vertex1, "VertexId '%s' is not a vertex", vertexId1, 1)

    self:DeleteLine(vertex1.Lines[vertexId2])
end

function Mesh.Methods:GetLinkedVertices(vertexId)
    vertexId = tostring(vertexId)

    local vertex = self.Vertices[vertexId]

    Output.assert(vertex, "VertexId '%s' is not a vertex", vertexId, 1)

    return TableUtils.getKeys(vertex.Lines)
end

function Mesh.Methods:GetVertices()
    return TableUtils.getValues(self.Vertices)
end

function Mesh.Methods:GetLines()
    return TableUtils.getValues(self.Lines)
end

-- Returns vertices within the radius of the given position
function Mesh.Methods:GetVerticesInRadius(pos, radius)
    Output.assert(typeof(pos) == "Vector3", "'%s' is not a Vector3", pos, 1)
    Output.assert(type(radius) == "number", "'%s' is not a number", radius, 1)

    local vertices = {}

    for _,vertex in pairs(self.Vertices) do
        if (vertex.Position - pos).Magnitude < radius then
            table.insert(vertices, vertex)
        end
    end

    return vertices
end

-- Returns vertices in order of distance of the given position
function Mesh.Methods:GetVerticesByDistance(pos)
    Output.assert(typeof(pos) == "Vector3", "'%s' is not a Vector3", pos, 1)

    local vertices = TableUtils.getValues(self.Vertices)

    table.sort(vertices, function(a, b)
        return (a.Position - pos).Magnitude < (b.Position - pos).Magnitude
    end)

    return vertices
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

function Mesh.Methods:MergeVerticesByDistance(distance, mergeMode)
    local merges = 0
    for _,vertex1 in pairs(self.Vertices) do
        local vertices = self:GetVerticesInRadius(vertex1.Position, distance)

        for i = 2, #vertices do
            local vertex2 = vertices[i]
            if vertex1 ~= vertex2 then
                merges += 1
                self:MergeVertices(vertex1.VertexId, vertex2.VertexId)
            end
        end
    end
    return merges
end

function Mesh.Methods:Translate(vec3)
    if type(vec3) == "number" then
        vec3 = Vector3.new(vec3, vec3, vec3)
    end

    Output.assert(typeof(vec3) == "Vector3", "'%s' is not a Vector3", vec3, 1)

    for _,vertex in pairs(self.Vertices) do
        self:SetVertexPosition(vertex.VertexId, vertex.Position + vec3)
    end

    return self
end

function Mesh.Methods:Scale(vec3)
    Output.assert(typeof(vec3) == "Vector3" or type(vec3) == "number", "'%s' is not a Vector3 or number", vec3, 1)

    for _,vertex in pairs(self.Vertices) do
        self:SetVertexPosition(vertex.VertexId, vertex.Position * vec3)
    end

    return self
end

function Mesh:start()
    TableUtils = self:Load("Deus.TableUtils")
    Output = self:Load("Deus.Output")

    return self:Load("Deus.BaseObject").new(self)
end

return Mesh