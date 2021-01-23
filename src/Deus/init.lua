local Modules = {}
local Settings = require(script.Settings)
local Deus = shared.Deus
local DefaultSettings = require(script.Settings)

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

local function registerModule(module, path)
    assert(not Modules[path], ("[Deus] Error on start, module path '%s' already exists"):format(path))

    if module.Name:lower():match("service") then
        Modules[path] = loadModule(module)
    else
        Modules[path] = module
    end
end

if not Deus then
    Deus = {}

    -- Can only be used once
    function Deus:SetSettings(newSettings)
        if typeof(newSettings) == "Instance" and newSettings:IsA("ModuleScript") then
            newSettings = require(newSettings)
        end
        Settings = newSettings
        Deus.SetSettings = nil
    end

    function Deus:GetSetting(settingName)
        local settingPath = string.split(settingName, ".")

        local success, setting = pcall(function()
            return Settings[settingPath[1]][settingPath[2]]
        end)

        if not success then
            success, setting = pcall(function()
                return DefaultSettings[settingPath[1]][settingPath[2]]
            end)
        end

        assert(success, ("[Deus] Error finding setting %s.%s"):format(settingPath[1], settingPath[2]))
        return setting
    end

    function Deus:Register(addon, addonName)
        addonName = addonName or addon.Name

        if addon:IsA("ModuleScript") then
            registerModule(addon, addonName)
        else
            for _,module in pairs(addon:GetDescendants()) do
                if module:IsA("ModuleScript") and not module:FindFirstAncestorWhichIsA("ModuleScript") then
                    local moduleName = string.split(module.Name, ".")[1]
                    registerModule(module, addonName.. ".".. moduleName)
                end
            end
        end
    end

    function Deus:Load(path, timeout)
        local module = Modules[path]

        if not module then
            local waitStart = tick()
            repeat
                module = Modules[path]
                wait()
            until module or tick() - waitStart > (timeout or 3)
        end

        assert(module, "[Deus] Error finding module ".. path)

        if typeof(module) == "Instance" then
            module = loadModule(module)
            Modules[path] = module
            return module
        else
            return module
        end
    end

    shared.Deus = Deus
end

return Deus