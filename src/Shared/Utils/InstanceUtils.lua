local InstanceUtils = {}

function InstanceUtils.instance(className, props, parent)
    local obj = Instance.new(className)
    for i,v in pairs(props) do
        obj[i] = v
    end
    obj.Parent = parent
    return obj
end

function InstanceUtils.instanceConfig(configName, config, parent)
    local configFolder = Instance.new("Folder")
    configFolder.Name = configName
    for i,v in pairs(config) do
        local setting = Instance.new(v[1])
        setting.Name = i
        setting.Value = v[2]
        setting.Parent = configFolder
    end
    configFolder.Parent = parent
    return configFolder
end

function InstanceUtils.onDestroy(obj, func, ...)
    local args = {...}
    obj.AncestryChanged:Connect(function(_, parent)
        if not parent then
            func(args)
        end
    end)
end

return InstanceUtils