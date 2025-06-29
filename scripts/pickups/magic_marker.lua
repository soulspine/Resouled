local MAGIC_MARKER = Isaac.GetCardIdByName("MagicMarker")

local PICKUP_UPGRADE = {
    [PickupVariant.PICKUP_SPIKEDCHEST] = {[1] = PickupVariant.PICKUP_HAUNTEDCHEST},
    [PickupVariant.PICKUP_MIMICCHEST] = {[1] = PickupVariant.PICKUP_HAUNTEDCHEST},
    [PickupVariant.PICKUP_HAUNTEDCHEST] = {[1] = PickupVariant.PICKUP_CHEST},
    [PickupVariant.PICKUP_CHEST] = {[1] = PickupVariant.PICKUP_REDCHEST},
    [PickupVariant.PICKUP_REDCHEST] = {[1] = PickupVariant.PICKUP_LOCKEDCHEST, [2] = PickupVariant.PICKUP_BOMBCHEST},
    [PickupVariant.PICKUP_LOCKEDCHEST] = {[1] = PickupVariant.PICKUP_WOODENCHEST, [2] = PickupVariant.PICKUP_OLDCHEST},
    [PickupVariant.PICKUP_BOMBCHEST] = {[1] = PickupVariant.PICKUP_WOODENCHEST, [2] = PickupVariant.PICKUP_OLDCHEST},
    [PickupVariant.PICKUP_WOODENCHEST] = {[1] = PickupVariant.PICKUP_ETERNALCHEST},
    [PickupVariant.PICKUP_OLDCHEST] = {[1] = PickupVariant.PICKUP_ETERNALCHEST},
    [PickupVariant.PICKUP_ETERNALCHEST] = {[1] = PickupVariant.PICKUP_MEGACHEST}
}

---@param player EntityPlayer
local function onCardUse(_, _, player)
    local chestCount = 0
    ---@param entity Entity
    Resouled.Iterators:IterateOverRoomEntities(function(entity)
        local pickup = entity:ToPickup()
        if pickup then
            if PICKUP_UPGRADE[pickup.Variant] then
                pickup:Morph(EntityType.ENTITY_PICKUP, PICKUP_UPGRADE[pickup.Variant][RNG(pickup.InitSeed):RandomInt(#PICKUP_UPGRADE[pickup.Variant]) + 1], 1)
                chestCount = chestCount + 1
            end
        end
    end)
    if chestCount < 1 then
        Game():Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_REDCHEST, Isaac.GetFreeNearPosition(player.Position, 0), Vector.Zero, nil, 0, player.InitSeed)
    end
end
Resouled:AddCallback(ModCallbacks.MC_USE_CARD, onCardUse, MAGIC_MARKER)