local require = shared.DeusHook()

local Debugger = {}

function Debugger.print(...)
    print(("[DEUS] [%s]:"):format(getfenv(2).script.Name), ...)
end

function Debugger.warn(...)
    warn(("[DEUS] [%s]:"):format(getfenv(2).script.Name), ...)
end

function Debugger.error(...)
    error(("[DEUS] [%s]:"):format(getfenv(2).script.Name), ...)
end

return Debugger