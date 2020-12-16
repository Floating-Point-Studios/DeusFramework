local Worker = script.Parent

if Worker:IsA("Actor") then
    function Worker.AssignTask.OnInvoke(task, ...)
        task.desynchronize()

        local result

        if type(task) == "function" then

            result = pack(task(...))

        elseif typeof(task) == "Instance" and task:IsA("ModuleScript") then

            local args = {...}
            local methodName = table.remove(args, 1)
            result = pack(require(task)[methodName](unpack(args)))

        end

        task.synchronize()

        return unpack(result)
    end
end