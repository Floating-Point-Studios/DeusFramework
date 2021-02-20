--[[
    Calculations from here:
    https://www.omnicalculator.com/physics/projectile-motion
]]

local VectorUtils
local CFrameUtils

local BasicProjectile = {}

BasicProjectile.ClassName = "Deus.BasicProjectile"

BasicProjectile.Extendable = true

BasicProjectile.Replicable = true

BasicProjectile.Methods = {}

BasicProjectile.Events = {}

function BasicProjectile.Methods:GetVelocityComponents()
    local vel = self.Velocity.Magnitude
    local a = self.Angle
    -- Returns Vx, Vy
    return vel * math.cos(a), vel * math.sin(a)
end

-- cutOffY is the height the "ground" is at to end the flight or otherwise projectile would continue forever
function BasicProjectile.Methods:GetFlightTime(cutoffY)
    cutoffY = cutoffY or 0

    local _,vy = self:GetVelocityComponents()
    local g = self.Gravity
    return (vy + math.sqrt(vy^2 + 2*g*(self.Origin.Y - cutoffY))) / g
end

function BasicProjectile.Methods:GetMaximumHeight()
    local origin = self.Origin
    -- If projectile is aimed downwards the origin is the max height
    if self.Velocity.Y > 0 then
        return origin.Y + self.Velocity.Magnitude^2 * math.sin(self.Angle)^2 / (2 * self.Gravity)
    else
        return origin.Y
    end
end

function BasicProjectile.Methods:GetHighestPoint()
    local origin = self.Origin
    local vel = self.Velocity
    -- If projectile is aimed downwards the origin is the max height
    if self.Velocity.Y > 0 then
        local range = self:GetRange(origin.Y)
        local parabolaEnd = origin + Vector3.new(vel.X, 0, vel.Z).Unit * range
        return CFrame.lookAt(origin, parabolaEnd) * CFrame.new(0, self:GetMaximumHeight() - origin.Y, -range / 2).Position
    else
        return origin
    end
end

function BasicProjectile.Methods:GetTickAtHeight(height)
    local _,vy = self:GetVelocityComponents()
    local g = self.Gravity

    local t1
    local t2

    -- Skip if height is higher than projectile's maximum height
    if height <= self:GetMaximumHeight() then
        local origin = self.Origin
        t1 = (vy + math.sqrt(vy^2 + 2*g*(origin.Y - height))) / g

        -- If projectile is aimed upward the height can only be at a 2nd tick
        if self.Velocity.Y > 0 then
            local flightTime = self:GetFlightTime(origin.Y)
            local highestPointTime = flightTime / 2

            t2 = highestPointTime - (t1 - highestPointTime)
        end
    end

    return t1, t2
end

function BasicProjectile.Methods:GetRange(cutoffY)
    cutoffY = cutoffY or 0

    local vx, vy = self:GetVelocityComponents()
    local g = self.Gravity
    return vx * (vy + math.sqrt(vy^2 + 2*g*(self.Origin.Y - cutoffY))) / g
end

function BasicProjectile.Methods:GetPositionAtTick(tick)
    return (CFrame.new(0, -self.Gravity * tick^2 / 2, 0) * CFrameUtils.fromOriginDir(self.Origin, self.Velocity.Unit) * CFrame.new(0, 0, -self.Velocity.Magnitude * tick)).Position
end

function BasicProjectile.Methods:GetCFrameAtTick(tick)
    return CFrame.lookAt(self:GetPositionAtTick(tick), self:GetPositionAtTick(tick + 0.001/self.Velocity.Magnitude))
end

function BasicProjectile.Methods:Forward(delta)
    self.Tick += delta

    local cframe = self:GetCFrameAtTick(self.Tick)
    self.Position = cframe.Position

    return cframe
end

function BasicProjectile.Methods:SetTick(tick)
    self.Tick = tick

    local cframe = self:GetCFrameAtTick(self.Tick)
    self.Position = cframe.Position
end

function BasicProjectile:Constructor(origin, velocity, gravity)
    origin      = origin    or self.Origin
    velocity    = velocity  or self.Velocity
    gravity     = gravity   or workspace.Gravity

    self.Origin     = origin
    self.Velocity   = velocity
    self.Gravity    = gravity

    local dir = velocity.Unit
    local a = VectorUtils.angle(dir, Vector3.new(dir.X, 0, dir.Z).Unit)
    if dir.Y < 0 then
        self.Angle = -a
    else
        self.Angle = a
    end
end

function BasicProjectile:start()
    VectorUtils = self:Load("Deus.VectorUtils")
    CFrameUtils = self:Load("Deus.CFrameUtils")

    self.PrivateProperties = {}

    self.PublicReadOnlyProperties = {
        Tick = 0,
        Origin = Vector3.new(),
        Velocity = Vector3.new(),
        Gravity = 0,
        Angle = 0,

        Position = Vector3.new(),
        CFrame = CFrame.new()
    }

    self.PublicReadAndWriteProperties = {}

    return self:Load("Deus.BaseObject").new(self)
end

return BasicProjectile