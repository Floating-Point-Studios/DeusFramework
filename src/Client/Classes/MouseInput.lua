local UserInputService = game:GetService("UserInputService")

local Output

local function inputBegan(self)
    return function(inputObject)
        if inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
            self:FireEvent("Button1Down", inputObject)
        elseif inputObject.UserInputType == Enum.UserInputType.MouseButton2 then
            self:FireEvent("Button2Down", inputObject)
        elseif inputObject.UserInputType == Enum.UserInputType.MouseButton3 then
            self:FireEvent("Button3Down", inputObject)
        end
    end
end

local function inputEnded(self)
    return function(inputObject)
        if inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
            self:FireEvent("Button1Up", inputObject)
        elseif inputObject.UserInputType == Enum.UserInputType.MouseButton2 then
            self:FireEvent("Button2Up", inputObject)
        elseif inputObject.UserInputType == Enum.UserInputType.MouseButton3 then
            self:FireEvent("Button3Up", inputObject)
        end
    end
end

local function inputChanged(self)
    return function(inputObject)
        if inputObject.UserInputType == Enum.UserInputType.MouseWheel then
            if inputObject.Position.Z > 0 then
                self:FireEvent("WheelForward", inputObject)
            else
                self:FireEvent("WheelBackward", inputObject)
            end
        elseif inputObject.UserInputType == Enum.UserInputType.MouseMovement then
            self:FireEvent("Move", inputObject)
        end
    end
end

local MouseInput = {
    ClassName = "MouseInput",
    Events = {"Move", "Button1Down", "Button1Up", "Button2Up", "Button2Down", "Button3Up", "Button3Down", "WheelBackward", "WheelForward"}
}

function MouseInput:Constructor()
    if not UserInputService.MouseEnabled then
        Output.warn("No mouse was found for this device")
    end

    self:Enable()
end

function MouseInput:Deconstructor()
    self:Disable()
end

function MouseInput:Enable()
    Output.assert(self:IsInternalAccess(), "Attempt to use internal method from externally", nil, 1)
    self.BeganConnection = UserInputService.InputBegan:Connect(inputBegan(self))
    self.EndedConnection = UserInputService.InputEnded:Connect(inputEnded(self))
    self.ChangedConnection = UserInputService.InputChanged:Connect(inputChanged(self))
    return self
end

function MouseInput:Disable()
    Output.assert(self:IsInternalAccess(), "Attempt to use internal method from externally", nil, 1)
    self.BeganConnection:Disconnect()
    self.EndedConnection:Disconnect()
    self.ChangedConnection:Disconnect()
    return self
end

function MouseInput:start()
    Output = self:Load("Deus.Output")

    local None = self:Load("Deus.Symbol").new("None")

    self.PrivateProperties = {
        BeganConnection = None,
        EndedConnection = None,
        ChangedConnection = None,
    }

    self.PublicReadOnlyProperties = {}

    self.PublicReadAndWriteProperties = {}

    return self:Load("Deus.BaseObject").new(self)
end

return MouseInput