local Raycaster = shared.Deus.import("Deus.Raycaster")

local StateController = {}

function StateController.new(character)
    local self = {
        _character = character,
        _raycaster = Raycaster.new({{character._body}, Enum.RaycastFilterType.Blacklist, true}, character._config.HipHeight.Value, true),
    }

    return setmetatable(self, {__index = StateController})
end

function StateController:Update()
    local character = self._character
    local body = character._body

    local raycastResult = self._raycaster:Cast(body.HumanoidRootPart.Position, Vector3.new(0, -1, 0))
    print(raycastResult)
end

return StateController