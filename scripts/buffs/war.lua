---@param bomb EntityBomb
local function postBombInit(_, bomb)
    if bomb.Variant == BombVariant.BOMB_GIGA then
        return
    end
    
    local player = Resouled:TryFindPlayerSpawner(bomb)
    if player then
        local newBomb = Resouled.Game:Spawn(EntityType.ENTITY_BOMB, BombVariant.BOMB_GIGA, bomb.Position, bomb.Velocity, bomb.SpawnerEntity, 0, bomb.InitSeed):ToBomb()
        if newBomb then
            newBomb:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
            newBomb:SetExplosionCountdown(bomb:GetExplosionCountdown())
            bomb:Remove()
            Resouled:RemoveActiveBuff(Resouled.Buffs.WAR)
            Resouled:RemoveCallback(ModCallbacks.MC_POST_BOMB_INIT, postBombInit)
        end
    end
end

Resouled:AddBuffCallbackConfig(Resouled.Buffs.WAR, {
    {
        CallbackID = ModCallbacks.MC_POST_BOMB_INIT,
        Function = postBombInit
    }
})