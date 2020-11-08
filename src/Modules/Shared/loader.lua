local Deus = {}
local Modules = {}

shared.Deus = Deus

function Deus.import(moduleName: string)
    local module = Modules[moduleName]
    if typeof(module) == "Instance" then
        Modules[moduleName] = require(module)
        module = Modules[moduleName]
    end
    return module
end

function Deus.addBranch(branch: Instance, branchName: string?)
    branchName = branchName or branch.Name

    for _,module in pairs(branch:GetDescendants()) do
        if module:IsA("ModuleScript") and not module:FindFirstAncestorWhichIsA("ModuleScript") then
            Modules[("%s.%s"):format(branchName, module.Name)] = module
        end
    end

    for name, module in pairs(Modules) do
        if name:sub(1, #branchName) == branchName and typeof(module) == "Instance" then
            Modules[name] = require(module)
        end
    end
end

Deus.addBranch(script.Parent.Parent, "Deus")

return nil