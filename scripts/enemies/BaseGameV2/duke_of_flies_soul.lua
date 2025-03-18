local DUKE_OF_FLIES_SOUL_VARIANT = Isaac.GetEntityVariantByName("Duke's Soul")
local DUKE_OF_FLIES_SOUL_ITEM_SUBTYPE = Isaac.GetItemIdByName("Duke's Soul")

local NORMAL = true

local DUKIE_SOUL_TYPE = Isaac.GetEntityTypeByName("Dukie's Soul")
local DUKIE_SOUL_VARIANT = Isaac.GetEntityVariantByName("Dukie's Soul")

local SPRITE_PLAYBACK_SPEED_MULTIPLIER = 1.7

local ENTITY_FLAGS = (EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
local SPRITE_SCALE_TO_ADD = 0.5
local SPRITE_OFFSET = Vector(0, 10)
local HITBOX_SIZE_MULTI = Vector(1, 0.5)
local HITBOX_SIZE_SCALE = 1.5

local EVENT_TRIGGER_EXPLOSION = "Explosion"
local EVENT_TRIGGER_RESOULED_ATTACK1 = "ResouledAttack"
local EVENT_TRIGGER_RESOULED_ATTACK2 = "ResouledAttack2"
local EVENT_TRIGGER_RESOULED_ATTACK_3 = "ResouledAttack3"

local IDLE = "Walk"
local ATTACK01 = "Attack01"
local ATTACK02 = "Attack02"
local ATTACK03 = "Attack03"

local ATTACK1_DUKIES_SPAWN_COUNT = 5
local ATTACK1_DUKIES_SPAWN_OFFSET_RANGE = 75

local ATTACK2_PROJECTILE_COUNT = 12
local ATTACK2_PROJECTILE_SCALE = 1.5
local ATTACK2_PROJECTILE_VARIANT = 6
local ATTACK2_PROJECTILE_COLOR = Color(2, 5, 12.5, 0.5)
local NORMAL_ATTACK2_PROJECTILE_COLOR = Color(1.5, 0.2, 0.2, 0.7)
local ATTACK2_PROJECTILE_SPEED_MULTIPLIER = 12.5

local ATTACK_COOLDOWN = 3 --seconds

local PARTICLE_TYPE = EffectVariant.DARK_BALL_SMOKE_PARTICLE
local PARTICLE_COUNT = 2
local PARTICLE_SPEED = 1
local NORMAL_PARTICLE_SPEED = 2
local PARTICLE_COLOR = Color(8, 10, 12)
local NORMAL_PARTICLE_COLOR = Color(1.5,1,1)
local PARTICLE_HEIGHT = 0
local PARTICLE_SUBTYPE = 0
local PARTICLE_OFFSET = Vector(0, -65)

---@param npc EntityNPC
local function onNpcInit(_, npc)
    if npc.Variant == DUKE_OF_FLIES_SOUL_VARIANT then
        local data = npc:GetData()
        local sprite = npc:GetSprite()
        if NORMAL then
            sprite:ReplaceSpritesheet(0, "gfx/souls/duke_of_flies_soul_boss_normal.png")
            sprite:ReplaceSpritesheet(2, "gfx/souls/duke_of_flies_soul_boss_normal.png")
            sprite:ReplaceSpritesheet(3, "gfx/souls/duke_of_flies_soul_boss_normal.png")
            sprite:LoadGraphics()
        end
        npc:AddEntityFlags(ENTITY_FLAGS)
        npc.Scale = npc.Scale + SPRITE_SCALE_TO_ADD --Sprite Scale
        npc.SpriteOffset = SPRITE_OFFSET --Sprite Offset
        npc.Size = npc.Size * HITBOX_SIZE_SCALE --Hitbox Size
        npc.SizeMulti = HITBOX_SIZE_MULTI
        npc:GetSprite().PlaybackSpeed = SPRITE_PLAYBACK_SPEED_MULTIPLIER

        data.attackTimer = 0
        data.attackCooldown = ATTACK_COOLDOWN * 30
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_INIT, onNpcInit, EntityType.ENTITY_DUKE)

