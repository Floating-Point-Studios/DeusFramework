local ServerStorage = game:GetService("ServerStorage")

local Load = require(script.Load)
local Register = require(script.Register)
local Setup = require(script.Setup)

local Deus = {
    Libraries = {},

    Load = Load,
    Register = Register,
    Setup = Setup
}

shared.DeusFramework = Deus

local Packages = ServerStorage:WaitForChild("DeusPackages", 5)
if Packages then
    for _,package in pairs(Packages:GetChildren()) do
        Deus:Setup(package)
    end
    Packages:Destroy()
end

return Deus