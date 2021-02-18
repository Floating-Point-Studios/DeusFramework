local Players = game:GetService("Players")

local Output

local RemoteEvent = {}

function RemoteEvent:FireClient(player, ...)
    Output.assert(self:IsInternalAccess(), "Attempt to use internal method")
    self.LastSendTick = tick()
    self.Internal.DEUSOBJECT_Properties.RBXEvent:FireClient(player, ...)
end

function RemoteEvent:FireClients(players, ...)
    Output.assert(self:IsInternalAccess(), "Attempt to use internal method")
    self.LastSendTick = tick()
    for _,player in pairs(players) do
        self.Internal.DEUSOBJECT_Properties.RBXEvent:FireClient(player, ...)
    end
end

function RemoteEvent:FireAllClients(...)
    Output.assert(self:IsInternalAccess(), "Attempt to use internal method")
    self.LastSendTick = tick()
    self.Internal.DEUSOBJECT_Properties.RBXEvent:FireAllClients(...)
end

function RemoteEvent:FireNearbyClients(pos, radius, ...)
    Output.assert(self:IsInternalAccess(), "Attempt to use internal method")
    self.LastSendTick = tick()
    local args = {...}
    for _,player in pairs(Players:GetPlayers()) do
        pcall(function()
            if (player.Character.HumanoidRootPart.Position - pos).Magnitude < radius then
                self.Internal.DEUSOBJECT_Properties.RBXEvent:FireClient(player, args)
            end
        end)()
    end
end

function RemoteEvent:Listen(func)
    return self.Internal.DEUSOBJECT_Properties.RBXEvent.OnServerEvent:Connect(func)
end

function RemoteEvent.start()
    Output = RemoteEvent:Load("Deus.Output")
end

return RemoteEvent