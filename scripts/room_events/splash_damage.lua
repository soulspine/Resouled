local AOE_DAMAGE = 0.25
local DAMAGE_RADIUS = 75

---@param tear EntityTear
local function postTearDeath(_, tear)
    if Resouled:RoomEventPresent(Resouled.RoomEvents.SPLASH_DAMAGE) then
        local playerDamage = tear.SpawnerEntity:ToPlayer().Damage
        ---@param entity Entity
        Resouled.Iterators:IterateOverRoomEntities(function(entity)
            if entity:IsEnemy() and entity:IsActiveEnemy() and entity:IsVulnerableEnemy() and entity.Position:Distance(tear.Position) < DAMAGE_RADIUS then
                entity:TakeDamage(playerDamage * AOE_DAMAGE, DamageFlag.DAMAGE_CRUSH, EntityRef(tear.SpawnerEntity), 0)
            end
        end)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_TEAR_DEATH, postTearDeath)