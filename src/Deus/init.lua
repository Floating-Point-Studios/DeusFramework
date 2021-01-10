local Modules = {}
local Settings = require(script.Settings)
local Deus = shared.Deus

local function __newindex()
    error("[Deus] Attempt to modify loaded module from externally")
end

local function loadModule(module)
    module = require(module)

    local proxy = newproxy(true)
    local metatable = getmetatable(proxy)

    metatable.__metatable = "[Deus] Locked Metatable"
    metatable.__index = module
    metatable.__newindex = __newindex

    return proxy
end

local function registerModule(module, addonName)
    local moduleName = string.split(module.Name, ".")[1]
    local path = addonName.. ".".. moduleName

    assert(not Modules[path], ("[Deus] Error on start, module path '%s' already exists"):format(path))

    if moduleName:lower():match("service") then
        Modules[path] = loadModule(module)
    else
        Modules[path] = module
    end
end

if not Deus then
    Deus = {}

    function Deus:SetSettings(newSettings)
        -- Can only be used once
        Settings = newSettings
        Deus.SetSettings = nil
    end

    function Deus:Register(addon, addonName)
        addonName = addonName or addon.Name

        if addon:IsA("ModuleScript") then
            registerModule(addon, addonName)
        else
            for _,module in pairs(addon:GetDescendants()) do
                if module:IsA("ModuleScript") and not module:FindFirstAncestorWhichIsA("ModuleScript") then
                    registerModule(module, addonName)
                end
            end
        end
    end

    function Deus:Load(path)
        local module = Modules[path]

        assert(module, "[Deus] Error finding ".. path)

        if type(module) == "userdata" then
            return module
        else
            module = loadModule(module)
            Modules[path] = module
            return module
        end
    end

    shared.Deus = Deus
end

return Deus