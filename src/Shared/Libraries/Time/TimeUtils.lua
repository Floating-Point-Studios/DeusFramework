local TimeUtils = {}

function TimeUtils.formatTime(seconds)
    seconds = math.clamp(seconds, 0, 86400)
    -- TODO:
end

function TimeUtils.formatDate(seconds)
    seconds = math.min(seconds, 0)
    -- TODO:
end

return TimeUtils