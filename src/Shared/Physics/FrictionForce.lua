local FrictionForce = {}

local FrictionCoefficients = {
    [Enum.Material.Plastic] = 0.2,
    [Enum.Material.Wood] = 0.4,
    [Enum.Material.Slate] = 0.6,
    [Enum.Material.Concrete] = 0.8,
    [Enum.Material.CorrodedMetal] = 0.6,
    [Enum.Material.DiamondPlate] = 0.1,
    [Enum.Material.Foil] = 0.7,
    [Enum.Material.Grass] = 0.35,
    [Enum.Material.Ice] = 0.05,
    [Enum.Material.Marble] = 0.5,
    [Enum.Material.Granite] = 0.4,
    [Enum.Material.Brick] = 0.5,
    [Enum.Material.Pebble] = 0.2,
    [Enum.Material.Sand] = 0.5,
    [Enum.Material.Fabric] = 0.8,
    [Enum.Material.SmoothPlastic] = 0.1,
    [Enum.Material.Metal] = 0.09,
    [Enum.Material.WoodPlanks] = 0.4,
    [Enum.Material.Cobblestone] = 0.4,
    [Enum.Material.Rock] = 0.4,
    [Enum.Material.Glacier] = 0.05,
    [Enum.Material.Snow] = 0.57,
    [Enum.Material.Sandstone] = 0.4,
    [Enum.Material.Mud] = 0.9,
    [Enum.Material.Basalt] = 0.5,
    [Enum.Material.Ground] = 0.5,
    [Enum.Material.CrackedLava] = 0.9,
    [Enum.Material.Glass] = 0.1,
    [Enum.Material.Asphalt] = 0.8,
    [Enum.Material.LeafyGrass] = 0.4,
    [Enum.Material.Salt] = 0.5,
    [Enum.Material.Limestone] = 0.4,
    [Enum.Material.Pavement] = 0.8,
}

function FrictionForce.new(obj, attachment, vectorForce)
    local self = {}

    if not vectorForce then
        attachment = attachment or Instance.new("Attachment", obj)
    end
    vectorForce = vectorForce or Instance.new("VectorForce")

    vectorForce.Force = Vector3.new()
    vectorForce.RelativeTo = Enum.ActuatorRelativeTo.World
    vectorForce.Attachment0 = attachment or vectorForce.Parent
    vectorForce.Parent = attachment or vectorForce.Parent
    self._vectorForce = vectorForce

    return setmetatable(self, {__index = FrictionForce})
end

function FrictionForce:Update(coefficient, magnitude, additive)
    local vectorForce = self._vectorForce
    local obj = vectorForce.Parent.Parent
    local velocity = obj.Velocity

    if velocity.Magnitude > 0.05 then
        if type(coefficient) ~= "number" then
            -- Defaults to a coefficient of 0.3 if no coefficient is found
            coefficient = FrictionCoefficients[coefficient] or 0.3
        end

        if additive then
            vectorForce.Force -= velocity * obj.Mass * coefficient * magnitude
        else
            vectorForce.Force = -velocity * obj.Mass * coefficient * magnitude
        end

        return coefficient
    end
    return 0
end

return FrictionForce