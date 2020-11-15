local Debug = {}

-- Creates a log in Deus without outputting to console
function Debug.log(...)
    
end

-- Replaces Roblox print function
function Debug.print(...)
    print(("[Deus] [%s]:"):format(getfenv(2).script.Name), ...)
end

-- Replaces Roblox warn function
function Debug.warn(...)
    warn(("[Deus] [%s]:"):format(getfenv(2).script.Name), ...)
end

-- Replaces Roblox error function
function Debug.error(...)
    error(("[Deus] [%s]:"):format(getfenv(2).script.Name), ..., 2)
end

-- Replaces Roblox assert function
function Debug.assert(condition, ...)
    if not condition then
        error(("[Deus] [%s]:"):format(getfenv(2).script.Name), ..., 2)
    end
end

return Debug