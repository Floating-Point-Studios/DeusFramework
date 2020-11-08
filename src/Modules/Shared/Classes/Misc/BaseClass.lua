local Maid = shared.Deus.import("Deus.Maid")

local BaseClass = {}

function BaseClass.new(className)
	local Class = {}
	Class.__index = Class
	Class.ClassName = className or "Deus/BaseClass"

	function Class.new(...)
		local self
		self._maid = Maid.new()

		if Class.super then
			self = setmetatable(Class.super.new(...), Class)
		else
			self = setmetatable({}, Class)
		end
		if Class.Constructor then
			Class.Constructor(self, ...)
		end
		return self
	end

	Class.Extends = BaseClass.Extends
	Class.IsA = BaseClass.IsA
	Class.Destroy = BaseClass.Destroy

	return Class
end

function BaseClass.Extends(self, superclass)
	setmetatable(self, {__index = superclass})
	self.super = superclass

	return self
end

function BaseClass.IsA(self, className)
	return self.ClassName == className
end

function BaseClass.Destroy(self)
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

return BaseClass