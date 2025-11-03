local CURSED_FATTY_VARIANT = Isaac.GetEntityVariantByName("Cursed Fatty")
local CURSED_FATTY_TYPE = Isaac.GetEntityTypeByName("Cursed Fatty")
local CURSED_FATTY_SUBTYPE = Isaac.GetEntitySubTypeByName("Cursed Fatty")

local CURSED_ENEMY_MORPH_CHANCE = Resouled.Stats.CursedEnemyMorphChance

local CursedFatty = {
    SizePerEnemy = 2.5,
    SizePerPickup = 1.5,
    HealthPerPickup = 10,
    
    MaxProjectileDistance = 10,
    MinProjectileDistance = 3,
    MaxProjectileTrajectory = 5,
    MinProjectileTrajectory = 1,
    MaxProjectileFallSpeed = 8,
    MinProjectileFallSpeed = 1,
    ProjectileFallSpeedMultiplier = 0.5,

    DeathTearsMultiplier = 3,
}

local params = Resouled.Stats:GetCursedProjectileParams()

local PICKUP_BLACKLIST = {
    [PickupVariant.PICKUP_BED] = true,
    [PickupVariant.PICKUP_BIGCHEST] = true,
    [PickupVariant.PICKUP_BROKEN_SHOVEL] = true,
    [PickupVariant.PICKUP_COLLECTIBLE] = true,
    [PickupVariant.PICKUP_MEGACHEST] = true,
    [PickupVariant.PICKUP_TRINKET] = true,
    [PickupVariant.PICKUP_TROPHY] = true,
    [PickupVariant.PICKUP_SHOPITEM] = true,
    [PickupVariant.PICKUP_MOMSCHEST] = true,
}
    
---@param npc EntityNPC
local function onNpcInit(_, npc)
    --Try to turn enemy into a cursed enemy
    if Game():GetLevel():GetCurses() > 0 then
        Resouled:TryEnemyMorph(npc, CURSED_ENEMY_MORPH_CHANCE, CURSED_FATTY_TYPE, CURSED_FATTY_VARIANT, CURSED_FATTY_SUBTYPE)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_INIT, onNpcInit, CURSED_FATTY_TYPE)

---@param npc EntityNPC
local function onNpcUpdate(_, npc)
    if npc.Variant == CURSED_FATTY_VARIANT and npc.SubType == CURSED_FATTY_SUBTYPE then
        local data = npc:GetData()

        if not data.Resouled_CursedFatty then
            data.Resouled_CursedFatty = {
                OriginalSize = npc.Size,
                EnemiesConsumed = 0,
                PickupsConsumed = 0
            }
        end

        local npcsNear = Isaac.FindInRadius(npc.Position, npc.Size + 1, EntityPartition.ENEMY)

        for _, npc2 in ipairs(npcsNear) do
            if npc2:IsEnemy() and npc2:IsActiveEnemy() and npc:IsVulnerableEnemy() and npc2.Index ~= npc.Index then
                if npc2.Type == CURSED_FATTY_TYPE and npc2.Variant == CURSED_FATTY_VARIANT and npc.SubType == CURSED_FATTY_SUBTYPE then
                    data.Resouled_CursedFatty.EnemiesConsumed = data.Resouled_CursedFatty.EnemiesConsumed + 1 + npc2:GetData().Resouled_CursedFatty.EnemiesConsumed
                    data.Resouled_CursedFatty.PickupsConsumed = data.Resouled_CursedFatty.PickupsConsumed + 1 + npc2:GetData().Resouled_CursedFatty.PickupsConsumed
                    npc.MaxHitPoints = npc.MaxHitPoints + npc2.HitPoints
                    npc.HitPoints = npc.HitPoints + npc2.HitPoints
                    npc2:Kill()
                else
                    data.Resouled_CursedFatty.EnemiesConsumed = data.Resouled_CursedFatty.EnemiesConsumed + 1
                    npc.MaxHitPoints = npc.MaxHitPoints + npc2.HitPoints
                    npc.HitPoints = npc.HitPoints + npc2.HitPoints
                    npc2:Kill()
                end
            end
        end

        local pickupsNear = Isaac.FindInRadius(npc.Position, npc.Size + 1, EntityPartition.PICKUP)

        for _, pickup in ipairs(pickupsNear) do
            if not PICKUP_BLACKLIST[pickup.Variant] then
                data.Resouled_CursedFatty.PickupsConsumed = data.Resouled_CursedFatty.PickupsConsumed + 1
                npc.MaxHitPoints = npc.MaxHitPoints + CursedFatty.HealthPerPickup
                npc.HitPoints = npc.HitPoints + CursedFatty.HealthPerPickup
                pickup:Remove()
            end
        end
    
        local size = data.Resouled_CursedFatty.OriginalSize + (data.Resouled_CursedFatty.EnemiesConsumed * CursedFatty.SizePerEnemy) + (data.Resouled_CursedFatty.PickupsConsumed * CursedFatty.SizePerPickup)

        npc.Size = size
        npc.Scale = size / data.Resouled_CursedFatty.OriginalSize

        npc.Velocity = npc.Velocity * (1 + (1 - npc.Scale)/3)
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_NPC_UPDATE, onNpcUpdate, CURSED_FATTY_TYPE)

---@param entity Entity
---@param damage number
local function npcTakeDamage(_, entity, damage)
    if entity.HitPoints - damage <= 0 then
        local npc = entity:ToNPC()
        if npc and npc.Type == CURSED_FATTY_TYPE and npc.Variant == CURSED_FATTY_VARIANT and npc.SubType == CURSED_FATTY_SUBTYPE then
            local data = npc:GetData()
            
            if data.Resouled_CursedFatty then
                local tears = (data.Resouled_CursedFatty.EnemiesConsumed + data.Resouled_CursedFatty.PickupsConsumed) * CursedFatty.DeathTearsMultiplier
                
                for _ = 1, tears do
                    local projectile = npc:FireBossProjectiles(1, npc.Position + Vector(math.random(CursedFatty.MinProjectileDistance, CursedFatty.MaxProjectileDistance), 0):Rotated(math.random(360)), math.random(CursedFatty.MinProjectileTrajectory, CursedFatty.MaxProjectileTrajectory), params):ToProjectile()
                    projectile.FallingSpeed = projectile.FallingSpeed + (math.random(CursedFatty.MinProjectileFallSpeed, CursedFatty.MaxProjectileFallSpeed) * CursedFatty.ProjectileFallSpeedMultiplier)
                end
            end
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, npcTakeDamage)