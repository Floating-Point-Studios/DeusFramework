local StateController = {}

function StateController.new(character)
    local self = {
        _character = character
    }

    character._lastState = "Idling"
    character._stateStartTime = tick()
    character._stateStartPos = character._body.HumanoidRootPart.Position
    character.State = "Idling"

    return setmetatable(self, {__index = StateController})
end

function StateController:Update(raycastResult)
    local character = self._character
    local humanoidRootPart = character._body.HumanoidRootPart
    local curStateStartTime = character._stateStartTime or tick()
    local curStateStartPos = character._stateStartPos or humanoidRootPart.Position
    local curState = character.State or "Idling"
    local newState = curState

    -- Character state logic
    if raycastResult then
        -- Skip logic if player is jumping or sitting
        if curState ~= "Jumping" and curState ~= "Sitting" then
            if character.Jump then

                -- If the jump property is enabled then initiate a jump
                character.Jump = false
                newState = "Jumping"

            elseif character.Sit then

                -- If the sit property is enabled then set state to sitting
                newState = "Sitting"

            elseif character.MoveDirection.Magnitude > 0.1 then

                -- If the move direction magnitude is higher than 0.1 set state to walking
                newState = "Walking"

            else

                -- If none of the conditions above are met the character must be idling
                newState = "Idling"

            end
        end
    else
        if curState == "Jumping" then

            -- If the character's Y position is now below where the state started the player is no longer jumping but falling, this occurs when player jumps off a edge
            if humanoidRootPart.Position.Y < curStateStartPos.Y then
                newState = "Falling"
            end

        else

            -- If no conditions above are met the player must be falling
            newState = "Falling"

        end
    end

    if newState ~= curState then
        character._lastState = curState
        character._stateStartTime = tick()
        character._stateStartPos = humanoidRootPart.Position
        character.State = newState
    end

    character._lastPos = character._position
    character._lastVelocity = character._velocity
    character._position = humanoidRootPart.Position
    character._velocity = humanoidRootPart.Velocity

end

return StateController