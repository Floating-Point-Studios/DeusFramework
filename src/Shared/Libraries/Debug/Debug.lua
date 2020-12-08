local Debug = {}

function Debug.print(msg, ...)
    print(("[DEUS] %s"):format(msg:format(...)))
end

function Debug.warn(msg, ...)
    warn(("[DEUS] %s"):format(msg:format(...)))
end

function Debug.error(level, msg, ...)
    error(("[DEUS] %s"):format(msg:format(...)), level)
end

function Debug.assert(condition, msg, ...)
    if not condition then
        error(("[DEUS] %s"):format(msg:format(...)))
    end
end

function Debug.benchmark(func, trials, ...)
    local benchmarkTime = 0
    for i = 1, trials do
        local startTime = tick()
        func(...)
        local endTime = tick()
        benchmarkTime += endTime - startTime
    end

    benchmarkTime /= trials
    Debug.print("Benchmark averaged %sns after %s trials", math.round(benchmarkTime * 1000000000), trials)

    return benchmarkTime
end

return Debug