local Team = shared.Deus.import("Deus.Baseclass").new("Deus/Team")

function Team.Constructor(self, players)
    self._players = players or {}

    self.SpawnPoints = {}
end

function Team:AddPlayer(player)
    
end

function Team:RemovePlayer(player)
    
end

function Team:GetPlayers()
    return self._players
end

return Team