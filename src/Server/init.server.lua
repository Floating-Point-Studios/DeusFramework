local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- Setup server
local Deus = script.Parent.Deus
Deus.Parent = ReplicatedStorage
Deus = require(Deus)

Deus:Register(script, "Deus")
Deus:Register(script.Parent.Shared, "Deus")

-- Setup client config

-- Setup client