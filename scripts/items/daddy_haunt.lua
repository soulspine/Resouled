local DADDY_HAUNT = Isaac.GetItemIdByName("Daddy Haunt")
local DADDY_HAUNT_VARIANT = Isaac.GetEntityVariantByName("Daddy Haunt")

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

if EID then
    EID:addCollectible(DADDY_HAUNT, "Locks onto an enemy and hovers over it slamming down every " .. math.ceil(SLAM_COOLDOWN/30) .. " seconds, dealing " .. math.floor(SLAM_DAMAGE) .. " damage in a small AoE.#Enemies hit have a " .. math.floor(SLAM_FEAR_CHANCE * 100) .. "% chance to be {{Fear}} feared for " .. math.floor(SLAM_FEAR_DURATION/30) .. " seconds.", "Daddy Haunt")
end

---@param player EntityPlayer
---@param cacheFlag CacheFlag
local function onCacheEval(_, player, cacheFlag)
    if cacheFlag & CacheFlag.CACHE_FAMILIARS then
        local itemConfigItem = Isaac.GetItemConfig():GetCollectible(DADDY_HAUNT)
        player:CheckFamiliar(DADDY_HAUNT_VARIANT, player:GetCollectibleNum(DADDY_HAUNT), player:GetCollectibleRNG(DADDY_HAUNT), itemConfigItem)
    end
end
Resouled:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, onCacheEval)

---@param familiar EntityFamiliar
local function onFamiliarInit(_, familiar)
    local data = familiar:GetData()
    local sprite = familiar:GetSprite()
    data.ResouledCooldown = math.random(0, SLAM_COOLDOWN)
    data.ResouledAscendFrames = 0
    data.ResouledDescendFrames = 0
    sprite.Color = SPRITE_COLOR_FOLLOW_PARENT
    sprite.Scale = SPRITE_SCALE

end
Resouled:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, onFamiliarInit, DADDY_HAUNT_VARIANT)

---@param familiar EntityFamiliar
local function onFamiliarUpdate(_, familiar)
    local sprite = familiar:GetSprite()
    local data = familiar:GetData()
    local room = Game():GetRoom()

    sprite.Scale = SPRITE_SCALE

    if room:GetAliveEnemiesCount() > 0 then
        local room = Game():GetRoom()
        if room:GetAliveEnemiesCount() > 0 then
            local target = Resouled.FamiliarTargeting:GetEnemyTarget(familiar)
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
                Resouled.FamiliarTargeting:SelectRandomEnemyTarget(familiar)
                if sprite:IsPlaying(ANIMATION_IDLE) then
                    familiar.PositionOffset = POSITION_OFFSET_ENEMY_HOVER
                end
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
        Game():Spawn(EntityType.ENTITY_EFFECT, Isaac.GetEntityVariantByName("Air Shockwave"), familiar.Position, Vector(0, 0), familiar, Isaac.GetEntitySubTypeByName("Air Shockwave"), 0)
        SFXManager():Play(SLAM_SFX, 1, 0, false, 1)

        ---@param entity EntityEffect
        Resouled.Iterators:IterateOverRoomEntities(function(entity)
            local npc = entity:ToNPC()
            if npc and npc:IsVulnerableEnemy() and npc:IsActiveEnemy() and not npc:IsDead() then
                local distance = (entity.Position - familiar.Position):Length()
                if distance < SLAM_EFFECT_RADIUS then
                    npc:TakeDamage(SLAM_DAMAGE, 0, EntityRef(familiar), 0)
                    if math.random() < SLAM_FEAR_CHANCE then
                        npc:AddFear(EntityRef(familiar), SLAM_FEAR_DURATION)
                    end
                end
            end
        end)
    elseif sprite:IsEventTriggered(EVENT_TRIGGER_RESOULED_ASCEND) then
        data.ResouledAscendFrames = ATTACK_ASCEND_FRAME_LENGTH
    elseif sprite:IsEventTriggered(EVENT_TRIGGER_RESOULED_DESCEND) then
        data.ResouledDescendFrames = ATTACK_DESCEND_FRAME_LENGTH
    end
end
Resouled:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, onFamiliarUpdate, DADDY_HAUNT_VARIANT)

