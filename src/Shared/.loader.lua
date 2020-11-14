local Deus = {}
local Modules = {}

shared.Deus = Deus

function Deus.import(moduleName: string)
    local module = Modules[moduleName]
    if typeof(module) == "Instance" then
        Modules[moduleName] = require(module)
        module = Modules[moduleName]
    end

    assert(module, ("Module '%s' does not exist"):format(moduleName))

    return module
end

function Deus.addBranch(branch: Instance, branchName: string?)
    branchName = branchName or branch.Name

    for _,module in pairs(branch:GetDescendants()) do
        local moduleName = module.Name
        if moduleName ~= ".loader" then -- stop infinite loops from ocurring

            if module:IsA("ModuleScript") and not module:FindFirstAncestorWhichIsA("ModuleScript") then
                Modules[("%s.%s"):format(branchName, moduleName)] = module
            end

        end
    end

    for name, module in pairs(Modules) do
        if name:sub(1, #branchName) == branchName and typeof(module) == "Instance" then
            module = require(module)

            local init = rawget(module, "Init")
            if init then
                init()
            end

            Modules[name] = module
        end
    end
end

Deus.addBranch(script.Parent.Parent, "Deus")

return nil