-- Class for wrapping Roblox services

local Deus = shared.DeusFramework

local Debug = Deus:Load("Deus/Debug")

function __index(self, i)
    local v = rawget(self, i)
    if v then
        return v
    end

    pcall(function()
        local service = self.__service
        v = service[i]

        if type(v) == "function" then
            local func = function(...)
                v(service, ...)
            end

            --Store function in original service object to skip this step if function is called again
            self[i] = func

            return func
        elseif v ~= nil then
            return v
        end
    end)
end

local ServiceWrapper = {}

function ServiceWrapper.new(serviceName)
    local self = {
        __service = game:GetService(serviceName)
    }

    return setmetatable(self, {__index = __index})
end

return ServiceWrapper