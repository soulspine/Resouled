local BLOATS_SOUL_TYPE = Isaac.GetEntityTypeByName("Bloat's Soul")
local BLOATS_SOUL_VARIANT = Isaac.GetEntityVariantByName("Bloat's Soul")

local NORMAL = true
local SOUL = "Bloat's Soul"

local ENTITY_FLAGS = (EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
local ENTITY_COLLISION_CLASS = EntityCollisionClass.ENTCOLL_ALL
local GRID_COLLISION_CLASS = GridCollisionClass.COLLISION_SOLID

local TEAR_COUNT = 20
local TEAR_BULLET_FLAGS = (ProjectileFlags.SMART)
local TEAR_SCALE = 1.5
local TEAR_TRAJECTORY_MODIFIER = 1
local TEAR_VARIANT = 6
local TEAR_COLOR = Color(2, 5, 12.5, 0.5)

local ATTACK_COOLDOWN = 3 --seconds
local SECOND_PHASE_ATTACK_COOLDOWN = 3 -- seconds

local ATTACK_TRIGGER = "ResouledAttack"
local BRIMSTONE_START = "ResouledAttackBrimstoneStart"
local BRIMSTONE_END = "ResouledAttackBrimstoneEnd"

local IDLE = "Idle"
local ATTACK = "Attack"
local ATTACK_BRIMSTONE = "AttackBrimstone"
local IDLE_SECOND_PHASE = "IdleSecondPhase"

local LASER_OFFSET = Vector(0, 0)
local LASER_GRID_COLLISION_CLASS = EntityGridCollisionClass.GRIDCOLL_NONE
local LASER_COLLISION_CLASS = EntityCollisionClass.ENTCOLL_PLAYERONLY
local LASER_COLOR = Color(1.3, 1.7, 9, 0.5)
local LASER_VARIANT = LaserVariant.SHOOP
local LASER_ROTATION_SPEED = -1.5

local ATTACK_BRIMSTONE_TIMEOUT = 75
local ATTACK_BRIMSTONE_LASER1_OFFSET = Vector(20, -50)
local ATTACK_BRIMSTONE_LASER2_OFFSET = Vector(-20, -50)
local ATTACK_BRIMSTONE_LASER3_OFFSET = Vector(0, -35)
local ATTACK_BRIMSTONE_LASER3_DEPTH_OFFSET = 10

local PARTICLE_TYPE = EffectVariant.DARK_BALL_SMOKE_PARTICLE
local PARTICLE_COUNT = 5
local PARTICLE_SPEED = 5
local PARTICLE_COLOR = Color(8, 10, 12)
local NORMAL_PARTICLE_COLOR = Color(1.5,1,1)
local PARTICLE_HEIGHT = 0
local PARTICLE_SUBTYPE = 0
local PARTICLE_OFFSET = Vector(0, 0)

local SECOND_PHASE_HEALTH_PRECENT_TRESHHOLD = 25
local SECOND_PHASE_MIN_TEAR_COUNT = 1
local SECOND_PHASE_MAX_TEAR_COUNT = 3
local SECOND_PHASE_TEAR_SHOOT_RANGE = 500
local SECOND_PHASE_TEAR_HEIGHT = -10
local SECOND_PHASE_DEPTH_OFFSET = 100
local SECOND_PHASE_TEAR_ATTACK_COOLDOWN = 4 --updates
local SECOND_PHASE_LASER_VARIANT = LaserVariant.LIGHT_BEAM
local SECOND_PHASE_LASER_COLOR = Color(1, 3, 6, 1)


---@param npc EntityNPC
local function onEntityInit(_, npc)
    if npc.Variant == BLOATS_SOUL_VARIANT then
        local sprite = npc:GetSprite()
        local data = npc:GetData()
        if NORMAL then
            sprite:ReplaceSpritesheet(0, "gfx/souls/bloats_soul_normal.png")
            sprite:LoadGraphics()
        end
        npc.GridCollisionClass = GRID_COLLISION_CLASS
        npc.EntityCollisionClass = ENTITY_COLLISION_CLASS
        npc:AddEntityFlags(ENTITY_FLAGS)
        sprite:Play(IDLE, true)

        data.CurrentAnimation = IDLE
        data.attackCooldown = ATTACK_COOLDOWN
        data.secondPhaseLaserAttackCooldown = SECOND_PHASE_ATTACK_COOLDOWN
        data.SecondPhaseAttackTimer = 0
        data.attackTimer = 0
        data.currentAttack = math.random(1, 2)
        data.brimstoneSpawned = false

        data.TearParams = ProjectileParams()
        data.TearParams.BulletFlags = TEAR_BULLET_FLAGS
        data.TearParams.Scale = TEAR_SCALE
        data.TearParams.Variant = TEAR_VARIANT
        data.TearParams.Color = TEAR_COLOR

        data.SecondTearParams = ProjectileParams()
        data.SecondTearParams.Color = TEAR_COLOR
        data.SecondTearParams.Variant = TEAR_VARIANT
        data.SecondTearParams.HeightModifier = SECOND_PHASE_TEAR_HEIGHT
        data.SecondTearParams.DepthOffset = SECOND_PHASE_DEPTH_OFFSET

        data.VelocityChangeTimer = 0

        data.Phase = "First"

    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_INIT, onEntityInit, BLOATS_SOUL_TYPE)

