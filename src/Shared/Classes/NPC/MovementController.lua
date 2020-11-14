local AlignAxis = shared.Deus.import("Deus.AlignAxis")

local MovementController = {}

function MovementController.new(character)
    local humanoidRootPart = character._body.HumanoidRootPart

    local self = {
        _character = character,
        _alignAxis = AlignAxis.new(humanoidRootPart, 0, 0, 0, false, true, false, humanoidRootPart.Mass * 2),
        _force = humanoidRootPart.Mass
    }

    return setmetatable(self, {__index = MovementController})
end

function MovementController:Update(raycastParams)
    local character = self._character
    local state = character.State or "Idling"
    local moveDirection = character.MoveDirection
    local alignAxis = self._alignAxis

    if state == "Idling" then
        alignAxis.DesiredPosition = Vector3.new(0, raycastParams.Hit.Y + character._config.HipHeight.Value, 0)
        alignAxis:Update(self._force)
    elseif state == "Jumping" or state == "Falling" then
        alignAxis._vectorForce.Force = Vector3.new()
    end

    local force = alignAxis._vectorForce.Force
    alignAxis._vectorForce.Force = force + moveDirection * self._force * character._config.WalkSpeed.Value
end

return MovementController