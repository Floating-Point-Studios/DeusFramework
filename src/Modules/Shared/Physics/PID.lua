-- Explanation on how to tune http://robotsforroboticists.com/pid-control/

local PID = {}

function PID.new(kP, kI, kD, desiredValue, bias)
    local self = {
        KP = kP or 1,
        KI = kI or 1,
        KD = kD or 1,
        DesiredValue = desiredValue or 0,
        Bias = bias or 0,

        _lastUpdate = tick(),
        _errorPrior = 0,
        _integralPrior = 0,
    }

    return setmetatable(self, {__index = PID})
end

function PID:Update(actualValue)
    local time = tick()
    local iterationTime = time - self._lastUpdate
    local error = self.DesiredValue - actualValue
    local integral = self._integralPrior + error * iterationTime
    local derivative = (error - self._errorPrior) / iterationTime

    self._lastUpdate = time
    self._errorPrior = error
    self._integralPrior = integral

    return self.KP * error + self.KI * integral + self.KD * derivative + self.Bias
end

return PID