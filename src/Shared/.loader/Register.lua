local createModuleProxy = require(script.Parent.ModuleProxy)

local function getModuleExtension(moduleName)
    return (moduleName:match("%.%w+$") or ""):sub(2):lower()
end

return function(deus, library, libraryName, extensionIgnoreList)
    extensionIgnoreList = extensionIgnoreList or {}
    libraryName = libraryName or library.Name

    local modulePaths = {}

    for _,module in pairs(library:GetDescendants()) do
        local moduleName = module.Name
        if module:IsA("ModuleScript") and not module:FindFirstAncestorWhichIsA("ModuleScript") and not table.find(extensionIgnoreList, getModuleExtension(moduleName)) then

            local path = ("%s/%s"):format(libraryName, moduleName)
            deus.Libraries[path] = module
            table.insert(modulePaths, path)

        end
    end

    for _,path in pairs(modulePaths) do
        deus.Libraries[path] = createModuleProxy(deus.Libraries[path])
    end
end