local RunService = game:GetService("RunService")

local WorkerMain
local Worker = {}

function Worker.new()
    local self = {
        Active = false
    }

    local actor = Instance.new("Actor")
    Instance.new("BindableFunction", actor).Name = "AssignTask"
    WorkerMain:Clone().Parent = actor
    actor.Parent = game

    self.Actor = actor

    return setmetatable(self, Worker)
end

function Worker:Assign(task, ...)
    if not self.Active then
        self.Active = true
        self.Actor.TaskAssign:Invoke(task, ...)
        self.Active = false
    end
end

if RunService:IsServer() then
    WorkerMain = script.ServerWorker
else
    WorkerMain = script.ClientWorker
end

return Worker