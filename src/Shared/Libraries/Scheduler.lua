local RunService = game:GetService("RunService")

local ThreadSpawner = Instance.new("BindableEvent")
ThreadSpawner.Event:Connect(function(callback, ...)
    callback(...)
end)

local Scheduler = {}

function Scheduler.wait(time)
    local waitStart = os.clock()
    local waitEnd

    if not time then
        RunService.Heartbeat:Wait()
        waitEnd = os.clock()
        return waitEnd - waitStart
    end

    repeat
        RunService.Heartbeat:Wait()
        waitEnd = os.clock()
    until waitEnd - time > waitStart
    return waitEnd - waitStart
end

function Scheduler.spawn(callback, ...)
    ThreadSpawner:Fire(callback, ...)
end

function Scheduler.delay(time, callback, ...)
    Scheduler.wait(time)
    Scheduler.spawn(callback, ...)
end

return Scheduler