local RunService = game:GetService("RunService")

local Workers
local WorkerServer = script.WorkerServer
local WorkerClient = script.WorkerClient

local Worker = {}

Worker.ClassName = "Deus.Worker"

Worker.Extendable = true

Worker.Replicable = true

Worker.Methods = {}

Worker.Events = {"JobAssigned", "JobFinished"}

function Worker.Methods:RunJob(module, funcName, ...)
    if not self.Busy then
        self.Busy = true
        self.JobAssigned:Fire()

        local result = {self.Actor.NewJob:Invoke(module, funcName, ...)}

        self.JobFinished:Fire()
        self.Busy = false

        return result
    end
end

function Worker:Constructor()
    local actor = Instance.new("Actor")
    local bindableFunction = Instance.new("BindableFunction")
    local workerScript

    if RunService:IsServer() then
        workerScript = WorkerServer:Clone()
    elseif RunService:IsClient() then
        workerScript = WorkerClient:Clone()
    end

    bindableFunction.Name = "NewJob"
    bindableFunction.Parent = actor

    workerScript.Parent = actor
    workerScript.Disabled = false

    actor.Parent = Workers

    self.Actor = actor
end

function Worker:Deconstructor()
    self.Actor:Destroy()
end

function Worker.start()
    Workers = Instance.new("Folder")
    Workers.Name = "Workers"
    Workers.Parent = workspace

    Worker.PrivateProperties = {
        Actor = Worker:Load("Deus.Symbol").new("None")
    }

    Worker.PublicReadOnlyProperties = {
        Busy = false
    }

    Worker.PublicReadAndWriteProperties = {}

    return Worker:Load("Deus.BaseObject").new(Worker)
end

return Worker