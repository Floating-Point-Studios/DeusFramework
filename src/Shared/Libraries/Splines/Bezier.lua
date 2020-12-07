-- https://developer.roblox.com/en-us/articles/Bezier-curves

local Deus = shared.DeusFramework

local MathUtils = Deus:Load("Deus/MathUtils")

local function lerp(n, points)
    repeat
		local L = {}
		for i = 1, #points - 1 do
			L[i] = MathUtils.lerp(points[i], points[i + 1], n)
		end
		points = L
	until #points == 1
	return points[1]
end

function length(points, func)
    func = func or lerp
    local n = #points
    local sum, ranges, sums = 0, {}, {}

	for i = 0, n-1 do
		local p1, p2 = func(i/n, points), func((i+1)/n, points)
        local dist

        if typeof(p1) == "CFrame" then
            dist = (p2.p - p1.p).Magnitude
        else
            dist = (p2 - p1).Magnitude
        end

		ranges[sum] = {dist, p1, p2}
		table.insert(sums, sum)
		sum = sum + dist
    end

	return sum, ranges, sums
end

local Bezier = {}

function Bezier.new(points, func)
    local sum, ranges, sums = length(points, func)

    local self = {
        Func = func or lerp;
        Points = points;
        Length = sum;
        Ranges = ranges;
        Sums = sums
    }

	return setmetatable(self, {__index = Bezier})
end

function Bezier:SetPoints(points)
	-- only update the length when the control points are changed
	local sum, ranges, sums = length(points, self.Func)
	self.Points = points
	self.Length = sum
	self.Ranges = ranges
	self.Sums = sums
end

function Bezier:Calc(t)
	-- if you don't need t to be a percentage of distance
	return self.Func(t, self.Points)
end

function Bezier:CalcFixed(t)
	local T, near = t * self.Length, 0
	for _, n in next, self.Sums do
		if (T - n) < 0 then break end
		near = n
	end
	local set = self.Ranges[near]
	local percent = (T - near)/set[1]
	return set[2], set[3], percent
end

function Bezier:CalcPoints(steps, dist)
    local points = {}
    for i = 0, steps do
        table.insert(points, self:Calc(i/steps))
    end

    if dist then
        local unevenPoints = points
        points = {{Position = unevenPoints[1], Percent = 0}}

        for i = 2, steps do
            local point = unevenPoints[i]
            local magnitude

            if typeof(point) == "CFrame" then
                magnitude = (point.p - points[#points].Position.p).Magnitude
            else
                magnitude = (point - points[#points].Position).Magnitude
            end

            if magnitude >= dist then
                table.insert(points, {Position = point, Percent = i/steps})
            end
        end

        table.insert(points, {Position = unevenPoints[#unevenPoints], Percent = 1})
    end
    return points
end

return Bezier