local Deus = shared.DeusFramework

local HttpService = game:GetService("HttpService")

local Debug = Deus:Load("Deus/Debug")

local Node = require(script.Node)

local MeshNetwork = {}

function MeshNetwork.new()
    local self = {
        Nodes = {}
    }

    return setmetatable(self, {__index = MeshNetwork})
end

function MeshNetwork:Add(nodeToConnect)
    local node = Node.new()

    if nodeToConnect then
        if type(nodeToConnect) == "table" then
            for _,nodeToConnect2 in pairs(nodeToConnect) do
                node:Connect(nodeToConnect2)
            end
        else
            node:Connect(nodeToConnect)
        end
    end

    self.Nodes[HttpService:GenerateGUID(false)] = node

    return node
end

function MeshNetwork:Pathfind(nodeA, nodeB, algorithm)
    
end

function MeshNetwork:GetNode(nodeId)
    local node = self.Nodes[nodeId]
    Debug.assert(node, "Invalid nodeId '%' provided", nodeId)
    return node
end

return MeshNetwork