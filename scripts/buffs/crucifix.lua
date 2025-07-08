local QUALITY = 4

---@param pickup EntityPickup
local function postPickupInit(_, pickup)
    if Game():GetRoom():GetType() == RoomType.ROOM_BOSS and Resouled:ActiveBuffPresent(Resouled.Buffs.CRUCIFIX) then
        local ROOM_SAVE = SAVE_MANAGER.GetRoomSave(pickup)

        local collectibleID = Resouled:GetRandomItemFromPool(ItemPoolType.POOL_ANGEL, RNG(pickup.InitSeed), QUALITY)

        pickup:AddCollectibleCycle(collectibleID)
        ROOM_SAVE.Resouled_CrucifixItemID = collectibleID

        Resouled:RemoveActiveBuff(Resouled.Buffs.CRUCIFIX)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, postPickupInit, PickupVariant.PICKUP_COLLECTIBLE)

---@param pickup EntityPickup
---@param collider Entity
local function prePickupCollision(_, pickup, collider)
    local player = collider:ToPlayer()
    if player then
        local ROOM_SAVE = SAVE_MANAGER.GetRoomSave(pickup)
        if ROOM_SAVE and ROOM_SAVE.Resouled_CrucifixItemID then
            if pickup.SubType == ROOM_SAVE.Resouled_CrucifixItemID then
                if player:GetMaxHearts() > 2 then
                    player:AddMaxHearts(-2, true)
                else
                    ROOM_SAVE.Resouled_CrucifixItemID = nil
                end
            end
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, prePickupCollision, PickupVariant.PICKUP_COLLECTIBLE)