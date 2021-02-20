local Array2D
local Array3D

local Array = {}

function Array.new2D(...)
    return Array2D.new(...)
end

function Array.new3D(...)
    return Array3D.new(...)
end

function Array:start()
    Array2D = self:WrapModule(script.Array2D, true, true)
    Array3D = self:WrapModule(script.Array3D, true, true)
end

return Array