local Team = require(script.Team)

local TeamService = {}

function TeamService.new()
    return Team.new()
end

return TeamService