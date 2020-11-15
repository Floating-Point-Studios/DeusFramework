local AlignPosition = shared.Deus.import("Deus.AlignPosition")

local MovementController = {}

function MovementController.new(character)
    local humanoidRootPart = character._body.HumanoidRootPart

    local self = {
        _character = character,
        -- These PID values are only tuned for a mass of 2.8 (Default Roblox HumanoidRootPart under standard Gravity)
        _AlignPosition = AlignPosition.new(humanoidRootPart, 20, 0.25, 0.75, Vector3.new(0, 10000, 0)),
        _force = -humanoidRootPart.Mass * workspace.Gravity
    }

    return setmetatable(self, {__index = MovementController})
end

function MovementController:Update(raycastResult)
    local character = self._character
    local state = character.State or "Idling"
    local moveDirection = character.MoveDirection
    local AlignPosition = self._AlignPosition

    if state == "Idling" and raycastResult then

        AlignPosition.DesiredPosition = Vector3.new(0, raycastResult.Position.Y + character._config.HipHeight.Value + (character._body.HumanoidRootPart.Size.Y / 2), 0)
        AlignPosition:Update(self._force)

    elseif state == "Jumping" or state == "Falling" then
        AlignPosition._vectorForce.Force = Vector3.new()
    end

    local force = AlignPosition._vectorForce.Force
    AlignPosition._vectorForce.Force = force + moveDirection * self._force * character._config.WalkSpeed.Value
end

return MovementController