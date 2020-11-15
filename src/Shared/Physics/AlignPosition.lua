-- Similar to the AlignPosition object but provides control over which axes it influences

local PID = shared.Deus.import("Deus.PID")

local AlignPosition = {}

function AlignPosition.new(obj, kP, kI, kD, maxForce, attachment, vectorForce)
    local self = {
        _PIDx = PID.new(kP, kI, kD, 0),
        _PIDy = PID.new(kP, kI, kD, 0),
        _PIDz = PID.new(kP, kI, kD, 0),

        DesiredPosition = Vector3.new(),
        MaxForce = maxForce or Vector3.new(5000, 5000, 5000),
    }

    if not vectorForce then
        attachment = attachment or Instance.new("Attachment", obj)
    end
    vectorForce = vectorForce or Instance.new("VectorForce")

    vectorForce.Force = Vector3.new()
    vectorForce.RelativeTo = Enum.ActuatorRelativeTo.World
    vectorForce.Attachment0 = attachment
    vectorForce.Parent = attachment
    self._vectorForce = vectorForce

    return setmetatable(self, {__index = AlignPosition})
end

function AlignPosition:Update(magnitude)
    local maxForce = self.MaxForce
    local vectorForce = self._vectorForce
    local currentPos = vectorForce.Parent.Parent.Position
    local desiredPos = self.DesiredPosition

    local forceX = math.clamp(self._PIDx:Update(desiredPos.X - currentPos.X) * magnitude, -maxForce.X, maxForce.X)
    local forceY = math.clamp(self._PIDy:Update(desiredPos.Y - currentPos.Y) * magnitude, -maxForce.Y, maxForce.Y)
    local forceZ = math.clamp(self._PIDz:Update(desiredPos.Z - currentPos.Z) * magnitude, -maxForce.Z, maxForce.Z)

    vectorForce.Force = Vector3.new(forceX, forceY, forceZ)
end

return AlignPosition