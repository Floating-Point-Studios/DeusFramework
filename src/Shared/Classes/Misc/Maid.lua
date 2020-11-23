local Deus = shared.DeusFramework

local TableProxy = Deus:Load("Deus/TableProxy")

local MaidMetatables = setmetatable({}, {__mode = "kv"})

local Maid = {}

function Maid.new()
    local self, metatable = TableProxy.new(
        {
            __index = Maid;

            Internals = {
                Tasks = {};
            };
        }
    )

    MaidMetatables[self] = metatable

    return self
end

function Maid:GiveTask(task)
    if not TableProxy.isInternalAccess(self) then
        self = MaidMetatables[self]
    end

    local tasks = self.Tasks
    local taskId = #tasks + 1

    tasks[taskId] = task

    return taskId
end

function Maid:DoCleaning()
    if not TableProxy.isInternalAccess(self) then
        self = MaidMetatables[self]
    end

    local tasks = self.Tasks

    for i, task in pairs(tasks) do
        if task.Disconnect then
            tasks[i] = nil
            task:Disconnect()
        end
    end

    local i, task = next(tasks)
	while task ~= nil do
		tasks[i] = nil
		if type(task) == "function" then
			task()
		elseif task.Disconnect then
			task:Disconnect()
		elseif task.Destroy then
			task:Destroy()
		end
		i, task = next(tasks)
	end
end

return Maid