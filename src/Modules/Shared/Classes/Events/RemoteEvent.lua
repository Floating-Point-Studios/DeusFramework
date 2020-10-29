local require = shared.DeusHook()

local BaseObject = require("BaseObject")

local RemoteEvent = setmetatable({}, BaseObject)
RemoteEvent.ClassName = "Deus/RemoteEvent"
RemoteEvent.__index = RemoteEvent

if game:GetService("RunService"):IsServer() then

    local Players = game:GetService("Players")

    function RemoteEvent.new(name, parent)
        local remoteEvent = Instance.new("RemoteEvent", parent)

        local self = setmetatable(BaseObject.new(remoteEvent), RemoteEvent)

        self._connections = {}
        self._lastFired = 0

        -- Fires event to a singular client
        function self:FireClient(player: Player, ...)

        end

        -- Fires event to array of clients, if no array is provided it will use all clients
        function self:FireClients(playerList, ...)
            local playerList = playerList or Players:GetPlayers()

            for _,player in pairs(playerList) do
                self:FireClient(player, ...)
            end
        end

        -- Fires event to all players except for player provided
        function self:FireAllClientsExcept(ignorePlayer: Player, ...)
            for _,player in pairs(Players:GetPlayers()) do
                if player ~= ignorePlayer then
                    self:FireClient(player, ...)
                end
            end
        end

        -- Fires event to all clients within a radius of a point
        function self:FireAllClientsInRadius(point: Vector3, radius: number, ...)
            local Args = ...
            for _,player in pairs(Players:GetPlayers()) do
                pcall(function()  
                    if (player.Character.HumanoidRootPart.Position - point).Magnitude <= radius then
                        self:FireClient(player, Args)
                    end
                end)()
            end
        end

        function self:Connect(callback)

        end

        function self:Wait()
            
        end

        return self
    end

else

    function RemoteEvent.new(remoteEvent)
        local self = setmetatable(BaseObject.new(remoteEvent), RemoteEvent)

        self._connections = {}
        self._lastFired = 0

        -- Fires event to server
        function self:FireServer(...)
            remoteEvent:FireServer(...)
        end

        function self:Connect(callback)
            
        end

        function self:Wait()
            
        end

        return self
    end

end

return RemoteEvent