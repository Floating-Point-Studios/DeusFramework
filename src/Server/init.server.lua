local deusFramework = script.Parent
local loader = require(deusFramework:WaitForChild("Shared")[".loader"])

loader:Setup(deusFramework)
loader:Register(script, "Deus", {"loader"})

deusFramework:Destroy()