local RaycastUtils = {}

local DefaultParams = RaycastParams.new()

function RaycastUtils.cast(origin, dir, params)
    return workspace:Raycast(origin, dir, params or DefaultParams)
end

function RaycastUtils.castCollideOnly(origin, dir, params)
    params = params or DefaultParams
    local dirUnit = dir.Unit
    repeat
        local result = workspace:Raycast(origin, dir, params)
        if result then
            if result.Instance.CanCollide then
                return result
            else
                origin = result.Position
                dir = dirUnit * (dir.Magnitude - (origin - result.Position).Magnitude)
            end
        else
            return nil
        end
    until not result
end

return RaycastUtils