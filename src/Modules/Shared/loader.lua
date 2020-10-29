--!strict

local Deus = {}

local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local function IntializeModule(module)
    local Init = module.Module.Init
    if not module.IsIntialized and Init then
        module.Module.Init()
    end
    module.IsIntialized = true
end

local function DeusRequire(moduleName: string)
    local module = Deus[moduleName]
    IntializeModule(module)
    return module.Module
end

shared.DeusHook = function()
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

local function AddDirectory(obj)
    for _,v in pairs(obj:GetChildren()) do
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

if RunService:IsClient() then
    -- Prevents exploits that do not inject on launch from hooking into Deus, server may hook in freely at any time
    shared.DeusHook = nil
end