---@param pickup EntityPickup
---@param collider Entity
local function postPickupCollision(_, pickup, collider)
    if Resouled:RoomEventPresent(Resouled.RoomEvents.SHADOW_OF_WAR) then
        local player = collider:ToPlayer()
        if player then
            local bomb = Game():Spawn(EntityType.ENTITY_BOMB, BombVariant.BOMB_NORMAL, pickup.Position, Vector.Zero, nil, BombSubType.BOMB_NORMAL, pickup.InitSeed)
            bomb:ToBomb():SetExplosionCountdown(0)
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PICKUP_COLLISION, postPickupCollision)