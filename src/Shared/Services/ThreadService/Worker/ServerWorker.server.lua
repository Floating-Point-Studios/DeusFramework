local Worker = script.Parent

if Worker:IsA("Actor") then
    function Worker.AssignTask.OnInvoke(func, ...)
        task.desynchronize()
        func(...)
        task.synchronize()
    end
end