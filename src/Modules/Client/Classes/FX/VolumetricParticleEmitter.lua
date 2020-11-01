-- Used to emit particles only within a sphere or cylinder

local VolumetricParticleEmitter = {}

function VolumetricParticleEmitter.new(obj: Part, partType, properties)
    local self = {
        _obj = obj,
        _attachment = Instance.new("Attachment"),
        _partType = partType,
        ParticleEmitter = Instance.new("ParticleEmitter")
    }

    self.ParticleEmitter.Parent = self._attachment

    for i,v in pairs(properties) do
        self.ParticleEmitter[i] = v
    end

    return setmetatable(self, {__index = VolumetricParticleEmitter})
end

function VolumetricParticleEmitter:Update()
    if self._partType == Enum.PartType.Ball then

    elseif self._partType == Enum.PartType.Cylinder then
        
    end
end

return VolumetricParticleEmitter