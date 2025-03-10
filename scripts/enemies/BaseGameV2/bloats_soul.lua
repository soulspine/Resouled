local BLOATS_SOUL_TYPE = Isaac.GetEntityTypeByName("Bloat's Soul")
local BLOATS_SOUL_VARIANT = Isaac.GetEntityVariantByName("Bloat's Soul")

local ENTITY_FLAGS = (EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
local ENTITY_COLLISION_CLASS = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
local GRID_COLLISION_CLASS = GridCollisionClass.COLLISION_WALL

local PROJECTILE_PARAMS = ProjectileParams()
local TEAR_COUNT = 20
local TEAR_BULLET_FLAGS = (ProjectileFlags.SMART)
local TEAR_SCALE = 1.5
local TEAR_TRAJECTORY_MODIFIER = 1
local TEAR_VARIANT = 6
local TEAR_COLOR = Color(1.3, 1.7, 9, 0.5)

local ATTACK_COOLDOWN = 10 --seconds
local SECOND_PHASE_ATTACK_COOLDOWN = 5 -- seconds

local ATTACK_TRIGGER = "ResouledAttack"

local IDLE = "Idle"
local ATTACK = "Attack"
local IDLE_SECOND_PHASE = "IdleSecondPhase"

local LASER_OFFSET = Vector(0, 0)
local LASER_GRID_COLLISION_CLASS = EntityGridCollisionClass.GRIDCOLL_NONE
local LASER_COLOR = Color(1, 3, 6, 1)
local LASER_VARIANT = LaserVariant.LIGHT_BEAM
local LASER_ROTATION_SPEED = -1.5

local PARTICLE_TYPE = EffectVariant.DARK_BALL_SMOKE_PARTICLE
local PARTICLE_COUNT = 5
local PARTICLE_SPEED = 5
local PARTICLE_COLOR = Color(8, 10, 12)
local PARTICLE_HEIGHT = 0
local PARTICLE_SUBTYPE = 0
local PARTICLE_OFFSET = Vector(0, 0)

local SECOND_PHASE_HEALTH_PRECENT_TRESHHOLD = 25

---@param npc EntityNPC
local function onEntityInit(_, npc)
    if npc.Variant == BLOATS_SOUL_VARIANT then
        local sprite = npc:GetSprite()
        local data = npc:GetData()
        npc.GridCollisionClass = GRID_COLLISION_CLASS
        npc.EntityCollisionClass = ENTITY_COLLISION_CLASS
        npc:AddEntityFlags(ENTITY_FLAGS)
        sprite:Play(IDLE, true)

        data.CurrentAnimation = IDLE
        data.attackCooldown = ATTACK_COOLDOWN
        data.secondPhaseAttackCooldown = SECOND_PHASE_ATTACK_COOLDOWN
        data.attackTimer = 0
        data.currentAttack = math.random(1, 1)

        data.TearParams = ProjectileParams()
        data.TearParams.BulletFlags = TEAR_BULLET_FLAGS
        data.TearParams.Scale = TEAR_SCALE
        data.TearParams.Variant = TEAR_VARIANT
        data.TearParams.Color = TEAR_COLOR

        data.VelocityChange = 0

        data.Phase = "First"

    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_INIT, onEntityInit, BLOATS_SOUL_TYPE)

---@param npc EntityNPC
local function onEntityUpdate(_, npc)
    if npc.Variant == BLOATS_SOUL_VARIANT then

        Game():SpawnParticles(npc.Position + PARTICLE_OFFSET, PARTICLE_TYPE, PARTICLE_COUNT, PARTICLE_SPEED, PARTICLE_COLOR, PARTICLE_HEIGHT, PARTICLE_SUBTYPE)

        local sprite = npc:GetSprite()
        local data = npc:GetData()
        
        if sprite:GetAnimation() == nil or sprite:IsFinished(data.CurrentAnimation) and data.Phase == "First" then
            sprite:Play(IDLE, true)
        end


        data.VelocityChange = data.VelocityChange + 1
        data.attackTimer = data.attackTimer + 1
        if data.Phase == "First" and data.VelocityChange == 6 then
            local randomMovement =  (npc:GetPlayerTarget().Position - npc.Position)/100 + Vector(math.random(-1, 1), math.random(-1, 1))
            npc.Velocity = randomMovement
            data.VelocityChange = 0
        end

        if data.attackTimer >= data.attackCooldown * 30 and data.Phase == "First" then
            if data.currentAttack == 1 then
                sprite:Play(ATTACK)
                if sprite:WasEventTriggered(ATTACK_TRIGGER) then
                    npc:FireBossProjectiles(TEAR_COUNT, npc:GetPlayerTarget().Position, TEAR_TRAJECTORY_MODIFIER, data.TearParams)
                    data.attackTimer = 0
                end
                data.CurrentAnimation = ATTACK
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

            if data.attackTimer == data.secondPhaseAttackCooldown then
                local laser = EntityLaser.ShootAngle(LASER_VARIANT, npc.Position, 90, 0, LASER_OFFSET, npc)
                laser.GridCollisionClass = LASER_GRID_COLLISION_CLASS
                laser.Color = LASER_COLOR
                laser:SetActiveRotation(30, 180, LASER_ROTATION_SPEED, false)
                laser.SplatColor = LASER_COLOR
            end
        end

        return true
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_NPC_UPDATE, onEntityUpdate, BLOATS_SOUL_TYPE)