local MathUtils = {}

-- @param x: number/vector3/vector2 to round
-- @param accuracy: number to round x to
function MathUtils.round(x, accuracy)
    return math.round(x / accuracy) * accuracy
end

function MathUtils.roundCeil(x, accuracy)
    return math.ceil(x / accuracy) * accuracy
end

function MathUtils.roundFloor(x, accuracy)
    return math.floor(x / accuracy) * accuracy
end

-- @param vector: vector3/vector2 to clamp
-- @param min: minimum value
-- @param max: maximum value
function MathUtils.clampVector(vector, min, max)
    if typeof(vector) == "Vector3" then
        return Vector3.new(math.clamp(vector.X, min, max), math.clamp(vector.Y, min, max), math.clamp(vector.Z, min, max))
    else
        return Vector2.new(math.clamp(vector.X, min, max), math.clamp(vector.Y, min, max))
    end
end

-- @param color: Color3 to multiply
-- @param x: factor to multiply by
function MathUtils.multiplyColor3(color, x)
    return Color3.new(color.R * x, color.G * x, color.B * x)
end

function MathUtils.factorial(x)
    local output = 1
    for i = 1, x do
        output *= i
    end
    return output
end

return MathUtils