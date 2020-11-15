local FrictionForce = {}

function FrictionForce.new(obj, attachment, vectorForce)
    local self = {}

    if not vectorForce then
        attachment = attachment or Instance.new("Attachment", obj)
    end
    vectorForce = vectorForce or Instance.new("VectorForce")

    vectorForce.Force = Vector3.new()
    vectorForce.RelativeTo = Enum.ActuatorRelativeTo.World
    vectorForce.Attachment0 = attachment or vectorForce.Parent
    vectorForce.Parent = attachment or vectorForce.Parent
    self._vectorForce = vectorForce

    return setmetatable(self, {__index = FrictionForce})
end

function FrictionForce:Update(coefficient, additive)
    local vectorForce = self._vectorForce

    if additive then
        vectorForce.Force += -vectorForce.Parent.Parent.Velocity * coefficient
    else
        vectorForce.Force = -vectorForce.Parent.Parent.Velocity * coefficient
    end
end

return FrictionForce