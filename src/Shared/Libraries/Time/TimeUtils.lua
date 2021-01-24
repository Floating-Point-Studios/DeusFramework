local TimeUtils = {}

function TimeUtils.formatTime(seconds)
    seconds = math.clamp(seconds, 0, 86400)
end

function TimeUtils.formatDate(seconds)
    seconds = math.min(seconds, 0)
end

return TimeUtils