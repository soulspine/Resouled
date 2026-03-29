local QUALITY = 4

---@param pickup EntityPickup
---@param collider Entity
local function prePickupCollision(_, pickup, collider)
    local player = collider:ToPlayer()
    if player then
        local ROOM_SAVE = Resouled.SaveManager.GetRoomSave(pickup)
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

---@param pickup EntityPickup
local function postPickupInit(_, pickup)
    if Resouled.Game:GetRoom():GetType() == RoomType.ROOM_BOSS then
        local ROOM_SAVE = Resouled.SaveManager.GetRoomSave(pickup)

        local collectibleID = Resouled:GetRandomItemFromPool(ItemPoolType.POOL_ANGEL, RNG(pickup.InitSeed), QUALITY)

        pickup:AddCollectibleCycle(collectibleID)
        ROOM_SAVE.Resouled_CrucifixItemID = collectibleID

        Resouled:RemoveActiveBuff(Resouled.Buffs.CRUCIFIX)
        Resouled:RemoveCallback(ModCallbacks.MC_POST_PICKUP_INIT, postPickupInit)
        Resouled:RemoveCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, prePickupCollision)
    end
end

Resouled:AddBuffCallbackConfig(Resouled.Buffs.CRUCIFIX, {
    {
        CallbackID = ModCallbacks.MC_POST_PICKUP_INIT,
        Function = postPickupInit,
        CallbackParams = PickupVariant.PICKUP_COLLECTIBLE
    },
    {
        CallbackID = ModCallbacks.MC_PRE_PICKUP_COLLISION,
        Function = prePickupCollision,
        CallbackParams = PickupVariant.PICKUP_COLLECTIBLE
    }
})