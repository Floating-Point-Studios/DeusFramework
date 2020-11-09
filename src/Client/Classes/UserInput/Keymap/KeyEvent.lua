local Signal = shared.Deus.import("Deus.Signal")

local KeyEvent = {}

function KeyEvent.new(button, ctrl, shift, alt)
    local self = {
        Active = false,
        _lastActive = 0,
        _button = button,
        _ctrl = ctrl,
        _shift = shift,
        _alt = alt,

        Began = Signal.new(),
        Ended = Signal.new(),
        Changed = Signal.new()
    }

    return setmetatable(self, {__index = KeyEvent})
end

function KeyEvent:Set(button, ctrl, shift, alt)
    self.Active = false
    self._button = button
    self._ctrl = ctrl
    self._shift = shift
    self._alt = alt
end

function KeyEvent:Update(active, inputObject, gameProcessedEvent)
    if self ~= active then
        if active then
            self.Active = true
            self._lastActive = tick()
            self.Began:Fire(inputObject, gameProcessedEvent)
        else
            self.Active = false
            self.Ended:Fire(tick() - self._lastActive, inputObject, gameProcessedEvent)
        end
    end
end

return KeyEvent