local CURSED_HAUNT_TYPE = Isaac.GetEntityTypeByName("Cursed Haunt")
local CURSED_HAUNT_VARIANT = Isaac.GetEntityVariantByName("Cursed Haunt")
local CURSED_HAUNT_SUBTYPE = Isaac.GetEntitySubTypeByName("Cursed Haunt")

local RESOULED_DUMMY_TYPE = Isaac.GetEntityTypeByName("ResouledDummy")
local RESOULED_DUMMY_VARIANT = Isaac.GetEntityVariantByName("ResouledDummy")
local RESOULED_DUMMY_SUBTYPE = Isaac.GetEntitySubTypeByName("ResouledDummy")

local HALO_SUBTYPE = 3
local HALO_OFFSET = Vector(0, 0)
local HALO_SCALE = Vector(3, 3)

local ATTACK_COOLDOWN = 5 * 30

local ATTACK1_TEAR_COUNT = 4 --!!! there are 4 waves with x amount of tears

local ATTACK1_WAVE1_PROJECTILE_PARAMS = ProjectileParams()
local ATTACK1_WAVE2_PROJECTILE_PARAMS = ProjectileParams()
ATTACK1_WAVE1_PROJECTILE_PARAMS.BulletFlags = (ProjectileFlags.GHOST | ProjectileFlags.BLUE_FIRE_SPAWN | ProjectileFlags.CURVE_LEFT)
ATTACK1_WAVE1_PROJECTILE_PARAMS.Color = Color(1, 0, 1, 1)
ATTACK1_WAVE1_PROJECTILE_PARAMS.CurvingStrength = 0.01
ATTACK1_WAVE2_PROJECTILE_PARAMS.BulletFlags = (ProjectileFlags.GHOST | ProjectileFlags.BLUE_FIRE_SPAWN | ProjectileFlags.CURVE_RIGHT)
ATTACK1_WAVE2_PROJECTILE_PARAMS.Color = Color(1, 0, 1, 1)
ATTACK1_WAVE2_PROJECTILE_PARAMS.CurvingStrength = 0.01

---@param npc EntityNPC
local function onNpcInit(_, npc)
    if npc.Variant == CURSED_HAUNT_VARIANT and npc.SubType == CURSED_HAUNT_SUBTYPE then
        local data = npc:GetData()
        data.ResouledAttackCooldown = ATTACK_COOLDOWN
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_INIT, onNpcInit, CURSED_HAUNT_TYPE)

---@param npc EntityNPC
local function onNpcUpdate(_, npc)
    if npc.Variant == CURSED_HAUNT_VARIANT and npc.SubType == CURSED_HAUNT_SUBTYPE then
        local data = npc:GetData()

        if data.ResouledAttackCooldown > 0 then
            data.ResouledAttackCooldown = data.ResouledAttackCooldown - 1
        end

        if data.ResouledAttackCooldown == 0 then
            for i = 1, ATTACK1_TEAR_COUNT do
                npc:FireProjectiles(npc.Position, Vector(10, 0):Rotated((360/ATTACK1_TEAR_COUNT)*i), 0, ATTACK1_WAVE1_PROJECTILE_PARAMS)
                npc:FireProjectiles(npc.Position, Vector(10, 0):Rotated((360/ATTACK1_TEAR_COUNT)*i) * 0.5, 0, ATTACK1_WAVE1_PROJECTILE_PARAMS)
                npc:FireProjectiles(npc.Position, Vector(10, 0):Rotated(((360/ATTACK1_TEAR_COUNT)*i) + (360/ATTACK1_TEAR_COUNT)/2) * 1.25, 0, ATTACK1_WAVE2_PROJECTILE_PARAMS)
                npc:FireProjectiles(npc.Position, Vector(10, 0):Rotated(((360/ATTACK1_TEAR_COUNT)*i) + (360/ATTACK1_TEAR_COUNT)/2) * 0.75, 0, ATTACK1_WAVE2_PROJECTILE_PARAMS)
            end
            data.ResouledAttackCooldown = ATTACK_COOLDOWN
        end

        npc.Pathfinder:MoveRandomlyBoss(true)
        npc.Pathfinder:MoveRandomly(true)



        return true
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_NPC_UPDATE, onNpcUpdate, CURSED_HAUNT_TYPE)

---@param type EntityType
---@param variant integer
---@param subtype integer
---@param position Vector
---@param velocity Vector
---@param spawner Entity
---@param seed integer
local function preEntitySpawn(_, type, variant, subtype, position, velocity, spawner, seed)
    if spawner then
        if spawner.SpawnerEntity then
            if spawner.SpawnerEntity.Type == CURSED_HAUNT_TYPE and spawner.SpawnerEntity.Variant == CURSED_HAUNT_VARIANT and spawner.SpawnerEntity.SubType == CURSED_HAUNT_SUBTYPE then
                if type == 33 and variant == 12 then
                    return {RESOULED_DUMMY_TYPE, RESOULED_DUMMY_VARIANT, RESOULED_DUMMY_SUBTYPE, seed}
                end
            end
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_ENTITY_SPAWN, preEntitySpawn)