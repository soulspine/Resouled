local VARIANT = Isaac.GetEntityVariantByName("Paper Gore Particle")
local SUBTYPE = Isaac.GetEntitySubTypeByName("Paper Gore Particle")

---@param effect EntityEffect
local function postEffectInit(_, effect)
    if effect.SubType == SUBTYPE then
        effect:GetSprite():Play(tostring(math.random(10)))
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, postEffectInit, VARIANT)
