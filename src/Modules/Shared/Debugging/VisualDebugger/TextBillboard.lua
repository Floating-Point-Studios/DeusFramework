local TextBillboard = {}

function TextBillboard.new(obj, property)
    local self = {
        _obj = obj,
        _property = property,
    }

    local parent = obj
    if not parent:IsA("BasePart") then
        parent = parent:FindFirstAncestorWhichIsA("Attachment") or parent:FindFirstAncestorWhichIsA("BasePart")
    end

    local BillboardGui = Instance.new("BillboardGui")
    BillboardGui.AlwaysOnTop = true
    BillboardGui.Size = UDim2.new(16, 0, 4, 0)
    local TextGui = Instance.new("TextLabel")
    TextGui.BackgroundTransparency = 1
    TextGui.Size = UDim2.new(1, 0, 1, 0)
    TextGui.Font = Enum.Font.SourceSansBold
    TextGui.TextScaled = true
    TextGui.TextColor3 = Color3.new(1, 1, 1)
    TextGui.TextStrokeTransparency = 0
    TextGui.Parent = BillboardGui
    BillboardGui.Parent = parent

    self._textGui = TextGui

    return setmetatable(self, {__index = TextBillboard})
end

function TextBillboard:Update()
    self._textGui.Text = tostring(self._obj[self._property])
end

return TextBillboard