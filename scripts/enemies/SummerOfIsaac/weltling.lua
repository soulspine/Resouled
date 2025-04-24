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

local OUTSIDE_TIME = 75 -- 2.5 seconds

local TEAR_SPEED = 10
local TEAR_COUNT = 2
local TEAR_SPREAD = 10

local TEAR_PARAMS = ProjectileParams()
TEAR_PARAMS.PositionOffset = Vector(0, -15)
TEAR_PARAMS.Scale = 1.5

---@param npc EntityNPC
local function onNpcInit(_, npc)
    if npc.Variant == WELTLING_VARIANT and npc.SubType == WELTLING_SUBTYPE then
        local sprite = npc:GetSprite()
        local data = npc:GetData()
        sprite:Play(EMERGE, true)
        data.ResouledOutsideTime = OUTSIDE_TIME
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_INIT, onNpcInit, WELTLING_TYPE)

---@param npc EntityNPC
local function onNpcUpdate(_, npc)
    if npc.Variant == WELTLING_VARIANT and npc.SubType == WELTLING_SUBTYPE then
        local sprite = npc:GetSprite()
        local data = npc:GetData()

        npc:UpdateDirtColor(false)
        
        if sprite:IsFinished(EMERGE) then
            sprite:Play(IDLE, true)
        end
        
        if data.ResouledOutsideTime == 0 then
            data.ResouledOutsideTime = OUTSIDE_TIME
            sprite:Play(SHOOT, true)
        end

        if sprite:IsFinished(SHOOT) then
            sprite:Play(RETRACT, true)
        end

        if sprite:IsPlaying(IDLE) and data.ResouledOutsideTime > 0 then
            data.ResouledOutsideTime = data.ResouledOutsideTime - 1
        end

        if sprite:IsFinished(RETRACT) then
            npc.Position = Isaac.GetFreeNearPosition(Isaac.GetRandomPosition(), 1)
            sprite:Play(EMERGE, true)
        end

        if sprite:IsEventTriggered(RETRACT_TRIGGER) then
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
        end

        if sprite:IsEventTriggered(EMERGE_TRIGGER) then
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
        end

        if sprite:IsEventTriggered(SHOOT_TRIGGER) then
            for i = 1, TEAR_COUNT do
                if i == 1 then
                    npc:FireProjectiles(npc.Position, ((npc:GetPlayerTarget().Position - npc.Position):Normalized() * TEAR_SPEED):Rotated(TEAR_SPREAD), 0, TEAR_PARAMS)
                end
                if i == 2 then
                    npc:FireProjectiles(npc.Position, ((npc:GetPlayerTarget().Position - npc.Position):Normalized() * TEAR_SPEED):Rotated(-TEAR_SPREAD), 0, TEAR_PARAMS)
                end
            end
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