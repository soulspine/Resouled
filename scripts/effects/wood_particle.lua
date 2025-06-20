local EFFECT_VARIANT = Isaac.GetEntityVariantByName("Wood Particle")
local EFFECT_SUBTYPE = Isaac.GetEntitySubTypeByName("Wood Particle")

---@param effect EntityEffect
local function postEffectInit(_, effect)
    if effect.SubType == EFFECT_SUBTYPE then
        local sprite = effect:GetSprite()
        if Isaac.GetPlayer():HasGoldenBomb() then
            sprite:ReplaceSpritesheet(0, "gfx/effects/particles/wood_particles_gold.png", true)
        end
        effect:GetSprite():Play(tostring(math.random(6) + 1), true)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, postEffectInit, EFFECT_VARIANT)