local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local RenderingService = {}

function RenderingService.createRenderPipeline(name, priority)
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

    return setmetatable(self, {__index = RenderingService})
end

-- @param obj: object with a function named 'Update'
function RenderingService:Add(obj)
    self.Pipeline[HttpService:GenerateGUID(false)] = obj
end

return RenderingService