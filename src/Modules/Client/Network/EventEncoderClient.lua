-- Encodes events to make remote spy being able to read and send events more difficult

local require = shared.DeusHook()

local JSONEncoder = require("JSONEncoder")

local BYTE					= string.byte
local CHAR					= string.char
local FLOOR					= math.floor
local NOISE					= math.noise

local EventDecoderServer = {}

local function DecimalToInt(Int: number): number
	return tonumber("0.".. Int)
end

function EventDecoderServer.Decrypt(Key: string, Seed: number, Package: string)
	local Decrypted = ""
	local NewKey = 0
	for i = 1, #Key do
		local Result = BYTE(Key, i, i)
		if Result % 2 == 0 then
			NewKey += Result
		else
			NewKey -= Result
		end
	end
	for i = 1, #Package do
		Decrypted ..= CHAR((BYTE(Package, i, i) - 32 - Seed - (FLOOR(NOISE(DecimalToInt(Seed), DecimalToInt(i), DecimalToInt(NewKey)) * 10000))) % 95 + 32)
	end
	return JSONEncoder.JSONDecode(Decrypted)
end

return EventDecoderServer