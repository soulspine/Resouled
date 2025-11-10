local PICKUP_BLACKLIST = {
    [PickupVariant.PICKUP_BED] = true,
    [PickupVariant.PICKUP_BROKEN_SHOVEL] = true,
    [PickupVariant.PICKUP_COLLECTIBLE] = true,
    [PickupVariant.PICKUP_SHOPITEM] = true,
    [PickupVariant.PICKUP_TROPHY] = true,
}

local function preActiveUse(_, itemId, rng, player, useFlags, activeSlot, varData)
    if      activeSlot ~= -1 -- called by code
    and     Resouled:RoomEventPresent(Resouled.RoomEvents.SHADOW_OF_FAMINE) then
        return true
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_USE_ITEM, preActiveUse)

---@param pickup EntityPickup
local function postPickupInit(_, pickup)
    if Resouled:RoomEventPresent(Resouled.RoomEvents.SHADOW_OF_FAMINE) then
        if not PICKUP_BLACKLIST[pickup.Variant] then
            pickup:Remove()
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, postPickupInit)