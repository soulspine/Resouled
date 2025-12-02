---@param npc EntityNPC
local function onNpcUpdate(_, npc)
    if Resouled:ActiveBuffPresent(Resouled.Buffs.FIEND) then
        if npc:IsEnemy() and npc:IsActiveEnemy() and npc:IsVulnerableEnemy() then
            local randomFloat = math.random()
            if randomFloat < Resouled.Stats.FiendBuff.BombChance then
                Game():Spawn(EntityType.ENTITY_BOMB, BombVariant.BOMB_SMALL, npc.Position + Vector(npc.Size + 3, 0):Rotated(math.random(360)), Vector.Zero, nil, BombSubType.BOMB_NORMAL, npc.InitSeed)
            end
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_NPC_UPDATE, onNpcUpdate)

Resouled:AddBuffToRemoveOnRunEnd(Resouled.Buffs.FIEND, true)