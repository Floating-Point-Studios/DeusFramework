-- BaseVehicle class for cars, boats, and planes. Uses the PrimaryPart of the vehicle as the root for seats.
-- If you want to create your own vehicle based off Deus vehicles extend them as a superclass.

local BaseVehicle = shared.Deus.import("Deus.BaseClass").new("Deus/BaseVehicle")

function BaseVehicle:CreateSeat(offset)
    
end

function BaseVehicle:SeatPlayer(seat, player)
    
end

return BaseVehicle