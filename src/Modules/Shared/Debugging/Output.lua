local Output = {}

-- Creates a log in Deus without outputting to console
function Output.log(...)
    
end

-- Replaces Roblox print function
function Output.print(...)
    print(("[Deus] [%s]:"):format(getfenv(2).script.Name), ...)
end

-- Replaces Roblox warn function
function Output.warn(...)
    warn(("[Deus] [%s]:"):format(getfenv(2).script.Name), ...)
end

-- Replaces Roblox error function
function Output.error(...)
    error(("[Deus] [%s]:"):format(getfenv(2).script.Name), ...)
end

return Output