---@param npc EntityNPC
local function onNpcUpdate(_, npc)
    if npc.Variant == DUKE_OF_FLIES_SOUL_VARIANT then
        local data = npc:GetData()
        local sprite = npc:GetSprite()
        --print(sprite:WasEventTriggered(EVENT_TRIGGER_EXPLOSION))
        if NORMAL then
            Game():SpawnParticles(npc.Position + PARTICLE_OFFSET, PARTICLE_TYPE, PARTICLE_COUNT, NORMAL_PARTICLE_SPEED, NORMAL_PARTICLE_COLOR, PARTICLE_HEIGHT, PARTICLE_SUBTYPE)
        else
            Game():SpawnParticles(npc.Position + PARTICLE_OFFSET, PARTICLE_TYPE, PARTICLE_COUNT, PARTICLE_SPEED, PARTICLE_COLOR, PARTICLE_HEIGHT, PARTICLE_SUBTYPE)
        end
        data.attackTimer = data.attackTimer + 1
        if sprite:IsEventTriggered(EVENT_TRIGGER_RESOULED_ATTACK1) then
            for _ = 1, ATTACK1_DUKIES_SPAWN_COUNT do
                local positionOffset = Vector(math.random(-ATTACK1_DUKIES_SPAWN_OFFSET_RANGE, ATTACK1_DUKIES_SPAWN_OFFSET_RANGE), math.random(-ATTACK1_DUKIES_SPAWN_OFFSET_RANGE, ATTACK1_DUKIES_SPAWN_OFFSET_RANGE))
                Game():Spawn(DUKIE_SOUL_TYPE, DUKIE_SOUL_VARIANT, npc.Position + positionOffset, Vector.Zero, npc, 0, npc.InitSeed)
            end
            data.attackTimer = 0
        end
        if sprite:GetAnimation() == IDLE and data.attackTimer >= data.attackCooldown + 30 then
            local projectileParams = ProjectileParams()
            projectileParams.Scale = ATTACK2_PROJECTILE_SCALE
            if NORMAL then
                projectileParams.Color = NORMAL_ATTACK2_PROJECTILE_COLOR
            else
                projectileParams.Color = ATTACK2_PROJECTILE_COLOR
            end
            projectileParams.Variant = ATTACK2_PROJECTILE_VARIANT
            for i = 1, ATTACK2_PROJECTILE_COUNT do
                npc:FireProjectiles(npc.Position, Vector.FromAngle(i * 360 / ATTACK2_PROJECTILE_COUNT):Resized(1)*ATTACK2_PROJECTILE_SPEED_MULTIPLIER, 0, projectileParams)
            end
            data.attackTimer = 0
        end
        if sprite:IsEventTriggered(EVENT_TRIGGER_RESOULED_ATTACK2) then
            local projectileParams = ProjectileParams()
            projectileParams.Scale = ATTACK2_PROJECTILE_SCALE
            if NORMAL then
                projectileParams.Color = NORMAL_ATTACK2_PROJECTILE_COLOR
            else
                projectileParams.Color = ATTACK2_PROJECTILE_COLOR
            end
            projectileParams.Variant = ATTACK2_PROJECTILE_VARIANT
            for i = 1, ATTACK2_PROJECTILE_COUNT do
                npc:FireProjectiles(npc.Position, Vector.FromAngle(i * 360 / ATTACK2_PROJECTILE_COUNT):Resized(1)*ATTACK2_PROJECTILE_SPEED_MULTIPLIER, 0, projectileParams)
            end
            data.attackTimer = 0
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_NPC_UPDATE, onNpcUpdate, EntityType.ENTITY_DUKE)

---@param npc EntityNPC
local function onFlyInit(_, npc)
    if npc.SpawnerEntity then
        local spawner = npc.SpawnerEntity:ToNPC()
        if spawner and spawner.Variant == DUKE_OF_FLIES_SOUL_VARIANT then
            npc:RemoveStatusEffects()
            npc:Remove()
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_INIT, onFlyInit, 18) -- fly idx that duke spawns

---@param effect EntityEffect
local function onFlyDeathEffectInit(_, effect)
    if effect.SpawnerEntity then
        local effectSpawner = effect.SpawnerEntity:ToNPC()
        if effectSpawner and effectSpawner.Type == EntityType.ENTITY_DUKE and effectSpawner.Variant == DUKE_OF_FLIES_SOUL_VARIANT then
            effect:Remove()
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, onFlyDeathEffectInit, 1) -- effect idx that duke spawns

---@param npc EntityNPC
local function onNpcDeath(_, npc)
    if npc.Variant ~= DUKE_OF_FLIES_SOUL_VARIANT then
        Resouled:TrySpawnSoulPickup(Resouled.Souls.DUKE, npc.Position)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, onNpcDeath, EntityType.ENTITY_DUKE)