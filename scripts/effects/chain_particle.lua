local EFFECT_VARIANT = Isaac.GetEntityVariantByName("Chain Particle")
local EFFECT_SUBTYPE = Isaac.GetEntitySubTypeByName("Chain Particle")

---@param effect EntityEffect
local function postEffectInit(_, effect)
    if effect.SubType == EFFECT_SUBTYPE then
        effect:GetSprite():Play(tostring(math.random(10) + 1), true)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, postEffectInit, EFFECT_VARIANT)

---@param effect EntityEffect
local function postEffectUpdate(_, effect)
    if effect.SubType == EFFECT_SUBTYPE then
        if effect:GetSprite():IsEventTriggered("Delete") then
            effect:Remove()
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, postEffectUpdate, EFFECT_VARIANT)