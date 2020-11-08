-- Useful for casting rays of fixed length or filtering out objects that have CanCollide disabled

local Raycaster = {}

function Raycaster.newParams(filterDescendantsInstances, filterType, ignoreWater)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = filterDescendantsInstances
    raycastParams.FilterType = filterType
    raycastParams.IgnoreWater = ignoreWater
    return raycastParams
end

function Raycaster.new(raycastParams, length, canCollideOnly)
    if typeof(raycastParams) == "table" then
        raycastParams = Raycaster.newParams(unpack(raycastParams))
    end
    local self = {
        RaycastParams = raycastParams,
        Length = length,
        CanCollideOnly = canCollideOnly or false
    }
    return setmetatable(self, {__index = Raycaster})
end

function Raycaster:Cast(origin, direction)
    if type(origin) == "CFrame" then
        origin = origin.Position
        direction = origin.LookVector
    end
    local length = self.Length
    local result = workspace:Raycast(origin, direction * length, self.RaycastParams)
    if result and self.CanCollideOnly and not result.Instance.CanCollide then
        repeat
            if length <= 0 then
                break
            end
            if result then
                length -= (origin - result.Position).Magnitude
                origin = result.Position
                local raycastParams = RaycastParams.new()
                raycastParams.FilterDescendantsInstances = {unpack(self.RaycastParams.FilterDescendantsInstances), result.Instance}
                raycastParams.FilterType = self.RaycastParams.FilterType
                raycastParams.IgnoreWater = self.RaycastParams.IgnoreWater
                raycastParams.CollisionGroup = self.RaycastParams.CollisionGroup
                result = workspace:Raycast(origin, direction * length, raycastParams)
            end
        until not result or result.Instance.CanCollide
        return result
    else
        return result
    end
end

return Raycaster