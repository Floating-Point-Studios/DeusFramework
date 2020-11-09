local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local Rendering = {}

function Rendering.createRenderPipeline(name, priority)
    local self = {
        Pipeline = {}
    }

    RunService:BindToRenderStep(name, priority, function()
        for i,v in pairs(self.Pipeline) do
            if v.Update then
                v:Update()
            else
                self.Pipeline[i] = nil
            end
        end
    end)

    return setmetatable(self, {__index = Rendering})
end

-- @param obj: object with a function named 'Update'
function Rendering:Add(obj)
    self.Pipeline[HttpService:GenerateGUID(false)] = obj
end

return Rendering