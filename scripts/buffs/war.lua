---@param bomb EntityBomb
local function postBombInit(_, bomb)
    if bomb.Variant == BombVariant.BOMB_GIGA then
        return
    end
    
    local player = Resouled:TryFindPlayerSpawner(bomb)
    if Resouled:ActiveBuffPresent(Resouled.Buffs.WAR) and player then
        local newBomb = Game():Spawn(EntityType.ENTITY_BOMB, BombVariant.BOMB_GIGA, bomb.Position, bomb.Velocity, bomb.SpawnerEntity, 0, bomb.InitSeed):ToBomb()
        if newBomb then
            newBomb:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
            newBomb:SetExplosionCountdown(bomb:GetExplosionCountdown())
            bomb:Remove()
            Resouled:RemoveActiveBuff(Resouled.Buffs.WAR)
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_BOMB_INIT, postBombInit)

Resouled:AddBuffDescription(Resouled.Buffs.WAR, Resouled.EID:AutoIcons("First bomb used in a run has a mama mega explosion"))