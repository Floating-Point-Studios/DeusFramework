local TweenService = shared.Deus.import("Deus.TweenService")

local Cutscene = {}

function Cutscene.play(scene)
    
end

function Cutscene.create(sceneData)
    local cutscene = {}

    for i, scene in pairs(sceneData) do
        table.insert(cutscene, TweenService:Create())
    end
end

return Cutscene