local Output

local MathUtils = {}

-- Golden Ratio
MathUtils.phi = (math.sqrt(5) + 1) / 2
-- Golden Angle in radians
MathUtils.ga = math.pi * (3 - math.sqrt(5))

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

function MathUtils.isPrime(x)
    for i = 2, math.sqrt(x) do
        if x % i == 0 then
            return false
        end
    end
    return true
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