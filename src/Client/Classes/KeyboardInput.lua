local UserInputService = game:GetService("UserInputService")

local Output

-- Little optimization to avoid global indexing
local KeyCodes = Enum.KeyCode
local IsTextBoxFocused = false

local function inputBegan(self)
    return function(inputObject)
        if inputObject.KeyCode == self.KeyCode and inputObject:IsModifierKeyDown(Enum.ModifierKey.Shift) == self.Shift then
            if not self.DisableWhenTextBoxFocused or (self.DisableWhenTextBoxFocused and not IsTextBoxFocused) then
                self.Active = true
                self:FireEvent("Began", inputObject)
            end
        end
    end
end

local function inputEnded(self)
    return function(inputObject)
        if self.Active and inputObject.KeyCode == self.KeyCode then
            self.Active = false
            self:FireEvent("Ended", inputObject)
        end
    end
end

local function onFocus(self)
    return function()
        if self.Active and self.DisableWhenTextBoxFocused then
            self.Active = false
            self:FireEvent("Ended")
        end
    end
end

local KeyboardInput = {
    ClassName = "KeyboardInput",
    Extendable = true,
    Methods = {},
    Events = {"Began", "Ended", "Changed"}
}

function KeyboardInput:Constructor(keyCode, shift)
    if type(keyCode) == "string" then
        keyCode = KeyCodes[keyCode]
    end

    Output.assert(typeof(keyCode) == "EnumItem", "Expected EnumItem or string as Argument #1, instead got ".. typeof(keyCode), nil, 1)
    Output.assert(keyCode.EnumType == KeyCodes, "Expected KeyCode as Argument #1, instead got ".. tostring(keyCode.EnumType), nil, 1)

    if not UserInputService.KeyboardEnabled then
        Output.warn("No keyboard was found for this device")
    end

    self.KeyCode = keyCode or false
    -- self.Alt = alt or false
    -- self.Ctrl = ctrl or false
    self.Shift = shift or false

    --[[
    self.BeganConnection = UserInputService.InputBegan:Connect(function(inputObject)
        if inputObject.KeyCode == self.KeyCode and inputObject:IsModifierKeyDown(Enum.ModifierKey.Shift) and IsTextBoxFocused ~= self.DisableWhenTextBoxFocused then
            self.Active = true
            self:FireEvent("Began", inputObject)
        end
    end)

    self.EndedConnection = UserInputService.InputEnded:Connect(function(inputObject)
        if self.Active and inputObject.KeyCode == self.KeyCode then
            self.Active = false
            self:FireEvent("Ended", inputObject)
        end
    end)

    self.ChangedConnection = UserInputService.InputChanged:Connect(function(inputObject)
        if inputObject.KeyCode == self.KeyCode then
            self:FireEvent("Changed", inputObject)
        end
    end)

    self.FocusedConnection = UserInputService.TextBoxFocused:Connect(function()
        if self.Active and self.DisableWhenTextBoxFocused then
            self.Active = false
            self:FireEvent("Ended")
        end
    end)
    ]]

    self:Enable()
end

function KeyboardInput:Deconstructor()
   self:Disable()
end

function KeyboardInput.Methods:Enable()
    Output.assert(self:IsInternalAccess(), "Attempt to use internal method from externally", nil, 1)
    self.BeganConnection = UserInputService.InputBegan:Connect(inputBegan(self))
    self.EndedConnection = UserInputService.InputEnded:Connect(inputEnded(self))
    self.FocusedConnection = UserInputService.TextBoxFocused:Connect(onFocus(self))
    return self
end

function KeyboardInput.Methods:Disable()
    Output.assert(self:IsInternalAccess(), "Attempt to use internal method from externally", nil, 1)
    self.BeganConnection:Disconnect()
    self.EndedConnection:Disconnect()
    -- self.ChangedConnection:Disconnect()
    self.FocusedConnection:Disconnect()
    return self
end

function KeyboardInput:start()
    Output = self:Load("Deus.Output")

    local None = self:Load("Deus.Symbol").new("None")

    self.PrivateProperties = {
        BeganConnection = None,
        EndedConnection = None,
        -- ChangedConnection = None,
        FocusedConnection = None,
    }

    self.PublicReadOnlyProperties = {
        Active = false,
    }

    self.PublicReadAndWriteProperties = {
        -- Alt = false,
        -- Ctrl = false,
        Shift = false,
        KeyCode = None,

        DisableWhenTextBoxFocused = false
    }

    -- TextBox Focused checking
    UserInputService.TextBoxFocused:Connect(function()
        IsTextBoxFocused = true
    end)

    UserInputService.TextBoxFocusReleased:Connect(function()
        IsTextBoxFocused = false
    end)

    return self:Load("Deus.BaseObject").new(self)
end

return KeyboardInput