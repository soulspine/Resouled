local g = Game()

local DADDY_HAUNT = Resouled.Enums.Items.DADDY_HAUNT
local DADDY_HAUNT_VARIANT = Isaac.GetEntityVariantByName("Daddy Haunt")
local DADDY_HAUNT_SUBTYPE = Isaac.GetEntitySubTypeByName("Daddy Haunt")

local VELOCITY_MULTIPLIER = 1.2

local SLAM_DAMAGE = 25
local SLAM_COOLDOWN = 90
local SLAM_VFX = EffectVariant.IMPACT
local SLAM_SFX = SoundEffect.SOUND_POISON_HURT
local SLAM_EFFECT_RADIUS = 70
local SLAM_FEAR_CHANCE = 0.5
local SLAM_FEAR_DURATION = 60

local SPRITE_SCALE = Vector(0.85, 0.85)
local SPRITE_COLOR_FOLLOW_PARENT = Color(1, 1, 1, 0.6)
local SPRITE_COLOR_ENEMY_HOVER = Color(1, 1, 1, 1)

local POSITION_OFFSET_FOLLOW_PARENT = Vector(0, -30)
local POSITION_OFFSET_ENEMY_HOVER = Vector(0, -80)

local ANIMATION_IDLE = "Idle"
local ANIMATION_ATTACK = "Attack"

local ATTACK_ASCEND_FRAME_LENGTH = 12
local ATTACK_DESCEND_FRAME_LENGTH = 4

local EVENT_TRIGGER_RESOULED_SLAM = "ResouledSlam"
local EVENT_TRIGGER_RESOULED_ASCEND = "ResouledAscend"
local EVENT_TRIGGER_RESOULED_DESCEND = "ResouledDescend"

local SLAM_EFFECT_SMOKE_AMOUNT = 16
local MIN_SLAM_EFFECT_SMOKE_SPEED = 9
local MAX_SLAM_EFFECT_SMOKE_SPEED = 18
local SMOKE_COLOR = Color(1, 1, 1, 0.25, 0.35, 0.25, 0.25)
local SMOKE_SPREAD_VECTOR = Vector(1, 0.5)

---@param pos Vector
local function doSlamEffect(pos)
    local x = 360/SLAM_EFFECT_SMOKE_AMOUNT
    local x2 = MAX_SLAM_EFFECT_SMOKE_SPEED - MIN_SLAM_EFFECT_SMOKE_SPEED
    for i = 1, SLAM_EFFECT_SMOKE_AMOUNT do
        local eff = g:Spawn(EntityType.ENTITY_EFFECT, EffectVariant.DARK_BALL_SMOKE_PARTICLE, pos, Vector.Zero, nil, 0, Resouled:NewSeed())
        local x3 = math.random() * x2
        local x4 = 1 + x3/x2
        eff.SpriteScale = Vector(x4, x4)
        eff.Velocity = Vector(MIN_SLAM_EFFECT_SMOKE_SPEED + x3, 0):Rotated(x * (i - 1)) * SMOKE_SPREAD_VECTOR
        eff.Color = SMOKE_COLOR
    end
end

---@param player EntityPlayer
---@param cacheFlag CacheFlag
local function onCacheEval(_, player, cacheFlag)
    if cacheFlag & CacheFlag.CACHE_FAMILIARS then
        Resouled.Familiar:CheckFamiliar(player, DADDY_HAUNT, DADDY_HAUNT_VARIANT, DADDY_HAUNT_SUBTYPE)
    end
end
Resouled:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, onCacheEval)

---@param familiar EntityFamiliar
local function onFamiliarInit(_, familiar)
    if familiar.SubType == DADDY_HAUNT_SUBTYPE then
        local data = familiar:GetData()
        local sprite = familiar:GetSprite()
        data.ResouledCooldown = math.random(0, SLAM_COOLDOWN)
        data.ResouledAscendFrames = 0
        data.ResouledDescendFrames = 0
        sprite.Color = SPRITE_COLOR_FOLLOW_PARENT
        sprite.Scale = SPRITE_SCALE
    end
