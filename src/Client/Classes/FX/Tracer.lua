local Debug = shared.Deus.import("Deus.Debug")

local Tracer = {}

local Terrain = workspace.Terrain

function Tracer.new(size: number?, parent: instance?, properties)
    local self = {
        _size = (size or 0.1) / 2,
        Attachment0 = Instance.new("Attachment", parent or Terrain),
        Attachment1 = Instance.new("Attachment", parent or Terrain),
        Trail = Instance.new("Trail")
    }

    for i,v in pairs(properties) do
        self.Trail[i] = v
    end

    self.Trail.Attachment0 = self.Attachment0
    self.Trail.Attachment1 = self.Attachment1
    self.Trail.Parent = self.Attachment0

    setmetatable(self, Tracer)

    return setmetatable(self, {__index = Tracer})
end

function Tracer:__newindex(index, value)
    Debug.assert(index, ("%q is not a valid member of Tracer"):format(tostring(index)))
    if index == "CFrame" then
        self.Attachment0.CFrame = value + value.UpVector * self._size
        self.Attachment1.CFrame = value - value.UpVector * self._size
    elseif index == "Position" or index == "p" then
        self.Attachment0.Position = value + Vector3.new(0, self._size, 0)
        self.Attachment1.Position = value - Vector3.new(0, self._size, 0)
    end
end

function Tracer:Destroy()
    self.Attachment0:Destroy()
    self.Attachment1:Destroy()
end

return Tracer