local StarterGui = game:GetService("StarterGui")

local RaycastUtils

local MouseUtils = {}

function MouseUtils.getTargetAtPosition(x, y, filterType, filterDescendantsInstances)
    local ray = workspace.CurrentCamera:ViewportPointToRay(x, y)

    local params = RaycastParams.new()
    params.FilterType = filterType or Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = filterDescendantsInstances or {}

    local result = RaycastUtils.cast(ray.Origin, ray.Direction, params)
    if result then
        return result.Instance
    end
end

function MouseUtils.getGuiObjectsAtPositionWithWhitelist(x, y, filter)
    local objects = StarterGui:GetGuiObjectsAtPosition(x, y)
    local filteredObjects = {}

    for _,v1 in pairs(objects) do
        for _,v2 in pairs(filter) do
            if v1 == v2 or v1:IsDescendantOf(v2) then
                table.insert(filteredObjects, v1)
            end
        end
    end

    return filteredObjects
end

function MouseUtils.start()
    RaycastUtils = MouseUtils:Load("Deus.RaycastUtils")
end

return MouseUtils