end
Resouled:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, onFamiliarInit, DADDY_HAUNT_VARIANT)

---@param familiar EntityFamiliar
local function onFamiliarUpdate(_, familiar)
    if familiar.SubType == DADDY_HAUNT_SUBTYPE then
        local sprite = familiar:GetSprite()
        local data = familiar:GetData()
        local room = Game():GetRoom()

        sprite.Scale = SPRITE_SCALE

        if room:GetAliveEnemiesCount() > 0 then
            local target = Resouled.Familiar.Targeting:GetEnemyTarget(familiar)
            if target then
                if familiar.IsFollower then
                    familiar:RemoveFromFollowers()
                    sprite.Color = SPRITE_COLOR_ENEMY_HOVER
                end

                familiar:FollowPosition(target.Position)
                familiar.Velocity = familiar.Velocity * VELOCITY_MULTIPLIER

                if data.ResouledCooldown == 0 then
                    sprite:Play(ANIMATION_ATTACK, true)
                    data.ResouledCooldown = SLAM_COOLDOWN
                else
                    data.ResouledCooldown = data.ResouledCooldown - 1
                end
            else
                Resouled.Familiar.Targeting:SelectRandomEnemyTarget(familiar)
                if sprite:IsPlaying(ANIMATION_IDLE) then
                    familiar.PositionOffset = POSITION_OFFSET_ENEMY_HOVER
                end
            end
        else
            if not familiar.IsFollower then
                familiar:AddToFollowers()
                sprite.Color = SPRITE_COLOR_FOLLOW_PARENT
            end
            familiar:FollowParent()
            familiar.PositionOffset = POSITION_OFFSET_FOLLOW_PARENT
        end

        if data.ResouledAscendFrames > 0 then
            data.ResouledAscendFrames = data.ResouledAscendFrames - 1
            familiar.PositionOffset = familiar.PositionOffset + POSITION_OFFSET_ENEMY_HOVER / ATTACK_ASCEND_FRAME_LENGTH
        elseif data.ResouledDescendFrames > 0 then
            data.ResouledDescendFrames = data.ResouledDescendFrames - 1
            familiar.PositionOffset = familiar.PositionOffset - POSITION_OFFSET_ENEMY_HOVER / ATTACK_DESCEND_FRAME_LENGTH
        end

        if sprite:IsFinished(ANIMATION_ATTACK) then
            sprite:Play(ANIMATION_IDLE, true)
        end

        if sprite:IsEventTriggered(EVENT_TRIGGER_RESOULED_SLAM) then
            doSlamEffect(familiar.Position)
            SFXManager():Play(SLAM_SFX, 1, 0, false, 1)

            ---@type EntityNPC[]
            local npcs = Isaac.FindInRadius(familiar.Position, SLAM_EFFECT_RADIUS, EntityPartition.ENEMY)
            for _, npc in ipairs(npcs) do
                if Resouled:IsValidEnemy(npc) then
                    npc:TakeDamage(SLAM_DAMAGE, 0, EntityRef(familiar), 0)
                    if math.random() < SLAM_FEAR_CHANCE then
                        npc:AddFear(EntityRef(familiar), SLAM_FEAR_DURATION)
                    end
                end
            end
        elseif sprite:IsEventTriggered(EVENT_TRIGGER_RESOULED_ASCEND) then
            data.ResouledAscendFrames = ATTACK_ASCEND_FRAME_LENGTH
        elseif sprite:IsEventTriggered(EVENT_TRIGGER_RESOULED_DESCEND) then
            data.ResouledDescendFrames = ATTACK_DESCEND_FRAME_LENGTH
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, onFamiliarUpdate, DADDY_HAUNT_VARIANT)
