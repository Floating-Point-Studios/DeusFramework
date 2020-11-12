local MovementController = {}

function MovementController.new(character)
    local self = {
        _character = character,
        _vectorForce = character._vectorForce
    }

    return setmetatable(self, {__index = MovementController})
end

function MovementController:Update()
    
end

return MovementController