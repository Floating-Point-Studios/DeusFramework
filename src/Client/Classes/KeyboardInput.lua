local UserInputService = game:GetService("UserInputService")

local Output

local function isTextBoxFocused()
    if UserInputService:GetFocusedTextBox() then
        return true
    end
    return false
end

local KeyboardInput = {
    ClassName = "KeyboardInput",
    Extendable = true,
    Replicable = true,
    Methods = {},
    Events = {"Began", "Ended", "Changed"}
}

function KeyboardInput:Constructor(keyCode, alt, ctrl, shift)
    Output.assert(typeof(keyCode) == "EnumItem", "Expected EnumItem as Argument #1, instead got ".. typeof(keyCode))
    Output.assert(keyCode.EnumType == "KeyCode", "Expected KeyCode as Argument #1, instead got ".. keyCode.EnumType)

    if not UserInputService.KeyboardEnabled then
        Output.warn("No keyboard was found for this device")
    end

    self.KeyCode = keyCode or false
    self.Alt = alt or false
    self.Ctrl = ctrl or false
    self.Shift = shift or false

    self.BeganConnection = UserInputService.InputBegan:Connect(function(inputObject)
        if inputObject.KeyCode == self.KeyCode and inputObject:IsModifierKeyDown(Enum.ModifierKey.Alt) == self.Alt and inputObject:IsModifierKeyDown(Enum.ModifierKey.Ctrl) == self.Ctrl and inputObject:IsModifierKeyDown(Enum.ModifierKey.Shift) == self.Shift and isTextBoxFocused() == self.DisableWhenTextBoxFocused then
            self:FireEvent("Began", inputObject)
        end
    end)

    self.EndedConnection = UserInputService.InputEnded:Connect(function(inputObject)
        if inputObject.KeyCode == self.KeyCode and inputObject:IsModifierKeyDown(Enum.ModifierKey.Alt) == self.Alt and inputObject:IsModifierKeyDown(Enum.ModifierKey.Ctrl) == self.Ctrl and inputObject:IsModifierKeyDown(Enum.ModifierKey.Shift) == self.Shift and isTextBoxFocused() == self.DisableWhenTextBoxFocused then
            self:FireEvent("Began", inputObject)
        end
    end)

    self.ChangedConnection = UserInputService.InputChanged:Connect(function(inputObject)
        if inputObject.KeyCode == self.KeyCode and inputObject:IsModifierKeyDown(Enum.ModifierKey.Alt) == self.Alt and inputObject:IsModifierKeyDown(Enum.ModifierKey.Ctrl) == self.Ctrl and inputObject:IsModifierKeyDown(Enum.ModifierKey.Shift) == self.Shift and isTextBoxFocused() == self.DisableWhenTextBoxFocused then
            self:FireEvent("Changed", inputObject)
        end
    end)

    self.FocusedConnection = UserInputService.TextBoxFocused:Connect(function()
        if self.DisableWhenTextBoxFocused then
            self.Active = false
            self:FireEvent("Ended")
        end
    end)
end

function KeyboardInput:Deconstructor()
   self.BeganConnection:Disconnect()
   self.EndedConnection:Disconnect()
   self.ChangedConnection:Disconnect()
   self.FocusedConnection:Disconnect()
end

function KeyboardInput:start()
    Output = self:Load("Deus.Output")

    local None = self:Load("Deus.Symbol").new("None")

    self.PrivateProperties = {
        BeganConnection = None,
        EndedConnection = None,
        ChangedConnection = None,
        FocusedConnection = None,
    }

    self.PublicReadOnlyProperties = {
        Active = false,
    }

    self.PublicReadAndWriteProperties = {
        Alt = false,
        Ctrl = false,
        Shift = false,
        KeyCode = None,

        DisableWhenTextBoxFocused = false,
    }

    return self:Load("Deus.BaseObject").new(self)
end

return KeyboardInput