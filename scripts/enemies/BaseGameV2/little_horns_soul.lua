local LITTLE_HORN_SOUL_TYPE = Isaac.GetEntityTypeByName("Little Horn's Soul")
local LITTLE_HORN_SOUL_VARIANT = Isaac.GetEntityVariantByName("Little Horn's Soul")
local LITTLE_HORN_SOUL_CLONE_SUBTYPE = 1

local SOUL_BALL_TYPE = Isaac.GetEntityTypeByName("Soul Ball")
local SOUL_BALL_VARIANT = Isaac.GetEntityVariantByName("Soul Ball")

local FOLLOW_SPEED = 5
local ORBIT_SIZE = 12
local ORBIT_SPEED = 1
local ONE_FULL_ORBIT = 6.3 --Number found through experimenting

local SPRITE_SIZE = 1.2
local HITBOX_SIZE = 1.2
local HITBOX_MULTI = Vector(1, 1)

local ENTITY_FLAGS = (EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
local ENTITY_COLLISION_CLASS = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
local GRID_COLLISION_CLASS = GridCollisionClass.COLLISION_NONE

local PARTICLE_TYPE = EffectVariant.DARK_BALL_SMOKE_PARTICLE
local PARTICLE_COUNT = 5
local PARTICLE_SPEED = 5
local PARTICLE_COLOR = Color(8, 10, 12)
local CLONE_PARTICLE_COLOR = Color(12, 6, 6)
local PARTICLE_HEIGHT = 0
local PARTICLE_SUBTYPE = 0
local PARTICLE_OFFSET = Vector(0, -35)

local LASER_OFFSET = Vector(0, -25)
local LASER_GRID_COLLISION_CLASS = EntityGridCollisionClass.GRIDCOLL_NONE
local LASER_COLOR = Color(1.3, 1.7, 9, 0.5)
local LASER_VARIANT = LaserVariant.SHOOP

local SHOOT_TRIGGER = "ResouledShoot"
local BOMB_TRIGGER = "ResouledBomb"
local DEATH_TRIGGER = "ResouledDeath"
local SUMMON_TRIGGER = "ResouledSummon"
local COLLISION_OFF_TRIGGER = "ResouledCollisionOFF"
local COLLISION_ON_TRIGGER = "ResouledCollisionON"

local IDLE = "Idle"
local ATTACK = "Shoot"
local BOMB = "Bomb"
local APPEAR = "Appear"
local SUMMON = "Summon"

local BOMB_VARIANT = BombVariant.BOMB_SMALL
local BOMB_SUBTYPE = BombSubType.BOMB_NORMAL

local BOMB_SPAWN_VOLUME = 1
local BOMB_SPAWN_SOUND_DELAY = 0
local BOMB_SPAWN_PITCH = 1
local BOMB_SPAWN_SOUND = SoundEffect.SOUND_SUMMON_POOF
local BOMB_SPAWN_EFFECT = EffectVariant.POOF01

local ATTACK_COOLDOWN = 5 --seconds

---@param npc EntityNPC
local function onNpcInit(_, npc)
    if npc.Variant == LITTLE_HORN_SOUL_VARIANT then
        local sprite = npc:GetSprite()
        local data = npc:GetData()
        npc.GridCollisionClass = GRID_COLLISION_CLASS
        npc.EntityCollisionClass = ENTITY_COLLISION_CLASS
        npc:AddEntityFlags(ENTITY_FLAGS)
        data.x = 0
        data.orbit = Vector
        data.attackTimer = 0
        data.attackCooldown = ATTACK_COOLDOWN
        npc.Scale = SPRITE_SIZE
        npc.Size = npc.Size * HITBOX_SIZE
        npc.SizeMulti = HITBOX_MULTI
        data.CurrentAnimation = APPEAR
        data.attack = math.random(1,3)
        data.bombCount = 0
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_INIT, onNpcInit, LITTLE_HORN_SOUL_TYPE)

