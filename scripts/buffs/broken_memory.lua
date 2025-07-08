local CHEST_MORPH_CHANCE = 0.5

---@param pickup EntityPickup
local function postPickupInit(_, pickup)
    if Resouled:ActiveBuffPresent(Resouled.Buffs.BROKEN_MEMORY) then
        local randomNum = RNG(pickup.InitSeed):RandomFloat()
        if randomNum < CHEST_MORPH_CHANCE then
            pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_OLDCHEST, 0, true, true, false)
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, postPickupInit, PickupVariant.PICKUP_LOCKEDCHEST)

local function postGameEnded()
    if Resouled:ActiveBuffPresent(Resouled.Buffs.BROKEN_MEMORY) then
        Resouled:RemoveActiveBuff(Resouled.Buffs.BROKEN_MEMORY)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_GAME_END, postGameEnded)