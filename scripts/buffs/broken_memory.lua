local CHEST_MORPH_CHANCE = 0.5

---@param pickup EntityPickup
local function postPickupInit(_, pickup)
    local randomNum = RNG(pickup.InitSeed):RandomFloat()
    if randomNum < CHEST_MORPH_CHANCE then
        pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_OLDCHEST, 0, true, true, false)
    end
end

Resouled:AddBuffCallbackConfig(Resouled.Buffs.BROKEN_MEMORY, {
    {
        CallbackID = postPickupInit,
        CallbackParams = PickupVariant.PICKUP_LOCKEDCHEST,
        Function = postPickupInit
    }
})

Resouled:AddBuffToRemoveOnRunEnd(Resouled.Buffs.BROKEN_MEMORY, true)