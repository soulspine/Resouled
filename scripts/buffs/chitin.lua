local CHANCE = 0.075

local function preEntityTakeDMG()
    if math.random() < CHANCE then
        return false
    end
end

Resouled:AddBuffCallbackConfig(Resouled.Buffs.CHITIN, {
    {
        CallbackID = ModCallbacks.MC_ENTITY_TAKE_DMG,
        CallbackParams = EntityType.ENTITY_PLAYER,
        Function = preEntityTakeDMG
    }
})

Resouled:AddBuffToRemoveOnRunEnd(Resouled.Buffs.CHITIN, true)