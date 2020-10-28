local require = shared.Setup()

local JSONEncoder = {}

local HttpService = game:GetService("HttpService")

local BRICKCOLOR = BrickColor.new
local VEC2 = Vector2.new
local VEC3 = Vector3.new
local CFRAME = CFrame.new
local C3 = Color3.new

local function Serialize(Data: any)
	for i,Arg in pairs(Data) do
		local Type = typeof(Arg)
		if Type == "BrickColor" then
			Data[i] = {_TYPE = "BC", Values = {tostring(Arg)}}
		elseif Type == "Vector2" then
			Data[i] = {_TYPE = "V2", Values = {Arg.X, Arg.Y}}
		elseif Type == "Vector3" then
			Data[i] = {_TYPE = "V3", Values = {Arg.X, Arg.Y, Arg.Z}}
		elseif Type == "CFrame" then
			Data[i] = {_TYPE = "CF", Values = {Arg:GetComponents()}}
		elseif Type == "Color3" then
			Data[i] = {_TYPE = "C3", Values = {Arg.r, Arg.g, Arg.b}}
		elseif Type == "table" then
			Data[i] = Serialize(Arg)
		end
	end
	return Data
end

local function Deserialize(Data: any)
	for i,Arg in pairs(Data) do
		if typeof(Arg) == "table" then
			if Arg._TYPE then
				local V = Arg.Values
				if Arg._TYPE == "BC" then
					Data[i] = BRICKCOLOR(V[1])
				elseif Arg._TYPE == "V2" then
					Data[i] = VEC2(V[1], V[2])
				elseif Arg._TYPE == "V3" then
					Data[i] = VEC3(V[1], V[2], V[3])
				elseif Arg._TYPE == "CF" then
					Data[i] = CFRAME(V[1], V[2], V[3], V[4], V[5], V[6], V[7], V[8], V[9], V[10], V[11], V[12])
				elseif Arg._TYPE == "C3" then
					Data[i] = C3(V[1], V[2], V[3])
				end
			else
				Data[i] = Deserialize(Arg)
			end
		end
	end
	return Data
end

function JSONEncoder.JSONEncode(Data: any)
	return HttpService:JSONEncode(Serialize(Data))
end

function JSONEncoder.JSONDecode(Data: string)
	return Deserialize(HttpService:JSONDecode(Data))
end

return JSONEncoder