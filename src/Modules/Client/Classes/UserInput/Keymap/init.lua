local UserInputService = game:GetService("UserInputService")

local KeyEvent = require(script.KeyEvent)

local Keymap = {}

-- Cache results
local ctrlDown = false
local shiftDown = false
local altDown = false

local function isMouseInput(input)
    if input == Enum.UserInputType.MouseButton1 or input == Enum.UserInputType.MouseButton2 or input == Enum.UserInputType.MouseButton3 then
        return true
    end
end

local function isKeyEventActive(keyEvent, button)
    return keyEvent._button == button and keyEvent._ctrl == ctrlDown and keyEvent._shift == shiftDown and keyEvent._alt == altDown
end

function Keymap.new(enabled)
    local self = {
        Enabled = enabled,
        Events = {}
    }

    UserInputService.InputBegan:connect(function(inputObject)
        self:_update(inputObject)
    end)

    UserInputService.InputEnded:connect(function(inputObject)
        self:_update(inputObject)
    end)

    UserInputService.InputChanged:connect(function(inputObject)
        self:_update(inputObject)
    end)

    return setmetatable(self, {__index = Keymap})
end

function Keymap:_update(inputObject, gameProcessedEvent)
    if self.Enabled then
        local button

        if isMouseInput(inputObject.UserInputType) then
            button = inputObject.UserInputType
        else
            button = inputObject.KeyCode
        end

        if inputObject.UserInputState == Enum.UserInputState.Begin then
            for _,keyEvent in pairs(self.Events) do
                keyEvent:Update(isKeyEventActive(keyEvent, button), inputObject, gameProcessedEvent)
            end
        elseif inputObject.UserInputState == Enum.UserInputState.End then
            for _,keyEvent in pairs(self.Events) do
                keyEvent:Update(isKeyEventActive(keyEvent, button), inputObject, gameProcessedEvent)
            end
        elseif inputObject.UserInputState == Enum.UserInputState.Change then
            KeyEvent.Changed:Fire(inputObject, gameProcessedEvent)
        end

    end
end

function Keymap:Set(eventName, button, ctrl, shift, alt)
    if self.Events[eventName] then
        self.Events[eventName]:Set(button, ctrl, shift, alt)
    else
        table.insert(self.Events, KeyEvent.new(button, ctrl, shift, alt))
    end
end

UserInputService.InputBegan:connect(function(inputObject)
    if inputObject.UserInputType == Enum.UserInputType.Keyboard then
        local keyCode = inputObject.KeyCode
        if keyCode == Enum.KeyCode.LeftControl or keyCode == Enum.KeyCode.RightControl then
            ctrlDown = true
        elseif keyCode == Enum.KeyCode.LeftShift or keyCode == Enum.KeyCode.RightShift then
            shiftDown = true
        elseif keyCode == Enum.KeyCode.LeftAlt or keyCode == Enum.KeyCode.RightAlt then
            altDown = true
        end
    end
end)

UserInputService.InputEnded:connect(function(inputObject)
    if inputObject.UserInputType == Enum.UserInputType.Keyboard then
        local keyCode = inputObject.KeyCode
        if keyCode == Enum.KeyCode.LeftControl or keyCode == Enum.KeyCode.RightControl then
            ctrlDown = false
        elseif keyCode == Enum.KeyCode.LeftShift or keyCode == Enum.KeyCode.RightShift then
            shiftDown = false
        elseif keyCode == Enum.KeyCode.LeftAlt or keyCode == Enum.KeyCode.RightAlt then
            altDown = false
        end
    end
end)

return Keymap