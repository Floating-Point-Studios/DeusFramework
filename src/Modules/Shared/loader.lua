--!strict

local Deus = {}

local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local function IntializeModule(module)
    if not module.IsIntialized then
        module.Module.Init()
        module.IsIntialized = true
    end
end

local function DeusRequire(moduleName: string)
    local module = Deus[moduleName]
    IntializeModule(module)
    return module.Module
end

shared.Setup = function()
    -- Removes source from ModuleScripts
    if RunService:IsClient() and not RunService:IsStudio() then

        local environment = getfenv(2)
        local moduleScript = environment.script
        local dummy = Instance.new("ModuleScript")

        for _,child in pairs(moduleScript:GetChildren()) do
            child.Parent = dummy
        end

        --dummy.Name = HttpService:GenerateGUID(false)

        environment.script = dummy
        dummy.Parent = moduleScript.Parent
        moduleScript.Name = ""
        moduleScript.Parent = nil
        moduleScript = nil

    end

    return DeusRequire
end

local function AddDirectory(instance)
    for _,v in pairs(instance:GetChildren()) do
        if v:IsA("ModuleScript") and v ~= script then
            if not Deus[v.Name] then
                Deus[v.Name] = {Module = v, IsIntialized = false}
            else
                warn(("Overwriting '%s' due to name conflict").gsub(Deus.Name))
            end
        else
            AddDirectory(v)
        end
    end
end

for _,module in pairs(Deus) do
    IntializeModule(module)
    if RunService:IsClient() and not RunService:IsStudio() then
        module.Module.Name = HttpService:GenerateGUID(false)
    end
end