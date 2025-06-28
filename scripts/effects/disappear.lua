local DISAPPEAR_VARIANT = Isaac.GetEntityVariantByName("Disappear")
local DISAPPEAR_SUBTYPE = Isaac.GetEntitySubTypeByName("Disappear")

---@param effect EntityEffect
local function onEffectInit(_, effect)
    if effect.SubType == DISAPPEAR_SUBTYPE then
        effect:GetSprite():Play("Idle", true)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, onEffectInit, DISAPPEAR_VARIANT)

---@param effect EntityEffect
local function onEffectUpdate(_, effect)
    if effect.SubType == DISAPPEAR_SUBTYPE then
        if effect:GetSprite():IsFinished("Idle") then
            effect:Remove()
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, onEffectUpdate, DISAPPEAR_VARIANT)