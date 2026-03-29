---@param npc EntityNPC
local function onNpcUpdate(_, npc)
    if npc:IsEnemy() and npc:IsActiveEnemy() and npc:IsVulnerableEnemy() then
        local randomFloat = math.random()
        if randomFloat < Resouled.Stats.FiendBuff.BombChance then
            Resouled.Game:Spawn(EntityType.ENTITY_BOMB, BombVariant.BOMB_SMALL, npc.Position + Vector(npc.Size + 3, 0):Rotated(math.random(360)), Vector.Zero, nil, BombSubType.BOMB_NORMAL, npc.InitSeed)
        end
    end
end

Resouled:AddBuffToRemoveOnRunEnd(Resouled.Buffs.FIEND, true)

Resouled:AddBuffCallbackConfig(Resouled.Buffs.FIEND, {
    {
        CallbackID = ModCallbacks.MC_NPC_UPDATE,
        Function = onNpcUpdate
    }
})