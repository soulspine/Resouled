local MONSTROS_SOUL_VARIANT = Isaac.GetEntityVariantByName("Monstro's Soul")
local MONSTORS_SOUL_ITEM_SUBTYPE = Isaac.GetItemIdByName("Monstro's Soul")

local NORMAL = true
local SOUL = "Monstro's Soul"

local ENTITY_FLAGS = (EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
local TEAR_COUNT = 25
local TEAR_BULLET_FLAGS = (ProjectileFlags.SMART)
local TEAR_SCALE = 1.5
local TEAR_TRAJECTORY_MODIFIER = 1
local TEAR_VARIANT = 6
local TEAR_COLOR = Color(2, 5, 12.5, 0.5)

local LASER_VARIANT = LaserVariant.SHOOP
local LASER_COUNT = 4
local LASER_TIMEOUT = 6
local LASER_ROTATION_ANGLE = 360
local LASER_ROTATION_SPEED = 2
local LASER_MAX_DISTANCE = 100
local LASER_TEAR_FLAGS = (TearFlags.TEAR_HOMING)
local LASER_COLLISION_CLASS = EntityCollisionClass.ENTCOLL_ALL
local LASER_COLOR = Color(1.3, 1.7, 9, 0.5)

local CREEP_SCALE = 2
local CREEP_TIMEOUT = 100

local SPRITE_PLAYBACK_SPEED_MULTIPLIER = 1.6

local LAND_MOVEMENT_BLOCK_COOLDOWN = 30

local EVENT_TRIGGER_RESOULED_SHOOT = "ResouledShoot"
local EVENT_TRIGGER_RESOULED_LAND = "ResouledLand"
local EVENT_TRIGGER_LAND = "Land"

local SFX_SHOOT = SoundEffect.SOUND_MONSTER_GRUNT_0
local SFX_LAND = SoundEffect.SOUND_HELLBOSS_GROUNDPOUND

local VOLUME_SHOOT = 1
local VOLUME_LAND = 1

local PARTICLE_TYPE = EffectVariant.DARK_BALL_SMOKE_PARTICLE
local PARTICLE_COUNT = 5
local PARTICLE_SPEED = 7
local PARTICLE_COLOR = Color(8, 10, 12)
local NORMAL_PARTICLE_COLOR = Color(1.5,1,1)
local PARTICLE_HEIGHT = 0
local PARTICLE_SUBTYPE = 0
local PARTICLE_OFFSET = Vector(0, 0)

---@param npc EntityNPC
local function onNpcInit(_, npc)
    if npc.Variant == MONSTROS_SOUL_VARIANT then
        local sprite = npc:GetSprite()
        if NORMAL then
            sprite:ReplaceSpritesheet(0, "gfx/souls/monstros_soul_boss_normal.png")
            sprite:LoadGraphics()
        end
        npc:AddEntityFlags(ENTITY_FLAGS)
        local data = npc:GetData()
        ---@type ProjectileParams
        data.TearParams = ProjectileParams()
        data.TearParams.BulletFlags = TEAR_BULLET_FLAGS
        data.TearParams.Scale = TEAR_SCALE
        data.TearParams.Variant = TEAR_VARIANT
        data.TearParams.Color = TEAR_COLOR

        data.MovementBlockCooldown = 0
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_INIT, onNpcInit, EntityType.ENTITY_MONSTRO)