---@param npc EntityNPC
local function onNpcUpdate(_, npc)
    if npc.Variant == LITTLE_HORN_SOUL_VARIANT then
        if npc.SubType == 0 then
            Game():SpawnParticles(npc.Position + PARTICLE_OFFSET, PARTICLE_TYPE, PARTICLE_COUNT, PARTICLE_SPEED, PARTICLE_COLOR, PARTICLE_HEIGHT, PARTICLE_SUBTYPE)
        else
            Game():SpawnParticles(npc.Position + PARTICLE_OFFSET, PARTICLE_TYPE, PARTICLE_COUNT, PARTICLE_SPEED, CLONE_PARTICLE_COLOR, PARTICLE_HEIGHT, PARTICLE_SUBTYPE)
        end

        local sprite = npc:GetSprite()
        local data = npc:GetData()

        if data.CurrentAnimation ~= IDLE and sprite:IsFinished(data.CurrentAnimation) then
            data.CurrentAnimation = IDLE
            sprite:Play(IDLE, true)
        end

        data.x = (data.x + 0.1)%(ONE_FULL_ORBIT/ORBIT_SPEED)

        data.orbit = Vector(math.sin(data.x * ORBIT_SPEED), math.cos(data.x * ORBIT_SPEED)) * (ORBIT_SIZE * ORBIT_SPEED)
        npc.Velocity = (npc:GetPlayerTarget().Position - npc.Position):Normalized() * FOLLOW_SPEED + data.orbit
        if npc.Position.Y - npc:GetPlayerTarget().Position.Y > 0 and sprite.FlipX then
            sprite.FlipX = false
        elseif npc.Position.Y - npc:GetPlayerTarget().Position.Y < 0 and not sprite.FlipX then
            sprite.FlipX = true
        end

        data.attackTimer = data.attackTimer + 1
        if data.attackTimer >= data.attackCooldown*30 then
            if data.attack == 1 then
                sprite:Play(ATTACK)
                data.CurrentAnimation = ATTACK
                if sprite:IsEventTriggered(SHOOT_TRIGGER) then
                    local randomDir = math.random(1,2)*180 - 90
                    local ball = Game():Spawn(SOUL_BALL_TYPE, SOUL_BALL_VARIANT, npc.Position, Vector.Zero, npc, 0, npc.InitSeed)
                    local laser = EntityLaser.ShootAngle(LASER_VARIANT, ball.Position, randomDir, 300, LASER_OFFSET, ball)
                    data.attackTimer = 0
                    laser.GridCollisionClass = LASER_GRID_COLLISION_CLASS
                    laser.Color = LASER_COLOR
                    laser:SetActiveRotation(30, 180, -2, false)
                    data.attackTimer = 0
                    data.attack = math.random(1,3)
                end
            elseif data.attack == 2 then
                data.BOMB_POSITION_TRANSLATION = {
                    [1] = npc:GetPlayerTarget().Position + Vector(100, 0),
                    [2] = npc:GetPlayerTarget().Position + Vector(-100, 0),
                    [3] = npc:GetPlayerTarget().Position + Vector(0, 100),
                    [4] = npc:GetPlayerTarget().Position + Vector(0, -100),
                    [5] = npc:GetPlayerTarget().Position + Vector(70, 70),
                    [6] = npc:GetPlayerTarget().Position + Vector(-70, 70),
                    [7] = npc:GetPlayerTarget().Position + Vector(70, -70),
                    [8] = npc:GetPlayerTarget().Position + Vector(-70, -70),
                }
                sprite:Play(BOMB)
                data.CurrentAnimation = BOMB
                if sprite:IsEventTriggered(BOMB_TRIGGER) then
                    npc:PlaySound(BOMB_SPAWN_SOUND, BOMB_SPAWN_VOLUME, BOMB_SPAWN_SOUND_DELAY, false, BOMB_SPAWN_PITCH)
                    for i = 1, 8 do
                        local effect = Game():Spawn(EntityType.ENTITY_EFFECT, BOMB_SPAWN_EFFECT, data.BOMB_POSITION_TRANSLATION[i], Vector.Zero, npc, 0, npc.InitSeed)
                        local laBomba = Game():Spawn(EntityType.ENTITY_BOMB, BOMB_VARIANT, data.BOMB_POSITION_TRANSLATION[i], Vector.Zero, npc, BOMB_SUBTYPE, npc.InitSeed)
                        laBomba.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
                    end
                    data.bombCount = data.bombCount + 1
                    if data.bombCount == 6 then
                        data.attack = math.random(1,3)
                        data.bombCount = 0
                        data.attackTimer = 0
                    end
                end
            elseif data.attack == 3 then
                sprite:Play(SUMMON)
                data.CurrentAnimation = SUMMON
                if sprite:IsEventTriggered(SUMMON_TRIGGER) then
                    Game():Spawn(LITTLE_HORN_SOUL_TYPE, LITTLE_HORN_SOUL_VARIANT, npc.Position, Vector.Zero, npc, LITTLE_HORN_SOUL_CLONE_SUBTYPE, npc.InitSeed)
                    data.attackTimer = 0
                    data.attack = math.random(1,3)
                end
            end
        end
        print(data.orbit)
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_NPC_UPDATE, onNpcUpdate, LITTLE_HORN_SOUL_TYPE)