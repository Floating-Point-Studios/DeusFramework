local Deus = shared.Deus()

local Output = Deus:Load("Deus.Output")

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
-- @param min: number/vecto3/vector2, minimum value
-- @param max: number/vecto3/vector2, maximum value
function MathUtils.clampVector(vector, min, max)
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

-- @param color: Color3 to multiply
-- @param x: factor to multiply by
function MathUtils.multiplyColor3(color, x)
    return Color3.new(color.R * x, color.G * x, color.B * x)
end

-- Not reccomended to use this if hard-coded values are possible
function MathUtils.factorial(x)
    local output = 1
    for i = 1, x do
        output *= i
    end
    return output
end

function MathUtils.lerp(a, b, c)
    local typeA, typeB = typeof(a), typeof(b)
    Output.assert(typeA == typeB, "Type mismatch between %s and %s, same type expected", typeA, typeB)
    if typeA == "CFrame" then
        return a:Lerp(b, c)
    else
        return a + (b - a) * c
    end
end

return MathUtils