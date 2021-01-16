local InstanceUtils = {}

function InstanceUtils.getAncestors(obj)
    local ancestors = {}
    repeat
        obj = obj.Parent
        table.insert(ancestors, obj)
    until obj.Parent == nil
    return ancestors
end

function InstanceUtils.findFirstAncestorWithName(obj, name)
    for _,ancestor in pairs(InstanceUtils.getAncestors(obj)) do
        if ancestor.Name == name then
            return ancestor
        end
    end
end

function InstanceUtils.findFirstChildNoCase(obj, name)
    name = name:lower()
    for _,child in pairs(obj:GetChildren()) do
        if child.Name:lower() == name then
            return child
        end
    end
end

function InstanceUtils.make(objData, ...)
    local className = objData[1]
    local properties = objData[2]
    local parent = objData[3]

    local obj = Instance.new(className)

    for i,v in pairs(properties) do
        obj[i] = v
    end

    for i = 4, #objData do
        objData[i][3] = obj
        InstanceUtils.make(objData[i])
    end

    obj.Parent = parent

    local objs = {obj}
    local objDataList = {...}
    for i = 1, #objDataList do
        table.insert(objs, InstanceUtils.make(objDataList[i]))
    end

    return unpack(objs)
end

return InstanceUtils