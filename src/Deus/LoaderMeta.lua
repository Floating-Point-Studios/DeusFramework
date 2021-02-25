local Modules = {}

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

    setmetatable(module, {__index = LoaderMeta})

    if module.init then
        if init then
            module:init()
            module.init = nil
        else
            local moduleInit = module.init
            module.init = function()
                moduleInit(module)
                module.init = nil
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
        else
            local moduleStart = module.start

            module.start = function()
                module.start = nil
                return moduleStart(module)
            end
        end
    end

    return module
end

function LoaderMeta:Register(instance, moduleName)
    moduleName = moduleName or instance.Name

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

return LoaderMeta