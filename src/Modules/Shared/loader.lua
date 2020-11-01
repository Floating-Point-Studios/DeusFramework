local Deus = {}
local Modules = {}

function Deus.import(moduleName: string)
    return Modules[moduleName]
end

function Deus.addBranch(branch: Instance, name: string?)
    name = name or branch.Name

    for _,module in pairs(branch:GetDescendants()) do
        if module:IsA("ModuleScript") and not module:FindFirstAncestorWhichIsA("ModuleScript") then
            Modules[("%s."):format(module.Name)] = require(module)
        end
    end
end

Deus.addBranch(script, "Deus")

shared.Deus = Deus