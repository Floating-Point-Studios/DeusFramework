local require = shared.Setup()

local Maid = require("Maid")

local BaseObject = {}
BaseObject.ClassName = "Deus/BaseObject"
BaseObject.__index = BaseObject

function BaseObject.new(obj)
	local self = setmetatable({}, BaseObject)

	self._maid = Maid.new()
    self._obj = obj
    
	return self
end

function BaseObject:IsA(ClassName)
    return self.ClassName == ClassName
end

function BaseObject:Destroy()
	-- local startTime = tick()
	self._maid:DoCleaning()

	-- This could emit events, which could cause bad startTime
	-- but we'll take this risk over getting the ClassName
	-- if tick() - startTime >= 0.01 then
	-- 	warn(("[BaseObject.Destroy] - Took %f ms to clean up %s")
	-- 		:format((tick() - startTime)*1000, tostring(self.ClassName)))
	-- end

	setmetatable(self, nil)
end

return BaseObject