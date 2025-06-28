local GAVEL_VARIANT = Isaac.GetEntityVariantByName("Gavel")
local GAVEL_SUBTYPE = Isaac.GetEntitySubTypeByName("Gavel")

local SOUND_ID = Isaac.GetSoundIdByName("Gavel")

---@param effect EntityEffect
local function onEffectInit(_, effect)
    if effect.SubType == GAVEL_SUBTYPE then
        effect:GetSprite():Play("Hit", true)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, onEffectInit, GAVEL_VARIANT)

---@param effect EntityEffect
local function onEffectUpdate(_, effect)
    if effect.SubType == GAVEL_SUBTYPE then
        local sprite = effect:GetSprite()
        if sprite:IsFinished("Hit") then
            effect:Remove()
        end
        if sprite:IsEventTriggered("ResouledHit") then
            SFXManager():Play(SOUND_ID)
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, onEffectUpdate, GAVEL_VARIANT)