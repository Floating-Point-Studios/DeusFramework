local ProximityDetector = {}

ProximityDetector.ClassName = "Deus.ProximityDetector"

ProximityDetector.Events = {"Entered", "Left"}

function ProximityDetector:Constructor(pos, maxActivationDistance, requiresLineOfSight)
    if requiresLineOfSight == nil then
        requiresLineOfSight = true
    end

    local proximityPrompt = Instance.new("ProximityPrompt")
    proximityPrompt.MaxActivationDistance = maxActivationDistance or 10
    proximityPrompt.RequiresLineOfSight = requiresLineOfSight
    proximityPrompt.Style = Enum.ProximityPromptStyle.Custom

    proximityPrompt.PromptShown:Connect(function()
        self.Entered:Fire()
    end)

    proximityPrompt.PromptHidden:Connect(function()
        self.Left:Fire()
    end)

    local attachment = Instance.new("Attachment")
    proximityPrompt.Parent = attachment

    if typeof(pos) == "Vector3" then
        attachment.Position = pos
        attachment.Parent = workspace:FindFirstChildWhichIsA("Terrain")
    elseif typeof(pos) == "Instance" then
        attachment.Parent = pos
    end

    self:ReplicateProperties(attachment)

    self.PublicReadOnlyProperties.Detector = attachment
end

function ProximityDetector:Deconstructor()
    self.PublicReadOnlyProperties.Detector:Destroy()
end

function ProximityDetector.start()
    return ProximityDetector:Load("Deus.BaseObject").new(ProximityDetector)
end

return ProximityDetector