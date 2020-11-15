-- Similar to the AlignOrientation object but provides control over which axes it influences

local MathUtils = shared.Deus.import("MathUtils")

local AlignOrientation = {}

function AlignOrientation.new(obj, maxForce, attachment, angularVelocity)
    local self = {
        DesiredOrientation = Vector3.new(),
        MaxForce = maxForce or Vector3.new(5000, 5000, 5000)
    }

    if not angularVelocity then
        attachment = attachment or Instance.new("Attachment", obj)
    end
    angularVelocity = angularVelocity or Instance.new("AngularVelocity")

    angularVelocity.Force = Vector3.new()
    angularVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
    angularVelocity.MaxTorque = math.huge
    angularVelocity.Attachment0 = attachment
    angularVelocity.Parent = attachment
    self._angularVelocity = angularVelocity

    return setmetatable(self, {__index = AlignOrientation})
end

function AlignOrientation:Update(magnitude)
    local desiredOrientation = self.DesiredOrientation
    local angulularVelocity = self._angularVelocity
    local obj = angulularVelocity.Parent.Parent
    local maxForce = self.MaxForce

    local goalX, goalY, goalZ = math.rad(desiredOrientation.X), math.rad(desiredOrientation.Y), math.rad(desiredOrientation.Z)
    local curX, curY, curZ = obj.CFrame:ToEulerAnglesYXZ()

	angulularVelocity.AngularVelocity = MathUtils.clampVector(Vector3.new(goalX - curX, goalY - curY, goalZ - curZ) * obj.Mass * magnitude, -maxForce, maxForce)
end

return AlignOrientation