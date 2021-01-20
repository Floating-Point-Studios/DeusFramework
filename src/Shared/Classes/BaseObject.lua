local HttpService = game:GetService("HttpService")

local Deus = shared.Deus

local TableUtils = Deus:Load("Deus.TableUtils")

function __tostring(self)
    return ("[DeusObject] {%s} {%s}"):format(self.ClassName, self.ObjectId)
end

local BaseObject = {}

function BaseObject.__index(self, i)

end

function BaseObject.__newindex(self, i, v)

end

function BaseObject.new(objData)
    
end

function BaseObject:Extend(obj)
    
end

function BaseObject:SetInstance(obj)
    
end

function BaseObject:Serialize()
    
end

return BaseObject