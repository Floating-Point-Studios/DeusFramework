-- Similar to the AlignPosition object but provides control over which axises it influences

local PID = shared.Deus.import("Deus.PID")

local AlignAxis = {}

function AlignAxis.new(obj, kP, kI, kD, alignX, alignY, alignZ, maxForce)
    local self = {
        _PIDx = PID.new(kP, kI, kD, 0),
        _PIDy = PID.new(kP, kI, kD, 0),
        _PIDz = PID.new(kP, kI, kD, 0),

        DesiredPosition = Vector3.new(),
        AlignXAxis = alignX or true,
        AlignYAxis = alignY or true,
        AlignZAxis = alignZ or true,
        MaxForce = maxForce or 5000,
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
    local force = {x = 0, y = 0, z = 0}
    local maxForce = self.MaxForce
    local currentPos = self._vectorForce.Parent.Position
    local desiredPos = self.DesiredPosition

    if self.AlignXAxis then
        force.x = math.clamp(self._PIDx:Update(desiredPos.X - currentPos.X) * magnitude, -maxForce, maxForce)
    end
    if self.AlignYAxis then
        force.y = math.clamp(self._PIDy:Update(desiredPos.Y - currentPos.Y) * magnitude, -maxForce, maxForce)
    end
    if self.AlignZAxis then
        force.z = math.clamp(self._PIDz:Update(desiredPos.Z - currentPos.Z) * magnitude, -maxForce, maxForce)
    end

    self._vectorForce.Force = Vector3.new(force.x, force.y, force.z)
end

return AlignAxis