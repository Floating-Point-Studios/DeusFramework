local HttpService = game:GetService("HttpService")

local JSON = {}

function JSON.encode(data)
    for i,v in pairs(data) do
        if typeof(i) == "table" then
            data[i] = {__TYPE = 0, __DATA = JSON.encode(v)}
        elseif typeof(i) == "Vector2" then
            data[i] = {__TYPE = 1, __DATA = {v.X, v.Y}}
        elseif typeof(i) == "Vector3" then
            data[i] = {__TYPE = 2, __DATA = {v.X, v.Y, v.Z}}
        elseif typeof(i) == "CFrame" then
            data[i] = {__TYPE = 3, __DATA = pack(v:ToComponents())}
        elseif typeof(i) == "Color3" then
            data[i] = {__TYPE = 4, __DATA = {v.r, v.g, v.b}}
        elseif typeof(i) == "BrickColor" then
            data[i] = {__TYPE = 5, __DATA = tostring(v)}
        else
            -- Unsupported data type
            data[i] = nil
        end
    end
    return HttpService:JSONEncode(data)
end

function JSON.decode(data)
    for i,v in pairs(data) do
        local dataType = data.__TYPE
        if dataType then
            if datatype == 0 then -- table
                data[i] = JSON.decode(v)
            elseif dataType == 1 then -- Vector2
                data[i] = Vector2.new(v[1], v[2])
            elseif dataType == 2 then -- Vector3
                data[i] = Vector3.new(v[1], v[2], v[3])
            elseif dataType == 3 then -- CFrame
                data[i] = CFrame.new(v[1], v[2], v[3], v[4], v[5], v[6], v[7], v[8], v[9], v[10], v[11], v[12])
            elseif dataType == 4 then -- Color3
                data[i] = Color3.new(v[1], v[2], v[3])
            elseif dataType == 5 then -- BrickColor
               data[i] = BrickColor.new(v) 
            end
        end
    end
    return HttpService:JSONDecode(data)
end

function JSON.isJSON(str)
    return pcall(HttpService.JSONDecode, HttpService, str)
end

return JSON