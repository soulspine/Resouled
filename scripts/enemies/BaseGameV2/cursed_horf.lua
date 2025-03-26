local CURSED_HORF_VARIANT = Isaac.GetEntityVariantByName("Cursed Horf")
local CURSED_HORF_TYPE = Isaac.GetEntityTypeByName("Cursed Horf")
local HALO_SUBTYPE = 3

local REFLECT_CHANCE = 0.5

local HALO_OFFSET = Vector(0, -15)
local HALO_SCALE = Vector(0.5, 0.5)

local DEATH_TEARS_SPAWN_COUNT = 3
local DEATH_TEAR_BULLET_FLAGS = (ProjectileFlags.SMART | ProjectileFlags.CURVE_RIGHT)
local DEATH_TEAR_WAVE_2_BULLET_FLAGS = (ProjectileFlags.SMART | ProjectileFlags.CURVE_LEFT)
local DEATH_TEAR_CURVING_STRENGTH = 0.02
local DEATH_TEAR_HOMING_STRENGTH = 0.05
local DEATH_TEAR_VELOCITY_MULTI = 5

local ON_HIT_TEAR_HOMING_STRENGTH = 1
local ON_HIT_TEAR_PROJECTILE_FLAGS = (ProjectileFlags.SMART)

local CURSED_ENEMY_MORPH_CHANCE = 0.1

---@param npc EntityNPC
local function onNPCDeath(_, npc)
    if npc.Variant == CURSED_HORF_VARIANT then
        local DEATH_PROJECTILE_PARAMS = ProjectileParams()
        DEATH_PROJECTILE_PARAMS.BulletFlags = DEATH_TEAR_BULLET_FLAGS
        DEATH_PROJECTILE_PARAMS.HomingStrength = DEATH_TEAR_HOMING_STRENGTH
        DEATH_PROJECTILE_PARAMS.CurvingStrength = DEATH_TEAR_CURVING_STRENGTH
        DEATH_PROJECTILE_PARAMS.VelocityMulti = DEATH_TEAR_VELOCITY_MULTI
        for i = 1, DEATH_TEARS_SPAWN_COUNT do
            npc:FireProjectiles(npc.Position, Vector.FromAngle(i * 360 / DEATH_TEARS_SPAWN_COUNT):Resized(1), 0, DEATH_PROJECTILE_PARAMS)
        end
        DEATH_PROJECTILE_PARAMS.BulletFlags = DEATH_TEAR_WAVE_2_BULLET_FLAGS
        for i = 1, DEATH_TEARS_SPAWN_COUNT do
            npc:FireProjectiles(npc.Position, Vector.FromAngle(i * 360 / DEATH_TEARS_SPAWN_COUNT):Resized(1), 0, DEATH_PROJECTILE_PARAMS)
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, onNPCDeath, CURSED_HORF_TYPE)

---@param npc EntityNPC
local function onNpcInit(_, npc)
    --Try to turn enemy into a cursed enemy
    if Game():GetLevel():GetCurses() > 0 then
        Resouled:TryEnemyMorph(npc, CURSED_ENEMY_MORPH_CHANCE, CURSED_HORF_TYPE, CURSED_HORF_VARIANT, 0)
    end

    --Add halo
    if npc.Variant == CURSED_HORF_VARIANT then
        Resouled:AddHaloToNpc(npc, HALO_SUBTYPE, HALO_SCALE, HALO_OFFSET)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_INIT, onNpcInit, CURSED_HORF_TYPE)

---@param entity Entity
---@param flags DamageFlag
---@param source EntityRef
---@param type EntityType
local function onEnemyHit(_, entity, amount, flags, source, frames, type)
    if entity.Variant == CURSED_HORF_VARIANT and not entity:IsDead() and entity:GetDropRNG():RandomFloat() < REFLECT_CHANCE and source.Entity then
        local PROJECTILE_PARAMS = ProjectileParams()
        PROJECTILE_PARAMS.BulletFlags = ON_HIT_TEAR_PROJECTILE_FLAGS
        PROJECTILE_PARAMS.HomingStrength = ON_HIT_TEAR_HOMING_STRENGTH
        entity:ToNPC():FireProjectiles(entity.Position, -source.Entity.Velocity, 0, PROJECTILE_PARAMS)
    end
end
Resouled:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, onEnemyHit, CURSED_HORF_TYPE)