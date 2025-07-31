local TENTACLE_BLACK = Resouled:GetEntityByName("Stun Tentacle (Black)")
local TENTACLE_PINK = Resouled:GetEntityByName("Stun Tentacle (Pink)")

local TENTACLE_BLACK_SPRITESHEET = "gfx/effects/stun_tentacle_black.png"
local TENTACLE_PINK_SPRITESHEET = "gfx/effects/stun_tentacle_pink.png"

local SPRITESHEET_LAYER = 0

local SPRITESHEETS = {
    [TENTACLE_BLACK.SubType] = TENTACLE_BLACK_SPRITESHEET,
    [TENTACLE_PINK.SubType] = TENTACLE_PINK_SPRITESHEET,
}

local MAX_GRAB_DISTANCE = 20
local CAN_STUN_BOSSES = false
local STUN_DURATION = 90

local STUN_TARGET_POSITION_OFFSET = Vector(0, -5) -- to make tentacles be in front

local ANIMATION_GRAB = "Grab"
local ANIMATION_LOOP = "GrabLoop"
local ANIMATION_RELEASE = "GrabEnd"

local ANIMATION_EVENT_GRAB = "Grab"
local ANIMATION_EVENT_RELEASE = "Release"

---@param effect EntityEffect
local function onEffectInit(_, effect)
    if SPRITESHEETS[effect.SubType] then
        effect:GetSprite():ReplaceSpritesheet(SPRITESHEET_LAYER, SPRITESHEETS[effect.SubType], true)
        local entitiesInRadius = Isaac.FindInRadius(effect.Position, MAX_GRAB_DISTANCE, EntityPartition.ENEMY)

        local closestTarget = nil
        local closestTargetDistance = math.huge
        for _, entity in ipairs(entitiesInRadius) do
            if entity:IsActiveEnemy() and entity:IsVulnerableEnemy() and (CAN_STUN_BOSSES or not entity:IsBoss()) then
                local distance = entity.Position:Distance(effect.Position)
                if distance < closestTargetDistance then
                    closestTarget = entity
                    closestTargetDistance = distance
                end
            end
        end

        if closestTarget then
            effect.Target = closestTarget
            effect:GetSprite():Play(ANIMATION_GRAB, true)
        else
            effect:Remove() -- nothing to grab so despawn
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, onEffectInit, TENTACLE_BLACK.Variant)

---@param effect EntityEffect
local function onEffectUpdate(_, effect)
    if SPRITESHEETS[effect.SubType] then
        local sprite = effect:GetSprite()
        local data = effect:GetData()

        -- countdown and release when over
        if data.RESOULED__STUN_TENTACLE_STUN_DURATION then
            data.RESOULED__STUN_TENTACLE_STUN_DURATION = data.RESOULED__STUN_TENTACLE_STUN_DURATION - 1
            if data.RESOULED__STUN_TENTACLE_STUN_DURATION <= 0 then
                sprite:Play(ANIMATION_RELEASE, true)
                data.RESOULED__STUN_TENTACLE_STUN_DURATION = nil
            end
        end

        -- set active flag betwen grab and release
        if sprite:IsEventTriggered(ANIMATION_EVENT_GRAB) then
            data.RESOULED__STUN_TENTACLE_ACTIVE = true
            data.RESOULED__STUN_TENTACLE_STUN_DURATION = STUN_DURATION
        elseif sprite:IsEventTriggered(ANIMATION_EVENT_RELEASE) then
            data.RESOULED__STUN_TENTACLE_ACTIVE = nil
        end

        if effect.Target and effect.Target:Exists() then
            -- hold in place
            if data.RESOULED__STUN_TENTACLE_ACTIVE then
                effect.Target.Velocity = ((effect.Position + STUN_TARGET_POSITION_OFFSET) - effect.Target.Position)
            end
        else -- retract because target is gone
            data.RESOULED__STUN_TENTACLE_ACTIVE = nil
            data.RESOULED__STUN_TENTACLE_STUN_DURATION = nil
        end

        if sprite:IsPlaying(ANIMATION_LOOP) and not data.RESOULED__STUN_TENTACLE_ACTIVE then
            sprite:Play(ANIMATION_RELEASE, true)
        end

        -- grab / release finish logic
        if sprite:IsFinished(ANIMATION_GRAB) then
            sprite:Play(ANIMATION_LOOP, true)
        elseif sprite:IsFinished(ANIMATION_RELEASE) then
            effect:Remove()
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_EFFECT_UPDATE, onEffectUpdate, TENTACLE_BLACK.Variant)
