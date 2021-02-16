local VectorUtils = {}

-- @param vector: vector3/vector2 to clamp
-- @param min: number/vecto3/vector2, minimum value
-- @param max: number/vecto3/vector2, maximum value
function VectorUtils.clampVector(vector, min, max)
    min = min or Vector3.new(-math.huge, -math.huge, -math.huge)
    max = max or Vector3.new(math.huge, math.huge, math.huge)

    if type(min) == "number" then
        min = Vector3.new(min, min, min)
    end

    if type(max) == "number" then
        max = Vector3.new(max, max, max)
    end

    if typeof(vector) == "Vector3" then
        return Vector3.new(math.clamp(vector.X, min.X, max.X), math.clamp(vector.Y, min.Y, max.Y), math.clamp(vector.Z, min.Z, max.Z))
    else
        return Vector2.new(math.clamp(vector.X, min.X, max.X), math.clamp(vector.Y, min.Y, max.Y))
    end
end

function VectorUtils.llarToWorld(lat, lon, alt, rad)
    -- https://stackoverflow.com/questions/10473852/convert-latitude-and-longitude-to-point-in-3d-space
    alt = alt or 0

    local ls = math.atan(math.tan(lat))

    local x = rad * math.cos(ls) * math.cos(lon) + alt * math.cos(lat) * math.cos(lon)
    local y = rad * math.cos(ls) * math.sin(lon) + alt * math.cos(lat) * math.sin(lon)
    local z = rad * math.sin(ls) + alt * math.sin(lat)

    return Vector3.new(x, y, z)
end

return VectorUtils