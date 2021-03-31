local RunService = game:GetService("RunService")

local Workers
local WorkerServer = script.WorkerServer
local WorkerClient = script.WorkerClient

local Worker = {
    ClassName = "Worker",
    Events = {"JobAssigned", "JobFinished"}
}

function Worker:RunJob(module, funcName, ...)
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

function Worker:Destructor()
    self.Actor:Destroy()
end

function Worker:start()
    Workers = Instance.new("Folder")
    Workers.Name = "Workers"
    Workers.Parent = workspace

    self.Private = {
        Actor = self:Load("Deus.Symbol").get("None")
    }

    self.Readable = {
        Busy = false
    }

    self.Writable = {}

    return self:Load("Deus.BaseObject").new(self)
end

return Worker