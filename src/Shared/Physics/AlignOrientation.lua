-- Similar to the AlignOrientation object but provides control over which axes it influences

local MathUtils = shared.Deus.import("Deus.MathUtils")

local AlignOrientation = {}

function AlignOrientation.new(obj, maxForce, attachment, angularVelocity)
    local self = {
        -- Desired orientation in degrees
        DesiredOrientation = Vector3.new(),
        MaxForce = maxForce or Vector3.new(5000, 5000, 5000)
    }

    if not angularVelocity then
        attachment = attachment or Instance.new("Attachment", obj)
    end
    angularVelocity = angularVelocity or Instance.new("AngularVelocity")

    angularVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
    angularVelocity.MaxTorque = math.huge
    angularVelocity.Attachment0 = attachment or angularVelocity.Parent
    angularVelocity.Parent = attachment or angularVelocity.Parent
    self._angularVelocity = angularVelocity

    return setmetatable(self, {__index = AlignOrientation})
end

local PI = math.pi

function AlignOrientation:Update(magnitude, add)
    magnitude = magnitude or 1

    local desiredOrientation = self.DesiredOrientation
    local angulularVelocity = self._angularVelocity
    local obj = angulularVelocity.Parent.Parent
    local maxForce = self.MaxForce

    local goalX, goalY, goalZ = math.rad(desiredOrientation.X), math.rad(desiredOrientation.Y), math.rad(desiredOrientation.Z)
    local _,_,_,_,_, m02, m10, m11, m12, _,_, m22 = obj.CFrame:components()
	local curX, curY, curZ = math.asin(-m12), math.atan2(m02, m22), math.atan2(m10, m11)
	local diffX, diffY, diffZ = goalX - curX, goalY - curY, goalZ - curZ

    -- For instances when traversing would take more than 180 degrees
	if math.abs(diffX) > PI then
		diffX %= PI
	end
	if math.abs(diffY) > PI then
		diffY %= PI
	end
	if math.abs(diffZ) > PI then
		diffZ %= PI
	end

    if add then
        angulularVelocity.AngularVelocity += MathUtils.clampVector(Vector3.new(diffX, diffY, diffZ) * obj.Mass * magnitude, -maxForce, maxForce)
    else
        angulularVelocity.AngularVelocity = MathUtils.clampVector(Vector3.new(diffX, diffY, diffZ) * obj.Mass * magnitude, -maxForce, maxForce)
    end
end

return AlignOrientation