-- Explanation on how to tune http://robotsforroboticists.com/pid-control/

local PID = {
    ClassName = "PID",
    Events = {}
}

function PID:Constructor(kP, kI, kD, desiredValue, bias)
    self.KP             = kP or self.KP
    self.KI             = kI or self.KI
    self.KD             = kD or self.KD
    self.DesiredValue   = desiredValue or self.DesiredValue
    self.Bias           = bias or self.Bias
    self.LastUpdate     = tick()
end

function PID:Update(actualValue)
    local time = tick()
    local iterationTime = math.min(time - self.LastUpdate, 0.1)
    local error = self.DesiredValue - actualValue
    local integral = self.IntegralPrior + error * iterationTime
    local derivative = (error - self.ErrorPrior) / iterationTime

    self.LastUpdate = time
    self.ErrorPrior = error
    self.IntegralPrior = integral

    return self.KP * error + self.KI * integral + self.KD * derivative + self.Bias
end

function PID:start()
    self.Private = {}

    self.Readable = {
        LastUpdate = 0,
        ErrorPrior = 0,
        IntegralPrior = 0
    }

    self.Writable = {
        KP = 1,
        KI = 1,
        KD = 1,
        DesiredValue = 0,
        Bias = 0
    }

    return self:Load("Deus.BaseObject").new(self)
end

return PID