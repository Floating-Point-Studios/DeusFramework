local DebugPipeline = shared.Deus.import("Deus.Rendering").createRenderPipeline("Debugging", 1000)

local TextBillboard = require(script.TextBillboard)
local Arrow = require(script.Arrow)

local VisualDebugger = {}

function VisualDebugger.visualizeTextGui(obj, property)
    DebugPipeline:Add(TextBillboard.new(obj, property))
end

function VisualDebugger.visualizeArrow(obj)
    DebugPipeline:Add(Arrow.new(obj))
end

function VisualDebugger.visualizePoint()
    
end

return VisualDebugger