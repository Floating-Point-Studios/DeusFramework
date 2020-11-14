local RBXTweenService = game:GetService("TweenService")

local TweenService = {}

setmetatable(TweenService, {
    __index = function(i,v)
        return rawget(i, v) or RBXTweenService[v]
    end
})

function TweenService.tweenString()
    
end

TweenService.Create = RBXTweenService.Create

return TweenService