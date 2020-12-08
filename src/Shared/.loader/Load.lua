local createModuleProxy = require(script.Parent.ModuleProxy)

return function(deus, pathName)
    local module = deus.Libraries[pathName]

    if not module then
        local waitStart = tick()
        repeat
            module = deus.Libraries[pathName]
            wait()
        until module or tick() - waitStart > 30
        assert(module, ("Module path '%s' was not found"):format(pathName))
    end

    if typeof(module) == "Instance" then
        module = createModuleProxy(module)
        deus.Libraries[pathName] = module
    end

    local init = module.init
    if init then
        init()
    end

    return module
end