local require = shared.DeusHook()

local BindableFunction = {}

function BindableFunction.new()
    local self = setmetatable({}, BindableFunction)

    self._connection = nil

    function self:Bind(callback)
        self._connection = callback
    end

    function self:Invoke(...)
        return self._connection(...)
    end
end

return BindableFunction