local MathUtils = shared.Deus.import("Deus.MathUtils")

local SuspensionThruster = {}

function SuspensionThruster.new(vehicle, attachment, raycaster, limit, stiffness, rigidity, turnAngle, powered, steering)
    local self = {
        _lastUpdate = tick(),

        _vehicle = vehicle,
        _attachment = attachment,
        _raycaster = raycaster,
        _dx = 0,
        _d2x = 0,
        _force = 0,

        Enabled = true,
        Limit = limit or 5,
        Stiffness = stiffness or 1,
        Rigidity = rigidity or 1,
        TurnAngle = turnAngle or 30,
        Powered = powered or false,
        Steering = steering or false
    }

    local vectorForce = Instance.new("VectorForce")
    vectorForce.Force = Vector3.new()
    vectorForce.RelativeTo = Enum.ActuatorRelativeTo.World
    vectorForce.Attachment0 = attachment
    vectorForce.Parent = attachment
    self._vectorForce = vectorForce

    return setmetatable(self, {__index = SuspensionThruster})
end

function SuspensionThruster:Update()
    if self.Enabled then
        local updateTime = tick()
        local elapsed = math.min(updateTime - self._lastUpdate, 0.01)

        local vehicle = self._vehicle
        local attachment = self._attachment
        local dx = self._dx
        local d2x = self._d2x
        local limit = self.Limit
        local stiffness = self.Stiffness
        local rigidity = self.Rigidity
        local force = self._force
        local raycastResults = self._raycaster:Cast(attachment.WorldPosition, -attachment.WorldCFrame.UpVector)
        if raycastResults then
            -- Ground is within reach of thruster

            local distance = (attachment.WorldPosition - raycastResults.Position).Magnitude
			local x = limit - distance
            local f = stiffness * x + rigidity*(x-dx) + rigidity/2*(x-d2x) * elapsed
            self._d2x = dx
            self._dx = x
            
            -- Check if f is a valid number, may return as NaN if player is not the vehicle network owner which results in the player crashing
            if f == f then
                
                local ThrottleForce = Vector3.new()
                if self.Powered and vehicle._speed <= vehicle.MaxSpeed then
                    ThrottleForce = vehicle.Throttle * vehicle._speed * force
                end
                --local BaseFriction = MathUtils.clampVector3(-Thruster.CFrame:VectorToObjectSpace(Thruster.Velocity).Unit * Vector3.new(Weight * VehicleData.RotationalFriction * FrictionMultiplier, 0, force * FrictionMultiplier) * (Engine.Velocity.Magnitude / VehicleData.Speed), -500000, 500000)
                local Friction = Vector3.new()
                if self.Steering then
                    --local Friction = (Thruster.CFrame * CFrame.Angles(0, math.rad(-vehicle.Steer * self.TurnAngle * 0.5), 0)):VectorToWorldSpace(BaseFriction)
                    self._vectorForce.Force = MathUtils.clampVector((Vector3.new(0, f * force, 0) + ((attachment.CFrame * CFrame.Angles(0, math.rad(vehicle.Steer * self.TurnAngle), 0)).LookVector * ThrottleForce) + Friction), -5000000, 5000000)
                else
                    --local Friction = Thruster.CFrame:VectorToWorldSpace(BaseFriction)
                    self._vectorForce.Force = MathUtils.clampVector((Vector3.new(0, f * force, 0) + (attachment.CFrame.LookVector * ThrottleForce) + Friction), -5000000, 5000000)
                end
                                    
            end
        else
            -- Ground is not within reach of thruster

            local f = stiffness * limit + rigidity*(limit-dx) + rigidity/2*(limit-d2x)
            self._d2x = dx
			self._dx = limit
            self._vectorForce.Force = Vector3.new(0, 0, 0)
        end

        self._lastUpdate = tick()
    end
end

return SuspensionThruster