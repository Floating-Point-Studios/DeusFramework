local Packages = {}
local Modules = {}

function __newindex()
    error("[Deus] Locked metatable, attempt to modify loaded module")
end

function __tostring()
    return "[Deus] Locked metatable"
end

local LoaderMeta = {}

function LoaderMeta:Load(path)
    local module = Modules[path]

    if not module then
        warn(("Could not find module %s beginning yield"):format(path))

        local waitStart = tick()
        local waitEnd
        repeat
            wait()
            waitEnd = tick()
            module = Modules[path]
        until module or waitEnd - waitStart > 3

        if not module then
            warn(("Could not find module %s after %s second yield, check load order"):format(path, waitEnd - waitStart))
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
    return Modules[path]
end

function LoaderMeta:WrapModule(module, shouldInit, shouldStart, state)
    local args = {require(module)}

    if type(args[1]) == "table" then
        module = args[1]

        -- Module metadata, uses underscore to try to avoid name collision
        local moduleData = {
            _InitTick = -1,
            _StartTick = -1
        }

        -- If the MainModule is Deus itself then leave it nil
        if self ~= LoaderMeta then
            moduleData._MainModule = self
        end

        setmetatable(
            module,
            {
                __index = setmetatable(
                    moduleData,
                    {
                        __index = LoaderMeta
                    }
                )
            }
        )

        local init = module.init
        if init then
            module.init = function()
                module.init = nil
                init(module, state)
                moduleData._InitTick = tick()
            end

            if shouldInit then
                module:init(state)
            end
        end

        local start = module.start
        if start then
            module.start = function()
                module.start = nil
                moduleData._StartTick = tick()
                return start(module)
            end

            if shouldStart then
                local substituteModule = module:start()

                if substituteModule then
                    return substituteModule
                end

                module.start = nil
                moduleData._StartTick = tick()
            end
        end

        return module
    elseif type(args[1]) == "function" then
        local func = args[1]

        return function(...)
            func(LoaderMeta, ...)
        end
    end
end

function LoaderMeta:WrapFunction(callback, ...)
    return callback(LoaderMeta, ...)
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

function LoaderMeta:GetModules()
    return Modules
end

function LoaderMeta:GetPackages()
    return Packages
end

-- Only reliable way I've found of checking if the script is a plugin so far is a hard-coded value
function LoaderMeta:IsPluginFramework()
    return false
end

return LoaderMeta