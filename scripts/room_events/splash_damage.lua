local AOE_DAMAGE = 0.25
local DAMAGE_RADIUS = 75

---@param tear EntityTear
local function postTearDeath(_, tear)
    if Resouled:RoomEventPresent(Resouled.RoomEvents.SPLASH_DAMAGE) then
        local player = Resouled:TryFindPlayerSpawner(tear)
        if player then
            local playerDamage = player.Damage

            ---@param entity Entity | EntityNPC | nil
            for _, entity in pairs(Isaac.FindInRadius(tear.Position, DAMAGE_RADIUS, EntityPartition.ENEMY)) do
                entity = entity:ToNPC()
                if entity and entity:IsEnemy() and entity:IsActiveEnemy() and entity:IsVulnerableEnemy() and entity.Position:Distance(tear.Position) < DAMAGE_RADIUS then
                    entity:TakeDamage(playerDamage * AOE_DAMAGE, DamageFlag.DAMAGE_CRUSH, EntityRef(tear.SpawnerEntity), 0)
                end
            end
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_TEAR_DEATH, postTearDeath)