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

local function onRunEnd()
    if Resouled:ActiveBuffPresent(Resouled.Buffs.FIEND) then
        Resouled:RemoveActiveBuff(Resouled.Buffs.FIEND)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_GAME_END, onRunEnd)

Resouled:AddBuffDescription(Resouled.Buffs.AGILITY, "Has a chance for a small bomb to spawn near a random enemy, lasts the whole run")