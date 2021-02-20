local BasicProjectile
local DragProjectile
local LaserProjectile

local Projectiles = {}

function Projectiles.newBasicProjectile(...)
    return BasicProjectile.new(...)
end

function Projectiles.newDragProjectile(...)
    return DragProjectile.new(...)
end

function Projectiles.newLaser(...)
    return LaserProjectile.new(...)
end

function Projectiles:start()
    BasicProjectile = self:WrapModule(script.BasicProjectile, true, true)
    DragProjectile = self:WrapModule(script.DragProjectile, true, true)
    LaserProjectile = self:WrapModule(script.DragProjectile, true, true)
end

return Projectiles