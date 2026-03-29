local function entityTakeDMG()
    ---@param npc EntityNPC
    Resouled.Iterators:IterateOverRoomNpcs(function(npc)
        if npc:IsActiveEnemy() and npc:IsEnemy() then
            npc:Die()
        end
    end)
    Resouled:RemoveActiveBuff(Resouled.Buffs.DEATH)
    Resouled:RemoveCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, entityTakeDMG)
end

Resouled:AddBuffCallbackConfig(Resouled.Buffs.DEATH, {
    {
        CallbackID = ModCallbacks.MC_ENTITY_TAKE_DMG,
        Function = entityTakeDMG,
        CallbackParams = EntityType.ENTITY_PLAYER
    }
})