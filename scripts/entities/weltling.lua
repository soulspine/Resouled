local WELTLING_TYPE = Isaac.GetEntityTypeByName("Weltling")
local WELTLING_VARIANT = Isaac.GetEntityVariantByName("Weltling")
local WELTLING_SUBTYPE = Isaac.GetEntitySubTypeByName("Weltling")

local IDLE = "Idle"
local EMERGE = "Emerge"
local RETRACT = "Retract"
local SHOOT = "Shoot"

local EMERGE_TRIGGER = "ResouledEmerge"
local RETRACT_TRIGGER = "ResouledRetract"
local SHOOT_TRIGGER = "ResouledShoot"

local SHOOT_CHECK = 20
local SHOOT_CHANCE = 1/4

local TEAR_SPEED = 8
local TEAR_PARAMS = ProjectileParams()
TEAR_PARAMS.BulletFlags = (
    ProjectileFlags.BOUNCE_FLOOR |
    ProjectileFlags.ANY_HEIGHT_ENTITY_HIT
)
TEAR_PARAMS.FallingAccelModifier = 1
TEAR_PARAMS.FallingSpeedModifier = -13
TEAR_PARAMS.PositionOffset = Vector(0, -15)
TEAR_PARAMS.Scale = 2

---@param npc EntityNPC
local function onNpcInit(_, npc)
    if npc.Variant == WELTLING_VARIANT and npc.SubType == WELTLING_SUBTYPE then
        local sprite = npc:GetSprite()
        sprite:Play(EMERGE, true)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_INIT, onNpcInit, WELTLING_TYPE)

---@param npc EntityNPC
local function onNpcUpdate(_, npc)
    if npc.Variant == WELTLING_VARIANT and npc.SubType == WELTLING_SUBTYPE then
        local sprite = npc:GetSprite()

        npc:UpdateDirtColor(false)
        
        if npc.FrameCount % SHOOT_CHECK == 0 and math.random() < SHOOT_CHANCE then
            sprite:Play(SHOOT, true)
        end

        if sprite:IsFinished(EMERGE) then
            sprite:Play(IDLE, true)
        end

        if sprite:IsFinished(SHOOT) then
            sprite:Play(IDLE, true)
        end

        if sprite:IsFinished(RETRACT) then
            sprite:Stop()
        end

        if sprite:IsEventTriggered(RETRACT_TRIGGER) then
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
        end

        if sprite:IsEventTriggered(EMERGE_TRIGGER) then
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
        end

        if sprite:IsEventTriggered(SHOOT_TRIGGER) then
            npc:FireProjectiles(npc.Position, (npc:GetPlayerTarget().Position - npc.Position):Resized(TEAR_SPEED), 0, TEAR_PARAMS)
        end

        if npc.Position.X - npc:GetPlayerTarget().Position.X > 0 then
            sprite:GetLayer(0):SetFlipX(true)
        else
            sprite:GetLayer(0):SetFlipX(false)
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_NPC_UPDATE, onNpcUpdate, WELTLING_TYPE)

---@param tear EntityTear
local function onTearCollision(_, tear)
    if tear.SpawnerEntity then
        if tear.SpawnerEntity.Type == WELTLING_TYPE and tear.SpawnerEntity.Variant == WELTLING_VARIANT and tear.SpawnerEntity.SubType == WELTLING_SUBTYPE then
            Game():Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CREEP_RED, tear.Position, Vector.Zero, tear.SpawnerEntity, 0, tear.SpawnerEntity.InitSeed)
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PROJECTILE_DEATH, onTearCollision)