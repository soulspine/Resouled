local CHANCE = 0.075

local function preEntityTakeDMG()
    if Resouled:ActiveBuffPresent(Resouled.Buffs.CHITIN) and math.random() < CHANCE then
        return false
    end
end
Resouled:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, preEntityTakeDMG, EntityType.ENTITY_PLAYER)

Resouled:AddBuffToRemoveOnRunEnd(Resouled.Buffs.CHITIN, true)