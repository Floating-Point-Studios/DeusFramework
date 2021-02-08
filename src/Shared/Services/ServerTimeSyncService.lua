local RunService = game:GetService("RunService")

local Deus = shared.Deus

local NetworkService = Deus:Load("Deus.NetworkService")

local ServerTimeOffset = 0
local ServerTimeSyncService = {}

if RunService:IsServer() then
    NetworkService.makeRemoteFunction("ServerTimeSync"):Listen(function()
        return tick()
    end)
else
    function ServerTimeSyncService.getServerTime()
        return tick() - ServerTimeOffset
    end

    local serverTimeSyncRemote = NetworkService.getRemoteFunction("ServerTimeSync")
    repeat
        local invokeStartTick = tick()
        local differenceTicks = ServerTimeSyncService.getServerTime() - serverTimeSyncRemote:InvokeServer()
        local invokeEndTick = tick()

        ServerTimeOffset += differenceTicks - (invokeEndTick - invokeStartTick) / 2
        wait()
    until math.abs(differenceTicks) < 0.1
end

return ServerTimeSyncService