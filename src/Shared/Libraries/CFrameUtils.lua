local CFrameUtils = {}

function CFrameUtils.fromOriginDir(origin, dir, up)
    if up then
        return CFrame.lookAt(origin, origin + dir, up)
    else
        return CFrame.lookAt(origin, origin + dir)
    end
end

return CFrameUtils