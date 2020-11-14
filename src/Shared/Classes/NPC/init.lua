local RunService = game:GetService("RunService")

local Raycaster = shared.Deus.import("Deus.Raycaster")
local InstanceUtils = shared.Deus.import("Deus.InstanceUtils")

local AnimationController = require(script.AnimationController)
local MovementController = require(script.MovementController)
local StateController = require(script.StateController)

local NPC = shared.Deus.import("Deus.BaseClass").new("NPC")

function NPC.Constructor(self, body)
    if not body then
        body = Instance.new("Model")

        local humanoidRootPart = Instance.new("Part")
        humanoidRootPart.Name = "HumanoidRootPart"
        humanoidRootPart.Transparency = 1
        humanoidRootPart.Size = Vector3.new(1, 1, 1)
        humanoidRootPart.Parent = body

        InstanceUtils.instanceConfig("Humanoid", {
            Health = {"NumberValue", 100},
            MaxHealth = {"NumberValue", 100},
            HipHeight = {"NumberValue", 2},
            WalkSpeed = {"NumberValue", 16},
            JumpPower = {"NumberValue", 50},
            CanJump = {"BoolValue", true},
            Seat = {"ObjectValue", nil},
            Rig = {"ObjectValue", nil}
        }, body)

        body.Parent = workspace

        if RunService:IsServer() then
           humanoidRootPart:SetNetworkOwner(nil)
        end
    end

    local humanoidRootPart = body:WaitForChild("HumanoidRootPart")

    self._body = body
    self._config = body:WaitForChild("Humanoid")
    self._raycaster = Raycaster.new({{body}, Enum.RaycastFilterType.Blacklist, true}, 2.1, true)

    self.AnimationController = AnimationController.new(Instance.new("AnimationController", humanoidRootPart))
    self.MovementController = MovementController.new(self)
    self.StateController = StateController.new(self)

    self.MoveDirection = Vector3.new()
    self.Jump = false
    self.Sit = false
end

function NPC:SetRig(rig)
    local rigValue = self._config.Rig
    if RunService:IsServer() then
        rigValue.Value = rig
    else
        rig = rig or rigValue.Value
        rigValue.Value = rig

        local body = self._body
        local rigParts = {}

        -- clones bodyParts into the character and sets the humanoidRootPart size
        for _,bodyPart in pairs(rig:GetChildren()) do
            if bodyPart.Name == "HumanoidRootPart" then
                if bodyPart:FindFirstChild("OriginalSize") then
                    body.HumanoidRootPart.Size = bodyPart.OriginalSize.Value
                else
                    body.HumanoidRootPart.Size = bodyPart.Size
                end
                bodyPart = bodyPart.RootRigAttachment:Clone()
                bodyPart.Parent = body.HumanoidRootPart
            else
                bodyPart = bodyPart:Clone()
                bodyPart.Massless = true -- makes controlling movement easier when everything is of the same mass
                bodyPart.Parent = body
                table.insert(rigParts, bodyPart)
            end
        end

        -- sets up the motors into the character
        for _,bodyPart in pairs(rigParts) do
            local Motor6D = bodyPart:FindFirstChildWhichIsA("Motor6D")
            local Part0Name = Motor6D.Part0.Name
            Motor6D.Part0 = body[Part0Name]
            bodyPart.Anchored = false
        end
    end

    return self
end

-- Can only be run on server
function NPC:SetPlayer(player)
    assert(RunService:IsServer(), "Setting NPC to player can only be performed on the server")

    local body = self._body
    body.Name = player.Name
    body.HumanoidRootPart:SetNetworkOwner(player)
    player.Character = body

    return self
end

function NPC:Update()
    -- Cast ray to ground
    local raycastResult = self._raycaster:Cast(self._body.HumanoidRootPart.Position, Vector3.new(0, -1, 0))

    self.StateController:Update(raycastResult)
    self.MovementController:Update(raycastResult)
end

return NPC