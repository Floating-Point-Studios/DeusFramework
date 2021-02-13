local Output

local ValidClasses = {
    "BoxHandleAdornment",
    "ConeHandleAdornment",
    "CylinderHandleAdornment",
    "LineHandleAdornment",
    "SphereHandleAdornment",
    "ImageHandleAdornment",
}

local AdornmentUtils = {}

function AdornmentUtils.make(className, parent, cframe, isWorldSpace, properties)
    Output.assert(table.find(ValidClasses, className), "Class '%s' is not an adornment", className)

    local adornment = Instance.new(className)

    if isWorldSpace and parent then
        adornment.CFrame = parent.CFrame:ToObjectSpace(cframe)
    elseif not isWorldSpace then
        adornment.CFrame = cframe
    end

    for i,v in pairs(properties) do
        adornment[i] = v
    end

    adornment.Parent = parent

    return adornment
end

function AdornmentUtils.start()
    Output = AdornmentUtils:Load("Deus.Output")
end

return AdornmentUtils