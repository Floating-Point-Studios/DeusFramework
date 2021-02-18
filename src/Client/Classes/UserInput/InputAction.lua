-- TODO: Refactor with new class standard

--[[
    Key press event that can have its keys re-mapped or enabled/disabled.
]]

local UserInputService = game:GetService("UserInputService")

local Output
local BaseObject

local function isInputActionActive(self)
    local ReadAndWriteProperties = self.Internal.DEUSOBJECT_LockedTables.ReadAndWriteProperties
    local keyDown = UserInputService:IsKeyDown(ReadAndWriteProperties.KeyCode)

    if not keyDown then
        return false
    end

    local ctrlDown = false
    local altDown = false
    local shiftDown = false

    if not ReadAndWriteProperties.ModifierCtrlRequired or (UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)) then
        ctrlDown = true
    end

    if not ReadAndWriteProperties.ModifierAltRequired or (UserInputService:IsKeyDown(Enum.KeyCode.LeftAlt) or UserInputService:IsKeyDown(Enum.KeyCode.RightAlt)) then
        altDown = true
    end

    if not ReadAndWriteProperties.ModifierShiftRequired or (UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift)) then
        shiftDown = true
    end

    if ctrlDown and altDown and shiftDown then
        return true
    end
    return false
end

local function isModifierKey(keyCode)
    if keyCode == Enum.KeyCode.LeftControl or keyCode == Enum.KeyCode.RightControl then
        return true
    end
    if keyCode == Enum.KeyCode.LeftAlt or keyCode == Enum.KeyCode.RightAlt then
        return true
    end
    if keyCode == Enum.KeyCode.LeftShift or keyCode == Enum.KeyCode.RightShift then
        return true
    end
    return false
end

local function updateAction(self, inputObject)
    if not (self.DisableWhenTyping and UserInputService:GetFocusedTextBox()) then
        local Events = self.Internal.DEUSOBJECT_LockedTables.Events
        local ReadOnlyProperties = self.Internal.DEUSOBJECT_LockedTables.ReadOnlyProperties
        local ReadAndWriteProperties = self.Internal.DEUSOBJECT_LockedTables.ReadAndWriteProperties

        if not inputObject or (inputObject.KeyCode == ReadAndWriteProperties.KeyCode or isModifierKey(inputObject.KeyCode)) then
            if ReadOnlyProperties.Enabled then
                local isActive = isInputActionActive(self)
                if isActive and not ReadOnlyProperties.Active then
                    ReadOnlyProperties.Active = true
                    ReadOnlyProperties.ActionStart = tick()
                    Events.InputBegan:Fire(inputObject)
                elseif not isActive and ReadOnlyProperties.Active then
                    ReadOnlyProperties.Active = false
                    ReadOnlyProperties.ActionStart = 0
                    Events.InputEnded:Fire(inputObject, tick() - ReadOnlyProperties.ActionStart)
                end
            end
        end
    end
end

local InputActionObjData = {
    ClassName = "Deus.InputAction",

    Constructor = function(self, keyCode, reqCtrl, reqAlt, reqShift)
        Output.assert(typeof(keyCode) == "EnumItem" and keyCode.EnumType == Enum.KeyCode, "Expected KeyCode")
        Output.assert(not reqCtrl or type(reqCtrl) == "boolean", "Expected nil or boolean as 2nd argument")
        Output.assert(not reqCtrl or type(reqAlt) == "boolean", "Expected nil or boolean as 3rd argument")
        Output.assert(not reqCtrl or type(reqShift) == "boolean", "Expected nil or boolean as 4th argument")

        local Events = self.Internal.DEUSOBJECT_LockedTables.Events
        local PrivateProperties = self.Internal.DEUSOBJECT_Properties
        local ReadAndWriteProperties = self.Internal.DEUSOBJECT_LockedTables.ReadAndWriteProperties
        ReadAndWriteProperties.KeyCode = keyCode
        ReadAndWriteProperties.ModifierCtrlRequired = reqCtrl or false
        ReadAndWriteProperties.ModifierAltRequired = reqAlt or false
        ReadAndWriteProperties.ModifierShiftRequired = reqShift or false

        PrivateProperties.InputBeganConnection = UserInputService.InputBegan:Connect(function(inputObject)
            updateAction(self, inputObject)
        end)

        PrivateProperties.InputEndedConnection = UserInputService.InputEnded:Connect(function(inputObject)
            updateAction(self, inputObject)
        end)

        PrivateProperties.TextBoxReleasedConnection = UserInputService.TextBoxFocusReleased:Connect(function()
            updateAction(self)
        end)

        PrivateProperties.ChangedConnection = Events.Changed:Connect(function()
            updateAction(self)
        end)
    end,

    Methods = {
        Toggle = function(self, state)
            local Events = self.Internal.DEUSOBJECT_LockedTables.Events
            local ReadOnlyProperties = self.Internal.DEUSOBJECT_LockedTables.ReadOnlyProperties

            Output.assert(self:IsInternalAccess(), "InputAction can only be toggled with internal access")
            Output.assert(state ~= nil and type(state) == "boolean", "Boolean expected as 2nd argument")

            ReadOnlyProperties.Enabled = state

            if not state then
                Events.InputEnded:Fire()
                ReadOnlyProperties.Active = false
            end
        end
    },

    Events = {"InputBegan", "InputEnded"},

    PublicReadOnlyProperties = {
        Enabled = true,
        Active = false,
        ActionStart = 0,
    },

    PublicReadAndWriteProperties = {
        DisableWhenTyping = false,
        ModifierCtrlRequired = false,
        ModifierAltRequired = false,
        ModifierShiftRequired = false
    }
}

local InputAction = {}

function InputAction:start()
    Output = self:Load("Deus.Output")
    BaseObject = self:Load("Deus.BaseObject")

    return BaseObject.new(InputActionObjData)
end

return InputAction