local Projectile = shared.Deus.import("Deus.BaseClass").new("Deus.Projectile")

local gravity = workspace.Gravity
local destroyHeight = workspace.FallenPartsDestroyHeight

local function getProjectileCFrame(startTime, startCFrame, startVelocity): CFrame
    local elapsed = tick() - startTime
    return startCFrame + startVelocity * elapsed - gravity * elapsed^2 / 2
end

-- @param start: CFrame of start position and orientation of projectile
-- @param Velocity: starting velocity
-- @param maskAlignToArc: whether the mask should have its orientation aligned to the angle of the arc or remain static, defaults to true
-- @param mask: object to use as mask, defaults to none
function Projectile.Constructor(self, start: CFrame, Velocity: number, maskAlignToArc: boolean?, mask: Instance?)
    self._startTime = tick()
    self.StartCFrame = start
    self.Velocity = Velocity
    self.MaskAlignToArc = maskAlignToArc or true
    self.Mask = mask
end

function Projectile:Update()
    local newCFrame = getProjectileCFrame(self._startTime, self.StartCFrame, self.Velocity)
    -- If projectile has a OnUpdate function run it, if it returns false destroy the projectile
    -- If projectile is below workspace.FallenPartsDestroyHeight then destroy the projectile
    if (self.OnUpdate and not self.OnUpdate(self, newCFrame)) or newCFrame.Y < destroyHeight then
        self:Destroy()
        return
    end

    if self.Mask then
        if self.MaskAlignToArc then
            self.Mask.CFrame = newCFrame
        else
            self.Mask.CFrame = CFrame.new(newCFrame.Position)
        end
    end
end

return Projectile