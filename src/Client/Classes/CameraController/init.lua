local CameraTypes = {
    FirstPersonView = require(script.CameraTypes.FirstPersonView),
    ThirdPersonView = require(script.CameraTypes.ThirdPersonView),
    Vehicle = require(script.CameraTypes.Vehicle),
    Orbital = require(script.CameraTypes.Orbital)
}

local CameraController = {}

function CameraController.new(camera)
    local self = {
        _camera = camera,
        _lastMouseDelta = Vector2.new(),
        _lastCFrame = CFrame.new(),
        _cameraType = "ThirdPersonView"
    }

    return setmetatable(self, {__index = CameraController})
end

function CameraController:SetCameraType(cameraType, ...)
    self._cameraType = cameraType
    
    local cameraModule = cameraTypes[cameraType]
    cameraModule.Setup(self, ...)
end

function CameraController:Update(mouseDelta, scrollDelta)
    local cameraType = self._cameraType
    if cameraType ~= "Custom" then
        CameraTypes[cameraType].Update(self, mouseDelta, scrollDelta)
    end
end

return CameraController