local actor = script.Parent
if actor:IsA("Actor") then
    function actor.NewJob.OnInvoke(module, functionName, ...)
        task.desynchronize()

        local result = require(module)[functionName](...)

        task.synchronize()

        return result
    end
else
    script.Disabled = true
end