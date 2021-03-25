local TableUtils = {}

local DefaultParams = RaycastParams.new()

local RaycastUtils = {}

function RaycastUtils.raycastParamsFrom(params)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances    = params.FilterDescendantsInstances
    raycastParams.FilterType                    = params.FilterType
    raycastParams.IgnoreWater                   = params.IgnoreWater
    raycastParams.CollisionGroup                = params.CollisionGroup
end

-- Clones a new RaycastParams with the same properties
function RaycastUtils.copyRaycastParams(raycastParams)
    local copyRaycastParams                         = RaycastParams.new()
    copyRaycastParams.FilterDescendantsInstances    = TableUtils.shallowCopy(raycastParams.FilterDescendantsInstances)
    copyRaycastParams.FilterType                    = raycastParams.FilterType
    copyRaycastParams.IgnoreWater                   = raycastParams.IgnoreWater
    copyRaycastParams.CollisionGroup                = raycastParams.CollisionGroup

    return copyRaycastParams
end

-- Behaves like the old raycast function
function RaycastUtils.cast(origin, dir, params)
    return workspace:Raycast(origin, dir, params or DefaultParams)
end

-- Cast ignores parts that are CanCollideOff
function RaycastUtils.castCollideOnly(origin, dir, params)
    params = RaycastUtils.copyRaycastParams(params or DefaultParams)
    local dirUnit = dir.Unit

    repeat
        local result = workspace:Raycast(origin, dir, params)
        if result then
            if result.Instance.CanCollide then
                return result
            else
                table.insert(params.FilterDescendantsInstances, result.Instance)
                origin = result.Position
                dir = dirUnit * (dir.Magnitude - (origin - result.Position).Magnitude)
            end
        else
            return nil
        end
    until not result
end

RaycastUtils.copy = RaycastUtils.copyRaycastParams
RaycastUtils.from = RaycastUtils.from

function RaycastUtils:start()
    TableUtils = self:Load("Deus.TableUtils")
end

return RaycastUtils