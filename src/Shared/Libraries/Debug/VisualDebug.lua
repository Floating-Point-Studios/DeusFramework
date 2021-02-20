local AdornmentUtils

local Terrain = workspace:FindFirstChildWhichIsA("Terrain")

local VisualDebug = {}

function VisualDebug.drawBox(cframe, size, color3)
    size = size or Vector3.new(1, 1, 1)
    color3 = color3 or Color3.fromRGB(13, 105, 172)

    if typeof(cframe) == "Vector3" then
        cframe = CFrame.new(cframe)
    end

    if type(size) == "number" then
        size = Vector3.new(size, size, size)
    end

    return AdornmentUtils.make("BoxHandleAdornment", Terrain, cframe, false, {
        Adornee = Terrain,
        Size = size,
        Color3 = color3
    })
end

function VisualDebug.drawSphere(pos, radius, color3)
    radius = radius or 1
    color3 = color3 or Color3.fromRGB(13, 105, 172)

    return AdornmentUtils.make("SphereHandleAdornment", Terrain, CFrame.new(pos), false, {
        Adornee = Terrain,
        Radius = radius / 2,
        Color3 = color3
    })
end

function VisualDebug.drawLine(pos1, pos2, color3)
    color3 = color3 or Color3.fromRGB(13, 105, 172)

    local length = (pos2 - pos1).Magnitude
    return AdornmentUtils.make("LineHandleAdornment", Terrain, CFrame.lookAt(pos1, pos2), false, {
        Adornee = Terrain,
        Length = length,
        Color3 = color3
    })
end

function VisualDebug.drawPath(points, radius, color3)
    radius = radius or 0.05
    color3 = color3 or Color3.fromRGB(13, 105, 172)

    local path = Instance.new("Folder")
    path.Name = "DebugPath"

    for i, pos1 in pairs(points) do
        local pos2 = points[i + 1]

        AdornmentUtils.make("SphereHandleAdornment", path, CFrame.new(pos1), false, {
            Adornee = Terrain,
            Radius = radius,
            Color3 = color3
        })

        if pos2 then
            local distance = (pos2 - pos1).Magnitude
            AdornmentUtils.make("CylinderHandleAdornment", path, CFrame.lookAt(pos1, pos2) * CFrame.new(0, 0, -(distance / 2)), false, {
                Adornee = Terrain,
                Height = distance,
                Radius = radius,
                Color3 = color3
            })
        end
    end

    path.Parent = Terrain
    return path
end

function VisualDebug.drawArrow(start, dir, radius, color3)
    radius = radius or 0.2
    color3 = color3 or Color3.fromRGB(13, 105, 172)

    local arrow = Instance.new("Folder")
    arrow.Name = "DebugArrow"

    local cframe = CFrame.lookAt(start, start + dir)
    local coneHeight = radius * 10
    local cylinderLength = dir.Magnitude - coneHeight

    AdornmentUtils.make("CylinderHandleAdornment", arrow, cframe * CFrame.new(0, 0, -cylinderLength / 2), false, {
        Adornee = Terrain,
        Height = cylinderLength,
        Radius = radius / 2,
        Color3 = color3
    })
    AdornmentUtils.make("ConeHandleAdornment", arrow, cframe * CFrame.new(0, 0, -dir.Magnitude + coneHeight), false, {
        Adornee = Terrain,
        Height = coneHeight,
        Radius = radius,
        Color3 = color3
    })

    arrow.Parent = Terrain
    return arrow
end

function VisualDebug.makeBillboardGui(name, size, text)
    if text == nil then
        text = ""
    elseif type(text) ~= "string" then
        text = tostring(text)
    end

    local billboardGui = Instance.new("BillboardGui")
    billboardGui.LightInfluence = 0
    billboardGui.Name = name or "DeusDebugGui"
    billboardGui.Size = UDim2.fromScale(size.X, size.Y)

    local textLabelGui = Instance.new("TextLabel")
    textLabelGui.BackgroundTransparency = 1
    textLabelGui.Size = UDim2.fromScale(1, 1)
    textLabelGui.TextColor3 = Color3.new(1, 1, 1)
    textLabelGui.TextScaled = true
    textLabelGui.TextStrokeTransparency = 1
    textLabelGui.Text = text
    textLabelGui.Parent = billboardGui

    return billboardGui
end

function VisualDebug:start()
    AdornmentUtils = self:Load("Deus.AdornmentUtils")
end

return VisualDebug