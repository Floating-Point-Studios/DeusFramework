local Players = game:GetService("Players")

local Deus = shared.Deus
local Output = Deus:Load("Deus.Output")

local RemoteEvent = {}

function RemoteEvent:FireClient(internalAccess, player, ...)
    Output.assert(internalAccess, "Attempt to use internal method")
    self.LastSendTick = tick()
    self.RBXEvent:FireClient(player, ...)
end

function RemoteEvent:FireClients(internalAccess, players, ...)
    Output.assert(internalAccess, "Attempt to use internal method")
    self.LastSendTick = tick()
    for _,player in pairs(players) do
        self.RBXEvent:FireClient(player, ...)
    end
end

function RemoteEvent:FireAllClients(internalAccess, ...)
    Output.assert(internalAccess, "Attempt to use internal method")
    self.LastSendTick = tick()
    self.RBXEvent:FireAllClients(...)
end

function RemoteEvent:FireNearbyClients(internalAccess, pos, radius, ...)
    Output.assert(internalAccess, "Attempt to use internal method")
    self.LastSendTick = tick()
    local args = {...}
    for _,player in pairs(Players:GetPlayers()) do
        pcall(function()
            if (player.Character.HumanoidRootPart.Position - pos).Magnitude < radius then
                self.RBXEvent:FireClient(player, args)
            end
        end)()
    end
end

function RemoteEvent:Listen(internalAccess, func)
    return self.RBXEvent.OnServerEvent:Connect(func)
end

return RemoteEvent