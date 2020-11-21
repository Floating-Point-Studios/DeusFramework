local createModuleProxy = require(script.Parent.ModuleProxy)

return function(deus, pathName)
    local module = deus.Libraries[pathName]

    if typeof(module) == "Instance" then
        module = createModuleProxy(module)
        deus.Libraries[pathName] = module
    end

    assert(module, ("Module path '%s' was not found"):format(pathName))

    local init = module.init
    if init then
        init()
    end

    return module
end