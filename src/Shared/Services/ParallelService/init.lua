local Worker

local Workers = {}

local ParallelService = {}

function ParallelService.run(module, funcName, ...)
    local worker = Workers[1]

    if worker then
        table.remove(Workers, 1)
    else
        worker = Worker.new()
    end

    local result = worker:RunJob(module, funcName, ...)

    table.insert(Workers, worker)

    return unpack(result)
end

function ParallelService:start()
    Worker = self:WrapModule(script.Worker, true, true)
end

return ParallelService