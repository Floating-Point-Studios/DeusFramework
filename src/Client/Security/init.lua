local Deus = shared.Deus

local Debug = Deus:Load("Deus/Debug")

local EnvironmentVariablesRef = require(script.EnvironmentVariables)

local function threadPermissionTest()
    game:GetService("CoreGui")
end

local function checkForEnvVars(vars, env)
    local finds = 0
    for varName, varType in pairs(vars) do
        local v = vars[varName]
        if v and type(v) == varType then
            finds += 1
        end
    end
    return finds
end

local Security = {}

function Security.getenvs()
    local environments = {}
    for i = 1, math.huge do
        local success, env = pcall(function()
            return getfenv(i)
        end)

        if success then
            table.insert(environments, env)
        else
            return environments
        end
    end
end

function Security.isThreadPermissionNormal()
    local success = pcall(threadPermissionTest)
    return not success
end

function Security.isExploitEnv(env)
    for exploitName, vars in pairs(EnvironmentVariablesRef.Exploits) do
        if checkForEnvVars(vars, env) >= 3 then
            return true, exploitName
        end
    end
    return false
end

function Security.removeSource()
    local env = getfenv(2)
    local curScript = env.script
    Debug.assert(curScript:IsA("ModuleScript"), "Source can only be removed from ModuleScripts")

    local dummy = Instance.new("ModuleScript")
    dummy.Name = curScript.Name
    dummy.Parent = curScript.Parent

    for _,v in pairs(curScript:GetChildren()) do
        v.Parent = dummy
    end

    env.script = dummy

    return dummy
end

function Security.inspectThread(deepScan)
    local test1 = false
    local test2 = false

    test1 = Security.isThreadPermissionNormal()

    if deepScan then
        local envs = Security.getenvs()
        test2 = Security.isExploitEnv(envs[#envs])
    end

    return test1 or test2
end

function Security.init()
    script.EnvironmentVariables:Destroy()
    Security.removeSource()
end

return Security