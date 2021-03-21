local Packages = {}
local Modules = {}
local GlobalContexts = {
    Global = {}
}
local ModuleContexts = {
    Global = setmetatable({}, {__mode = "v"})
}

function __newindex()
    error("[Deus] Locked metatable, attempt to modify loaded module")
end

function __tostring()
    return "[Deus] Locked metatable"
end

--[[
function newModuleProxy(module)
    local proxy = newproxy(true)
    local meta = getmetatable(proxy)

    meta.__metatable = "[Deus] Locked metatable"
    meta.__index = module
    meta.__newindex = __newindex
    meta.__tostring = __tostring

    return proxy
end
]]

local LoaderMeta = {}

function LoaderMeta:Load(path)
    local module = Modules[path]

    if not module then
        warn(("Could not find module '%s' beginning yield"):format(path))

        local waitStart = tick()
        local waitEnd
        repeat
            wait()
            waitEnd = tick()
            module = Modules[path]
        until module or waitEnd - waitStart > 3

        if not module then
            warn(("Could not find module '%s' after %s second yield, check load order"):format(path, waitEnd - waitStart))
        end
    end

    if typeof(module) == "Instance" and module:IsA("ModuleScript") then
        -- Module depends on another module that isn't loaded yet
        module = LoaderMeta:WrapModule(module, true)
        Modules[path] = module
    end

    if module.init then
        module:init()
    end

    if module.start then
        local substituteModule = module:start()

        if substituteModule then
            module = substituteModule
            Modules[path] = module
        end
    end

    -- Return module anyway in event error can be circumvented
    return module
end

function LoaderMeta:WrapModule(module, init, start)
    module = require(module)

    --[[
    module.Load = LoaderMeta.Load
    module.WrapModule = LoaderMeta.WrapModule
    module.Register = LoaderMeta.Register
    ]]

    -- Module metadata, uses underscore to try to avoid name collision
    local moduleData = {}

    -- If the MainModule is Deus itself then leave it nil
    if self ~= LoaderMeta then
        moduleData._MainModule = self
    end

    setmetatable(module, {__index = setmetatable(moduleData, {__index = LoaderMeta})})

    if module.init then
        if init then
            module:init()
            module.init = nil
            moduleData._InitTick = tick()
        else
            local moduleInit = module.init
            module.init = function()
                moduleInit(module)
                module.init = nil
                moduleData._InitTick = tick()
            end
        end
    end

    if module.start then
        if start then
            local substituteModule = module:start()

            if substituteModule then
                return substituteModule
            end

            module.start = nil
            moduleData._StartTick = tick()
        else
            local moduleStart = module.start

            module.start = function()
                module.start = nil
                moduleData._StartTick = tick()
                return moduleStart(module)
            end
        end
    end

    return module
end

function LoaderMeta:Register(instance, moduleName)
    moduleName = moduleName or instance.Name

    if not table.find(Packages, moduleName) then
        table.insert(Packages, moduleName)
    end

    if instance:IsA("ModuleScript") then
        Modules[moduleName] = LoaderMeta:WrapModule(instance, true)
    else
        local libraries = {}
        local classes = {}
        local services = {}
        local misc = {}

        for _,module in pairs(instance:GetDescendants()) do
            -- Check if module is a submodule
            if module:IsA("ModuleScript") and not module:FindFirstAncestorWhichIsA("ModuleScript") then
                -- Attempt to classify the module
                if module:FindFirstAncestor("Libraries") or module:FindFirstAncestor("libraries") or module.Name:sub(#module.Name - 5, #module.Name) == "Utils" then
                    table.insert(libraries, module)
                elseif module:FindFirstAncestor("Classes") or module:FindFirstAncestor("classes") then
                    table.insert(classes, module)
                elseif module:FindFirstAncestor("Services") or module:FindFirstAncestor("services") or module.Name:sub(#module.Name - 7, #module.Name) == "Service" then
                    table.insert(services, module)
                else
                    table.insert(misc, module)
                end
            end
        end

        for _,module in pairs(libraries) do
            Modules[("%s.%s"):format(moduleName, module.Name)] = module -- LoaderMeta:WrapModule(module, true)
        end

        for _,module in pairs(classes) do
            Modules[("%s.%s"):format(moduleName, module.Name)] = module -- LoaderMeta:WrapModule(module, true)
        end

        for _,module in pairs(misc) do
            Modules[("%s.%s"):format(moduleName, module.Name)] = module -- LoaderMeta:WrapModule(module, true)
        end

        -- Services is split so the path is registered first in case any services depend on other services
        for _,module in pairs(services) do
            Modules[("%s.%s"):format(moduleName, module.Name)] = module -- LoaderMeta:WrapModule(module, true, true)
        end

        for _,module in pairs(services) do
            local path = ("%s.%s"):format(moduleName, module.Name)
            module = Modules[path]

            if type(module) == "table" then
                Modules[path] = LoaderMeta:WrapModule(module, true, true)
            end
        end
    end
end

-- Checks if path is registered
function LoaderMeta:IsRegistered(path)
    local splitPath = string.split(path, ".")

    if #splitPath == 1 then
        if table.find(Packages, splitPath[1]) then
            return true
        end
    else
        if Modules[path] then
            return true
        end
    end

    return false
end

-- Set variable in a context, defaults to global context
function LoaderMeta:SetContext(...)
    local args = {...}

    if #args == 3 then
        local contextName = args[1]
        local i = args[2]
        local v = args[3]

        if not GlobalContexts[contextName] then
            GlobalContexts[contextName] = {[i] = v}
            ModuleContexts[contextName] = setmetatable({}, {__mode = "v"})
        else
            GlobalContexts[contextName][i] = v
        end

        -- Update scripts within context
        for _,env in pairs(ModuleContexts[contextName]) do
            env[i] = v
        end
    elseif #args == 2 then
        local i = args[1]
        local v = args[2]
        GlobalContexts.Global[i] = v

        -- Update scripts within context
        for _,env in pairs(ModuleContexts.Global) do
            env[i] = v
        end
    else
       error("Expected 2 or 3 arguments", 2)
    end
end

--[[
    Set script to a context, defaults to global context
    Script can have multiple contexts, variable name conflicts can occur, last injected variable is the one set
]]
function LoaderMeta:GetContext(contextName, level)
    contextName = contextName or "Global"

    local context = GlobalContexts[contextName]

    assert(context, ("Context %s could not be found"):format(contextName))

    local env = getfenv(2 + (level or 0))

    for i,v in pairs(context) do
        env[i] = v
    end

    table.insert(ModuleContexts[contextName], env)
end

-- Returns the module which wrapped it, if the module is not a submodule it will return Deus
function LoaderMeta:GetMainModule()
    return self._MainModule
end

-- Returns when the module was initiated
function LoaderMeta:GetInitTick()
    return self._InitTick
end

-- Returns when the module was started
function LoaderMeta:GetStartTick()
    return self._StartTick
end

-- Only reliable way I've found of checking if the script is a plugin so far is a hard-coded value
function LoaderMeta:IsPluginFramework()
    return false
end

return LoaderMeta