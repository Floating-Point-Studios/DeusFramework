local RunService = game:GetService("RunService")

local AlignOrientation = shared.Deus.import("Deus.AlignOrientation")
local AlignPosition = shared.Deus.import("Deus.AlignPosition")
local FrictionForce = shared.Deus.import("Deus.FrictionForce")

local MovementController = {}

function MovementController.new(character)
    local humanoidRootPart = character._body.HumanoidRootPart

    local self = {
        _character = character,
        _force = -humanoidRootPart.Mass * workspace.Gravity
    }

    -- These PID values are only tuned for a mass of 2.8 (Default Roblox HumanoidRootPart under standard Gravity)
    if RunService:IsServer() then
        local attachment = Instance.new("Attachment", humanoidRootPart)
        self._alignOrientation = AlignOrientation.new(humanoidRootPart, Vector3.new(50000, 1000, 50000), attachment)
        self._alignPosition = AlignPosition.new(humanoidRootPart, 20, 0.25, 0.75, Vector3.new(0, 10000, 0), attachment)
        self._frictionForce = FrictionForce.new(nil, nil, self._alignPosition._vectorForce)
        self._vectorForce = self._alignPosition._vectorForce
    else
        local vectorForce = humanoidRootPart.Attachment.VectorForce
        self._alignOrientation = AlignOrientation.new(nil, Vector3.new(50000, 1000, 50000), nil, humanoidRootPart.Attachment.AngularVelocity)
        self._alignPosition = AlignPosition.new(nil, 20, 0.25, 0.75, Vector3.new(0, 10000, 0), nil, vectorForce)
        self._frictionForce = FrictionForce.new(nil, nil, vectorForce)
        self._vectorForce = vectorForce
    end

    return setmetatable(self, {__index = MovementController})
end

function MovementController:Update(raycastResult)
    local character = self._character
    local state = character.State or "Idling"
    local moveDirection = character.MoveDirection
    local alignOrientation = self._alignOrientation
    local alignPosition = self._alignPosition
    local humanoidRootPart = character._body.HumanoidRootPart

    alignOrientation.DesiredOrientation = Vector3.new(0, character.LookAngle, 0)
    alignOrientation:Update(3)

    if state == "Idling" and raycastResult then

        -- Prevents bouncing from high falls
        local velocity = character._velocity
        if tick() - character._stateStartTime < 0.1 and character._lastState == "Falling" and math.abs(velocity.Y) > 30 then
            humanoidRootPart.Velocity = Vector3.new(velocity.X, 0, velocity.Z)
        end

        -- Update the DesiredPosition to HipHeight level based off RaycastResult.Position.Y
        alignPosition.DesiredPosition = Vector3.new(0, raycastResult.Position.Y + character._config.HipHeight.Value + (humanoidRootPart.Size.Y / 2), 0)
        alignPosition:Update(self._force)
        local frictionCoefficient = self._frictionForce:Update(raycastResult.Material, 20, true)

        -- Update walk force
        self.vectorForce.Force += moveDirection * frictionCoefficient * 20 * humanoidRootPart.Mass * character._config.WalkSpeed.Value

    elseif state == "Jumping" or state == "Falling" then
        -- Update walk force
        alignPosition._vectorForce.Force = moveDirection * humanoidRootPart.Mass * character._config.WalkSpeed.Value

        -- Prevents bouncing from high falls
        local velocity = character._velocity
        if math.sign(velocity.Y) ~= math.sign(character._lastVelocity.Y) then
            humanoidRootPart.Velocity = Vector3.new(velocity.X, 0, velocity.Z)
        end
    end
end

return MovementController