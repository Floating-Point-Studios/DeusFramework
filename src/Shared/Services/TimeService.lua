local RunService = game:GetService("RunService")

local TimeService = {}

function TimeService.getTicksSinceServerStart()
    
end

function TimeService.init()
    if RunService:IsClient() then

        function TimeService.getServerTick()
            
        end

        function TimeService.getTicksSinceJoined()
            return workspace.DistributedGameTime
        end

        function TimeService.start()
            
        end

    end
end

return TimeService