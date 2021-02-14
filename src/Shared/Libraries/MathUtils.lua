local Output

local MathUtils = {}

function MathUtils.isNaN(x)
    return x ~= x
end

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

function MathUtils.getFactors(x)
    local factors = {}
    local sqrtx = math.sqrt(x)

    for i = 1, sqrtx do
        if x % i == 0 then
            table.insert(factors, i)
            if i ~= sqrtx then
                table.insert(factors, x / i)
            end
        end
    end

    table.sort(factors)

    return factors
end

-- Returns the closest number to 'x' from a table of numbers
function MathUtils.snap(x, numbers, snapUp)
    local bestMatch = numbers[1]
    local diff = math.abs(x - numbers[1])

    for i = 2, #numbers do
        local v = numbers[i]
        local testDiff = math.abs(x - v)

        if testDiff < diff then
            bestMatch = v
            diff = testDiff
        end
    end

    if snapUp and bestMatch < x then
        return numbers[table.find(numbers, bestMatch) + 1]
    end

    return bestMatch
end

function MathUtils.start()
    Output = MathUtils:Load("Deus.Output")
end

return MathUtils