local Raycaster = shared.Deus.import("Deus.Raycaster")
local BaseVehicle = shared.Deus.import("Deus.BaseVehicle")
local SuspensionThruster = shared.Deus.import("Deus.SuspensionThruster")
local PhysicsUtil = shared.Deus.import("Deus.PhysicsUtil")
local Car = shared.Deus.import("Deus.BaseClass").new("Deus/Car").Extends(BaseVehicle)

function Car.Constructor(self, vehicle, maxSpeed, maxThrottle, limit, stiffness, rigidity)
    self._vehicle = vehicle
    self._speed = 0
    self._mass = 0
    self._centerOfMass = Vector3.new()

    self.Throttle = 0
    self.Steer = 0

    self.MaxSpeed = maxSpeed or 100
    self.MaxThrottle = maxThrottle or 1

    self.Suspension = {
        _raycaster = Raycaster.new({{self._vehicle}, Enum.RaycastFilterType.Blacklist, true}, limit, true),
        _thrusters = {},

        Limit = limit or 5,
        Stiffness = stiffness or 1,
        Rigidity = rigidity or 1,
    }
end

function Car:CreateThruster(offset, turnAngle, powered, steering)
    local attachment = Instance.new("Attachment")
    local suspensionSettings = self.Suspension
    attachment.CFrame = offset
    attachment.Parent = self._vehicle.PrimaryPart
    local thruster = SuspensionThruster.new(
        self._vehicle,
        attachment,
        suspensionSettings._raycaster,
        suspensionSettings.Limit,
        suspensionSettings.Stiffness,
        suspensionSettings.Rigidity,
        turnAngle, powered, steering
    )
    table.insert(suspensionSettings._thrusters, thruster)
    return thruster
end

-- IMPORTANT: Run this after adding/removing thrusters or if the mass of the vehicle changes
function Car:RecalculatePhysics()
    local centerOfMass, mass = PhysicsUtil.getCenterOfMass(PhysicsUtil.getConnectedParts(self._vehicle.PrimaryPart))
    local weight = mass * workspace.Gravity
    self._mass = mass
    self._centerOfMass = centerOfMass

    local totalThrusterDistance = 0
    for _,thruster in pairs(self.Suspension._thrusters) do
        totalThrusterDistance += (centerOfMass - thruster._attachment.WorldPosition).Magnitude
    end

    for _,thruster in pairs(self.Suspension._thrusters) do
        thruster._force = weight * (centerOfMass - thruster._attachment.WorldPosition).Magnitude / totalThrusterDistance
    end
end

function Car:Update()
    for _,thruster in pairs(self.Suspension._thrusters) do
        thruster:Update()
    end
end

return Car