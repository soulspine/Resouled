---@param npc EntityNPC
local function onNpcDeath(_, npc)
    if Resouled:ActiveBuffPresent(Resouled.Buffs.DEMON) then
        if npc:IsEnemy() and npc:IsActiveEnemy() then
            local randomFloat = math.random()
            if randomFloat < Resouled.Stats.DemonBuff.OnDeathChance then
                Game():BombExplosionEffects(npc.Position, Resouled.Stats.DemonBuff.BigDamage)
            end
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, onNpcDeath)

---@param entity Entity
local function entityTakeDMG(_, entity)
    if Resouled:ActiveBuffPresent(Resouled.Buffs.DEMON) then
        local npc = entity:ToNPC()
        if npc and npc:IsActiveEnemy() and npc:IsEnemy() and npc:IsBoss() then
            local randomFloat = math.random()
            if randomFloat < Resouled.Stats.DemonBuff.OnHitForBossChance then
                Game():BombExplosionEffects(npc.Position, Resouled.Stats.DemonBuff.SmallDamage)
            end
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, entityTakeDMG)

Resouled:AddBuffToRemoveOnRunEnd(Resouled.Buffs.DEMON, true)