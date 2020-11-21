return function(module)
    if typeof(module) == "Instance" then
        module = require(module)
    end

    -- Return may have been a userdata
    if type(module) == "table" then
        local moduleProxy = newproxy(true)
        local metatable = getmetatable(moduleProxy)

        -- Create a wrapper for the init function to only allow it to run once
        local init = module.init
        if init and type(init) == "function" then
            module.init = function()
                module.init = false
                init()
            end
        else
            -- Checking without erroring
            module.init = false
        end

        -- Read-only module
        metatable.__metatable = "[Deus] Locked metatable"
        metatable.__index = module

        return moduleProxy
    else
        return module
    end
end