local RBXPlayerService = game:GetService("Players")

local Signal = shared.Deus.import("Deus.Signal")

local PlayerService = {}

setmetatable(PlayerService, {
    __index = function(i,v)
        return rawget(i, v) or RBXPlayerService[v]
    end
})

local PlayerAddedSignal = Signal.new()
local PlayerRemovingSignal = Signal.new()

PlayerAddedSignal.OnConnect = function(func, fireOnConnectedPlayers)
    if fireOnConnectedPlayers then
        for _,player in pairs(RBXPlayerService:GetPlayers()) do
            func(player)
        end
    end
end

RBXPlayerService.PlayerAdded:Connect(function(player)
    PlayerAddedSignal:Fire(player)
end)

RBXPlayerService.PlayerRemoving:Connect(function(player)
    PlayerRemovingSignal:Fire(player)
end)

PlayerService.PlayerAdded = PlayerAddedSignal
PlayerService.PlayerRemoving = PlayerRemovingSignal

return PlayerService