local BUTTER_FINGERS_ACTIVATION_DISTANCE = 150

local VELOCITY_MULTIPLIER = 0.95

---@param pickup EntityPickup
local function postPickupUpdate(_, pickup)
    if Resouled:RoomEventPresent(Resouled.RoomEvents.BUTTER_FINGERS) then
        local playerPos = Game():GetNearestPlayer(pickup.Position).Position
        if playerPos:Distance(pickup.Position) < BUTTER_FINGERS_ACTIVATION_DISTANCE then
            pickup.Velocity = (pickup.Velocity + (pickup.Position - playerPos):Normalized()) * VELOCITY_MULTIPLIER
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, postPickupUpdate)