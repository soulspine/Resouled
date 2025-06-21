local EFFECT_VARIANT = Isaac.GetEntityVariantByName("Wood Particle")
local EFFECT_SUBTYPE = Isaac.GetEntitySubTypeByName("Wood Particle")
local EFFECT_GOLDEN_SUBTYPE = Isaac.GetEntitySubTypeByName("Wood Gold Particle")

---@param effect EntityEffect
local function postEffectInit(_, effect)
    if effect.SubType == EFFECT_SUBTYPE or effect.SubType == EFFECT_GOLDEN_SUBTYPE then
        effect:GetSprite():Play(tostring(math.random(6) + 1), true)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, postEffectInit, EFFECT_VARIANT)

---@param effect EntityEffect
local function postEffectUpdate(_, effect)
    if effect.SubType == EFFECT_SUBTYPE or effect.SubType == EFFECT_GOLDEN_SUBTYPE then
        if effect:GetSprite():IsEventTriggered("Death") then
            effect:Remove()
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, postEffectUpdate, EFFECT_VARIANT)