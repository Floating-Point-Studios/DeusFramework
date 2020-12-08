local Node = {}

function Node.new()
    local self = {
        Connections = {}
    }

    return setmetatable(self, {__index = Node})
end

function Node:Connect(node)
    table.insert(self.Connections, node)
    table.insert(node.Connections, self)
end

function Node:Disconnect(node)
    table.remove(self.Connections, table.find(self.Connections, node))
end

function Node:IsConnected(node)
    if table.find(self.Connections, node) then
        return true
    end
    return false
end

return Node