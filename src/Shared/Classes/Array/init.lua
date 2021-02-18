local Array2D
local Array3D

local Array = {}

function Array:start()
    Array2D = self:WrapModule(script.Array2D)
    Array3D = self:WrapModule(script.Array3D)
end

return Array