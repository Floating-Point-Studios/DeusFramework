local HttpService = game:GetService("HttpService")

local JSON = {}

function JSON.serialize(tab)
    for i,v in pairs(tab) do
        local dataType = typeof(v)

        if dataType == "table" then
            tab[i] = {_TYPE = 0, _DATA = JSON.serialize(v)}
        elseif dataType == "Vector2" then
            tab[i] = {_TYPE = 1, _DATA = {v.X, v.Y}}
        elseif dataType == "Vector3" then
            tab[i] = {_TYPE = 2, _DATA = {v.X, v.Y, v.Z}}
        elseif dataType == "CFrame" then
            tab[i] = {_TYPE = 3, _DATA = pack(v:ToComponents())}
        elseif dataType == "Color3" then
            tab[i] = {_TYPE = 4, _DATA = {v.r, v.g, v.b}}
        elseif dataType == "BrickColor" then
            tab[i] = {_TYPE = 5, _DATA = tostring(v)}
        end
    end
    return HttpService:JSONEncode(tab)
end

function JSON.deserialize(tab)
    tab = HttpService:JSONDecode(tab)
    for i,v in pairs(tab) do
        if type(v) == "table" then
            local dataType = v._TYPE
            v = v._DATA

            if dataType then
                if dataType == 0 then -- table
                    tab[i] = JSON.deserialize(v)
                elseif dataType == 1 then -- Vector2
                    tab[i] = Vector2.new(v[1], v[2])
                elseif dataType == 2 then -- Vector3
                    tab[i] = Vector3.new(v[1], v[2], v[3])
                elseif dataType == 3 then -- CFrame
                    tab[i] = CFrame.new(v[1], v[2], v[3], v[4], v[5], v[6], v[7], v[8], v[9], v[10], v[11], v[12])
                elseif dataType == 4 then -- Color3
                    tab[i] = Color3.new(v[1], v[2], v[3])
                elseif dataType == 5 then -- BrickColor
                    tab[i] = BrickColor.new(v)
                end
            end
        end
    end
    return tab
end

function JSON.isJSON(str)
    local success = pcall(HttpService.JSONDecode, HttpService, str)
    return success
end

return JSON