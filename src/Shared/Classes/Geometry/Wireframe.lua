local VisualDebug
local Output
local Symbol

local None

local function getLine(self, lineId)
    local line = self.LineAdornments[lineId]

    if not line then
        line = Instance.new("LineHandleAdornment")
        line.Parent = self.Wires
        self.LineAdornments[lineId] = line
    end

    return line
end

local function getSphere(self, sphereId)
    local sphere = self.SphereAdornments[sphereId]

    if not sphere then
        sphere = Instance.new("SphereHandleAdornment")
        sphere.Parent = self.Wires
        self.SphereAdornments[sphereId] = sphere
    end

    return sphere
end

local function disableLines(self, lineIdStart, lineIdEnd)
    lineIdStart = lineIdStart or 1
    lineIdEnd = lineIdEnd or #self.LineAdornments

    for i = lineIdStart, lineIdEnd do
        self.LineAdornments[i].Visible = false
    end
end

local function disableSpheres(self, sphereIdStart, sphereIdEnd)
    sphereIdStart = sphereIdStart or 1
    sphereIdEnd = sphereIdEnd or #self.SphereAdornments

    for i = sphereIdStart, sphereIdEnd do
        self.SphereAdornments[i].Visible = false
    end
end

local Wireframe = {
    ClassName = "Wireframe",
    Events = {}
}

function Wireframe:Constructor(mesh, adornee)
    self.Adornee = adornee or None
    self.Mesh = mesh or None
    self.Wires = Instance.new("Folder")

    if mesh then
        self:Update()
    end
end

function Wireframe:Deconstructor()
   self.Wires:Destroy()
end

function Wireframe:Update()
    local mesh = self.Mesh
    Output.assert(mesh ~= None, "Mesh has not been set to Wireframe", nil, 1)

    if self.ShowVertices then
        local i = 1
        for _,vertex in pairs(mesh:GetVertices()) do
            local sphere = getSphere(self, i)

            sphere.Visible = true
            sphere.Color3 = self.Color3
            sphere.Adornee = self.Adornee
            sphere.Radius = self.VertexRadius
            sphere.CFrame = CFrame.new(vertex.Position)
            if self.ShowVertexId then
                local gui = sphere:FindFirstChild("Id")
                if gui then
                    gui.TextLabel.Text = vertex.VertexId
                else
                    gui = VisualDebug.makeBillboardGui("Id", Vector2.new(1, 1), vertex.VertexId)
                    gui.Parent = sphere
                end
                gui.Adornee = self.Adornee
                gui.StudsOffsetWorldSpace = vertex.Position
            end

            i += 1
        end
        disableSpheres(self, i)
    else
        disableSpheres(self)
    end

    if self.ShowLines then
        local i = 1
        for _,lineData in pairs(mesh:GetLinesAsVector3()) do
            local linePos1 = lineData[1]
            local linePos2 = lineData[2]
            local line = getLine(self, i)

            line.Visible = true
            line.Color3 = self.Color3
            line.Adornee = self.Adornee
            line.Thickness = self.LineThickness
            line.CFrame = CFrame.lookAt(linePos1, linePos2)
            line.Length = (linePos2 - linePos1).Magnitude

            i += 1
        end
        disableLines(self, i)
    else
        disableLines(self)
    end
end

function Wireframe:start()
    VisualDebug = self:Load("Deus.VisualDebug")
    Output = self:Load("Deus.Output")
    Symbol = self:Load("Deus.Symbol")

    None = Symbol.new("None")

    self.PrivateProperties = {
        LineAdornments = {},
        SphereAdornments = {}
    }

    self.PublicReadOnlyProperties = {
        Wires = None
    }

    self.PublicReadAndWriteProperties = {
        Adornee = None,
        Mesh = None,
        ShowLines = true,
        ShowVertices = true,
        ShowLineId = false,
        ShowVertexId = false,
        LineThickness = 1,
        VertexRadius = 0.01,
        Color3 = Color3.new(1, 1, 1)
    }

    return self:Load("Deus.BaseObject").new(self)
end

return Wireframe