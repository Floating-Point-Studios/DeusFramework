local function getScriptName()
    local env = getfenv(3)
    if env.script and typeof(env.script) == "Instance" then
        return env.script.Name
    end
    return ""
end

local Output = {}

function Output.print(msg, args)
    if type(args) ~= "table" then
        args = {args}
    end
    print(("[Deus][%s] "):format(getScriptName()).. (msg or ""):format(unpack(args or {})))
end

function Output.warn(msg, args)
    if type(args) ~= "table" then
        args = {args}
    end
    warn(("[Deus][%s] "):format(getScriptName()).. (msg or ""):format(unpack(args or {})))
end

function Output.error(msg, args, level)
    if type(args) ~= "table" then
        args = {args}
    end
    error(("[Deus][%s] "):format(getScriptName()).. (msg or ""):format(unpack(args or {})), 2 + (level or 0))
end

function Output.assert(condition, msg, args, level)
    if type(args) ~= "table" then
        args = {args}
    end
    if not condition then
        error(("[Deus][%s] "):format(getScriptName()).. (msg or ""):format(unpack(args or {})), 2 + (level or 0))
    end
end

return Output