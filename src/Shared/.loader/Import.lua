function load(module)
    local metatable = getmetatable(module)
    
end

return function(deus, pathName)
    local module = deus.Libraries[pathName]

    assert(module, ("Module path '%s' was not found"):format(pathName))

    return load(module)
end