---@param npc EntityNPC
local function onNpcUpdate(_, npc)
    if npc.Variant == MONSTROS_SOUL_VARIANT then
        local data = npc:GetData()
        local sprite = npc:GetSprite()

        
        sprite.PlaybackSpeed = SPRITE_PLAYBACK_SPEED_MULTIPLIER
        
        if data.MovementBlockCooldown > 0 then
            if NORMAL then
                Game():SpawnParticles(npc.Position + PARTICLE_OFFSET, PARTICLE_TYPE, PARTICLE_COUNT, PARTICLE_SPEED, NORMAL_PARTICLE_COLOR, PARTICLE_HEIGHT, PARTICLE_SUBTYPE)
            else
                Game():SpawnParticles(npc.Position + PARTICLE_OFFSET, PARTICLE_TYPE, PARTICLE_COUNT, PARTICLE_SPEED, PARTICLE_COLOR, PARTICLE_HEIGHT, PARTICLE_SUBTYPE)
            end

            local creepEntity = Game():Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CREEP_WHITE, npc.Position, Vector.Zero, npc, 0, npc.InitSeed)
            local creepEffect = creepEntity:ToEffect()
            if creepEffect then
                creepEffect:SetTimeout(CREEP_TIMEOUT)
                creepEffect.Scale = CREEP_SCALE
            end

            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
            npc.Velocity = Vector.Zero
            data.MovementBlockCooldown = data.MovementBlockCooldown - 1
            return true
        end
        
        local sprite = npc:GetSprite()
    
        if npc.EntityCollisionClass ~= EntityCollisionClass.ENTCOLL_NONE then
            if NORMAL then
                Game():SpawnParticles(npc.Position + PARTICLE_OFFSET, PARTICLE_TYPE, PARTICLE_COUNT, PARTICLE_SPEED, NORMAL_PARTICLE_COLOR, PARTICLE_HEIGHT, PARTICLE_SUBTYPE)
            else
                Game():SpawnParticles(npc.Position + PARTICLE_OFFSET, PARTICLE_TYPE, PARTICLE_COUNT, PARTICLE_SPEED, PARTICLE_COLOR, PARTICLE_HEIGHT, PARTICLE_SUBTYPE)
            end

            local creepEntity = Game():Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CREEP_WHITE, npc.Position, Vector.Zero, npc, 0, npc.InitSeed)
            local creepEffect = creepEntity:ToEffect()
            if creepEffect then
                creepEffect:SetTimeout(CREEP_TIMEOUT)
                creepEffect.Scale = CREEP_SCALE
            end
        end

        if sprite:IsEventTriggered(EVENT_TRIGGER_RESOULED_SHOOT) then
            npc:PlaySound(SFX_SHOOT, VOLUME_SHOOT, 0, false, 1)
            npc:FireBossProjectiles(TEAR_COUNT, npc:GetPlayerTarget().Position, TEAR_TRAJECTORY_MODIFIER, data.TearParams)
            
        elseif sprite:IsEventTriggered(EVENT_TRIGGER_RESOULED_LAND) then
            data.MovementBlockCooldown = math.ceil(LAND_MOVEMENT_BLOCK_COOLDOWN / sprite.PlaybackSpeed)
            npc:PlaySound(SFX_LAND, VOLUME_LAND, 0, false, 1)
            for i = 0, LASER_COUNT - 1 do
                local laser1 = EntityLaser.ShootAngle(LASER_VARIANT, npc.Position, 360/LASER_COUNT * i, LASER_TIMEOUT, Vector.Zero, npc)
                local laser2 = EntityLaser.ShootAngle(LASER_VARIANT, npc.Position, 360/LASER_COUNT * i, LASER_TIMEOUT, Vector.Zero, npc)
                laser1.EntityCollisionClass = LASER_COLLISION_CLASS
                laser2.EntityCollisionClass = LASER_COLLISION_CLASS
                laser1.TearFlags = LASER_TEAR_FLAGS
                laser2.TearFlags = LASER_TEAR_FLAGS
                laser1:SetActiveRotation(0, LASER_ROTATION_ANGLE, LASER_ROTATION_SPEED, false)
                laser2:SetActiveRotation(0, LASER_ROTATION_ANGLE, -LASER_ROTATION_SPEED, false)
                laser1:SetTimeout(LASER_TIMEOUT)
                laser2:SetTimeout(LASER_TIMEOUT)
                laser1:SetMaxDistance(LASER_MAX_DISTANCE)
                laser2:SetMaxDistance(LASER_MAX_DISTANCE)
                laser1.Color = LASER_COLOR
                laser2.Color = LASER_COLOR
            end
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_NPC_UPDATE, onNpcUpdate, EntityType.ENTITY_MONSTRO)

local function postNpcDeath(_, npc)
    local itemConfig = Isaac.GetItemConfig()
    local collectible = itemConfig:GetCollectible(MONSTORS_SOUL_ITEM_SUBTYPE)
    if npc.Variant ~= MONSTROS_SOUL_VARIANT and collectible:IsAvailable() then
        Resouled:TrySpawnSoulItem(ResouledSouls.MONSTRO, npc.Position)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, postNpcDeath, EntityType.ENTITY_MONSTRO)

---@param npc EntityNPC
local function onNpcDeath(_, npc)
    if npc.Variant ~= MONSTROS_SOUL_VARIANT then 
        Resouled:SpawnSoulPickup(npc, SOUL)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, onNpcDeath, EntityType.ENTITY_MONSTRO)