---@param npc EntityNPC
local function onEntityUpdate(_, npc)
    if npc.Variant == BLOATS_SOUL_VARIANT then

        if NORMAL then
            Game():SpawnParticles(npc.Position + PARTICLE_OFFSET, PARTICLE_TYPE, PARTICLE_COUNT, PARTICLE_SPEED, NORMAL_PARTICLE_COLOR, PARTICLE_HEIGHT, PARTICLE_SUBTYPE)
        else
            Game():SpawnParticles(npc.Position + PARTICLE_OFFSET, PARTICLE_TYPE, PARTICLE_COUNT, PARTICLE_SPEED, PARTICLE_COLOR, PARTICLE_HEIGHT, PARTICLE_SUBTYPE)
        end

        local sprite = npc:GetSprite()
        local data = npc:GetData()
        
        if sprite:GetAnimation() == nil or sprite:IsFinished(data.CurrentAnimation) and data.Phase == "First" then
            sprite:Play(IDLE, true)
        end


        data.VelocityChangeTimer = data.VelocityChangeTimer + 1
        data.attackTimer = data.attackTimer + 1
        if data.Phase == "First" and data.VelocityChangeTimer == 15 then
            local randomMovement =  Vector(math.random(-15, 15), math.random(-15, 15))/15 + (npc:GetPlayerTarget().Position - npc.Position)/400
            npc.Velocity = randomMovement
            data.VelocityChangeTimer = 0
        end

        if data.attackTimer >= data.attackCooldown * 30 and data.Phase == "First" then
            if data.currentAttack == 1 then
                sprite:Play(ATTACK)
                data.CurrentAnimation = ATTACK
                if sprite:WasEventTriggered(ATTACK_TRIGGER) then
                    npc:FireBossProjectiles(TEAR_COUNT, npc:GetPlayerTarget().Position, TEAR_TRAJECTORY_MODIFIER, data.TearParams)
                    data.currentAttack = math.random(1, 2)
                    data.attackTimer = 0
                end
            elseif data.currentAttack == 2 then
                sprite:Play(ATTACK_BRIMSTONE)
                data.CurrentAnimation = ATTACK_BRIMSTONE
                npc.Velocity = Vector.Zero
                if sprite:WasEventTriggered(BRIMSTONE_START) and not data.brimstoneSpawned then
                    local laser1 = EntityLaser.ShootAngle(LASER_VARIANT, npc.Position, -30, 0, LASER_OFFSET, npc)
                    local laser2 = EntityLaser.ShootAngle(LASER_VARIANT, npc.Position, 210, 0, LASER_OFFSET, npc)
                    local laser3 = EntityLaser.ShootAngle(LASER_VARIANT, npc.Position, 90, 0, LASER_OFFSET, npc)
                    laser1.PositionOffset = ATTACK_BRIMSTONE_LASER1_OFFSET
                    laser2.PositionOffset = ATTACK_BRIMSTONE_LASER2_OFFSET
                    laser3.PositionOffset = ATTACK_BRIMSTONE_LASER3_OFFSET
                    laser1.Color = LASER_COLOR
                    laser2.Color = LASER_COLOR
                    laser3.Color = LASER_COLOR
                    laser1:SetTimeout(ATTACK_BRIMSTONE_TIMEOUT)
                    laser2:SetTimeout(ATTACK_BRIMSTONE_TIMEOUT)
                    laser3:SetTimeout(ATTACK_BRIMSTONE_TIMEOUT)
                    laser3.DepthOffset = ATTACK_BRIMSTONE_LASER3_DEPTH_OFFSET
                    data.brimstoneSpawned = true
                end
                if sprite:WasEventTriggered(BRIMSTONE_END) then
                    data.currentAttack = math.random(1, 2)
                    data.attackTimer = 0
                    data.brimstoneSpawned = false
                end
            end
        end

        if npc.HitPoints <= npc.MaxHitPoints / (100/SECOND_PHASE_HEALTH_PRECENT_TRESHHOLD) then
            if data.Phase ~= "Second" then
                data.Phase = "Second"
                sprite:Play(IDLE_SECOND_PHASE, true)
                npc.Position = Game():GetRoom():GetCenterPos()
                data.attackTimer = 0
            end

            if npc.Velocity ~= Vector.Zero then
                npc.Velocity = Vector.Zero
            end

            data.SecondPhaseAttackTimer = data.SecondPhaseAttackTimer + 1

            if data.Phase == "Second" and data.SecondPhaseAttackTimer == SECOND_PHASE_TEAR_ATTACK_COOLDOWN then
                npc:FireBossProjectiles(math.random(SECOND_PHASE_MIN_TEAR_COUNT, SECOND_PHASE_MAX_TEAR_COUNT), npc.Position + Vector(math.random(-SECOND_PHASE_TEAR_SHOOT_RANGE, SECOND_PHASE_TEAR_SHOOT_RANGE), math.random(-SECOND_PHASE_TEAR_SHOOT_RANGE, SECOND_PHASE_TEAR_SHOOT_RANGE)), 2, data.SecondTearParams)
                data.SecondPhaseAttackTimer = 0
            end

            if data.attackTimer == data.secondPhaseLaserAttackCooldown then
                local laser = EntityLaser.ShootAngle(SECOND_PHASE_LASER_VARIANT, npc.Position, 90, 0, LASER_OFFSET, npc)
                laser.GridCollisionClass = LASER_GRID_COLLISION_CLASS
                laser.Color = SECOND_PHASE_LASER_COLOR
                laser:SetActiveRotation(30, 180, LASER_ROTATION_SPEED, false)
                laser.SplatColor = SECOND_PHASE_LASER_COLOR
            end
        end

        return true
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_NPC_UPDATE, onEntityUpdate, BLOATS_SOUL_TYPE)

---@param npc EntityNPC
local function onNpcDeath(_, npc)
    if npc.Variant ~= BLOATS_SOUL_VARIANT and npc.Variant ~= 10 and npc.Variant ~= 11 then --variants 10 and 11 are eyes
        Resouled:SpawnSoulPickup(npc, SOUL)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, onNpcDeath,BLOATS_SOUL_TYPE)