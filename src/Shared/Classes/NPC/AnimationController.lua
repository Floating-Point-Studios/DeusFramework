local AnimationController = {}

function AnimationController.new(animator)
    local self = {
        _animator = animator,
        _animationTracks = {},
    }

    return setmetatable(self, {__index = AnimationController})
end

-- @param animationName: name to assign to the animation, used when wanting to play the animation
-- @param animation: animation instance
-- @param looped: if animation should be looped
-- @param priority: priority of animation
-- @param speed: speed of animation
function AnimationController:LoadAnimation(animationName, animation)
    local track = self._animator:LoadAnimation(animation)
    self._animationTracks[animationName] = track
    return track
end

function AnimationController:PlayAnimation(animationName, fadeTime, weight, speed)
    local track = self._animationTracks[animationName]
    track:Play(fadeTime, weight, speed)
    return track
end

function AnimationController:StopAnimation(animationName, fadeTime)
    local track = self._animationTracks[animationName]
    track:Stop(fadeTime)
    return track
end

function AnimationController:GetAnimationTrack(animationName)
    return self._animationTracks[animationName]
end

return AnimationController