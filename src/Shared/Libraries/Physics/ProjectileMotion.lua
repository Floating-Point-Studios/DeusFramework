local ProjectileMotion = {}

function ProjectileMotion.calcNoDrag(time, start, dir, startVelocity, gravity)
    gravity = gravity or workspace.Gravity
end

function ProjectileMotion.calcWithDrag(time, start, dir, startVelocity, mass, gravity, gasDensity, dragCoefficient, area)
    gravity = gravity or workspace.Gravity
    gasDensity = gasDensity or 1.225

    local weight = mass * gravity
    local terminalVelocity = math.sqrt((2 * weight) / (dragCoefficient * gasDensity * area))

end

function ProjectileMotion.calcLaunchAngleToTargetNoDrag(start, target, startVelocity)
    
end

function ProjectileMotion.calcLaunchAngleToTargetWithDrag(start, target, startVelocity)
    
end

return ProjectileMotion