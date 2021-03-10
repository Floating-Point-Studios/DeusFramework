local CollectionService = game:GetService("CollectionService")

local Output

local InstanceUtils = {}

function InstanceUtils.anchor(obj, state)
    if state == nil then
        state = true
    end

    if obj:IsA("BasePart") then
        obj.Anchored = true
    end

    for _,part in pairs(obj:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Anchored = state
        end
    end
end

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

function InstanceUtils.findFirstChildNoCase(obj, name, recursive)
    name = name:lower()
    local tree
    if recursive then
        tree = obj:GetDescendants()
    else
        tree = obj:GetChildren()
    end
    for _,child in pairs(tree) do
        if child.Name:lower() == name then
            return child
        end
    end
end

function InstanceUtils.findFirstChildWithAttribute(obj, name, recursive)
    local tree
    if recursive then
        tree = obj:GetDescendants()
    else
        tree = obj:GetChildren()
    end
    for _,child in pairs(tree) do
        if child:GetAttribute(name) ~= nil then
            return child
        end
    end
end

function InstanceUtils.findFirstAncestorWithAttribute(obj, name)
    for _,ancestor in pairs(InstanceUtils.getAncestors(obj)) do
        if ancestor:GetAttribute(name) ~= nil then
            return ancestor
        end
    end
end

function InstanceUtils.findFirstAncestorWithTag(obj, tag)
    for _,ancestor in pairs(InstanceUtils.getAncestors(obj)) do
        if CollectionService:HasTag(ancestor, tag) then
            return ancestor
        end
    end
end

-- For mass setting attributes at once
function InstanceUtils.setAttributes(obj, attributes)
    for i,v in pairs(attributes) do
        obj:SetAttribute(i, v)
    end
end

local attributeSupportedDataTypes = {
    "nil",
    "string",
    "boolean",
    "number",
    "UDim",
    "UDim2",
    "BrickColor",
    "Color3",
    "Vector2",
    "Vector3",
    "NumberSequence",
    "ColorSequence",
    "NumberRange",
    "Rect",
}

function InstanceUtils.isTypeAttributeSupported(dataType)
    if table.find(attributeSupportedDataTypes, dataType) then
        return true
    end
    return false
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

function InstanceUtils:start()
    Output = self:Load("Deus.Output")
end

return InstanceUtils