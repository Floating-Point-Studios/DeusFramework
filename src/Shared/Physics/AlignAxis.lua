-- Similar to the AlignPosition object but provides control over which axises it influences

local PID = shared.Deus.import("Deus.PID")

local AlignAxis = {}

function AlignAxis.new(obj, kP, kI, kD, maxForce)
    local self = {
        _PIDx = PID.new(kP, kI, kD, 0),
        _PIDy = PID.new(kP, kI, kD, 0),
        _PIDz = PID.new(kP, kI, kD, 0),

        DesiredPosition = Vector3.new(),
        MaxForce = maxForce or Vector3.new(5000, 5000, 5000),
    }

    local attachment = Instance.new("Attachment", obj)
    local vectorForce = Instance.new("VectorForce")
    vectorForce.Force = Vector3.new()
    vectorForce.RelativeTo = Enum.ActuatorRelativeTo.World
    vectorForce.Attachment0 = attachment
    vectorForce.Parent = attachment
    self._vectorForce = vectorForce

    return setmetatable(self, {__index = AlignAxis})
end

function AlignAxis:Update(magnitude)
    local maxForce = self.MaxForce
    local currentPos = self._vectorForce.Parent.Parent.Position
    local desiredPos = self.DesiredPosition

    local forceX = math.clamp(self._PIDx:Update(desiredPos.X - currentPos.X) * magnitude, -maxForce.X, maxForce.X)
    local forceY = math.clamp(self._PIDy:Update(desiredPos.Y - currentPos.Y) * magnitude, -maxForce.Y, maxForce.Y)
    local forceZ = math.clamp(self._PIDz:Update(desiredPos.Z - currentPos.Z) * magnitude, -maxForce.Z, maxForce.Z)

    self._vectorForce.Force = Vector3.new(forceX, forceY, forceZ)
end

return AlignAxis