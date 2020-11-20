local deusFramework = script.Parent
local loader = require(deusFramework:WaitForChild("Shared")[".loader"])
loader:SetupFramework(deusFramework)
loader:Register(script, "Deus", {"loader"})
deusFramework:Destroy()