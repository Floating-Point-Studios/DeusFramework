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

local Wireframe = {}

Wireframe.ClassName = "Deus.Wireframe"

Wireframe.Extendable = true

Wireframe.Replicable = true

Wireframe.Methods = {}

Wireframe.Events = {}

function Wireframe.Constructor(self, mesh, adornee)
    self.Adornee = adornee or None
    self.Mesh = mesh or None
    self.Wires = Instance.new("Folder")
end

function Wireframe.Deconstructor(self)
   self.Wires:Destroy()
end

function Wireframe.Methods:Update()
    local mesh = self.Mesh
    Output.assert(mesh ~= None, "Mesh has not been set to Wireframe")

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
                    gui.Text = vertex.VertexId
                else
                    gui = VisualDebug.makeBillboardGui("Id", Vector2.new(1, 1), vertex.VertexId)
                    gui.Adornee = self.Adornee
                    gui.StudsOffsetWorldSpace = vertex.Position
                    gui.Parent = sphere
                end
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

function Wireframe.start()
    VisualDebug = Wireframe:Load("Deus.VisualDebug")
    Output = Wireframe:Load("Deus.Output")
    Symbol = Wireframe:Load("Deus.Symbol")

    None = Symbol.new("None")

    Wireframe.PrivateProperties = {
        LineAdornments = {},
        SphereAdornments = {}
    }

    Wireframe.PublicReadOnlyProperties = {
        Wires = None
    }

    Wireframe.PublicReadAndWriteProperties = {
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

    return Wireframe:Load("Deus.BaseObject").new(Wireframe)
end

return Wireframe