local Worker = require(script.Worker)

local Workers = {}

local ThreadService = {}

function ThreadService.assign(func, ...)
    for _,worker in pairs(Workers) do
        if not worker.Active then
            Worker:Assign(func, ...)
            return true
        end
    end

    local worker = Worker.new()
    worker:Assign(func, ...)
    table.insert(Workers, worker)

    return true
end

function ThreadService.countWorkers()
    local active = 0
    for _,worker in pairs(Workers) do
        if worker.Active then
            active += 1
        end
    end

    return #Workers, active
end

return ThreadService