local PICKUP_BLACKLIST = {
    [PickupVariant.PICKUP_BED] = true,
    [PickupVariant.PICKUP_BROKEN_SHOVEL] = true,
    [PickupVariant.PICKUP_COLLECTIBLE] = true,
    [PickupVariant.PICKUP_SHOPITEM] = true,
    [PickupVariant.PICKUP_TROPHY] = true,
}

local TNT_VARIANT = Isaac.GetEntityVariantByName("Blast Miner TNT")
local TNT_SUBTYPE = Isaac.GetEntitySubTypeByName("Blast Miner TNT")
local TNT_MEGA_SUBTYPE = Isaac.GetEntitySubTypeByName("Blast Miner TNT Mega")
local TNT_GIGA_SUBTYPE = Isaac.GetEntitySubTypeByName("Blast Miner TNT Giga")

local PICKUP_DESC_BLACKLIST = {
    {Type = EntityType.ENTITY_PICKUP, Variant = TNT_VARIANT, SubType = TNT_SUBTYPE},
    {Type = EntityType.ENTITY_PICKUP, Variant = TNT_VARIANT, SubType = TNT_MEGA_SUBTYPE},
    {Type = EntityType.ENTITY_PICKUP, Variant = TNT_VARIANT, SubType = TNT_GIGA_SUBTYPE}
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
        for _, desc in ipairs(PICKUP_DESC_BLACKLIST) do
            if Resouled:MatchesEntityDesc(pickup, desc) then
                return
            end
        end
        if not PICKUP_BLACKLIST[pickup.Variant] then
            pickup:Remove()
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, postPickupInit)