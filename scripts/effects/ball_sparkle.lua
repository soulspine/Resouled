local Sparkle = {
    Variant = Isaac.GetEntityVariantByName("Ball Sparkle"),
    SubType = Isaac.GetEntitySubTypeByName("Ball Sparkle"),
    MaxStartFrameOffset = 8,
    VelocityMultiplier = 0.975,
}

---@param effect EntityEffect
local function onEffectInit(_, effect)
    if effect.SubType == Sparkle.SubType then
        local sprite = effect:GetSprite()
        sprite:Play("Idle", true)
        sprite:SetFrame(math.random(Sparkle.MaxStartFrameOffset) + 1)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, onEffectInit, Sparkle.Variant)

---@param effect EntityEffect
local function onEffectUpdate(_, effect)
    if effect.SubType == Sparkle.SubType then
        local sprite = effect:GetSprite()
        if sprite:IsFinished("Idle") then
            effect:Remove()
        end

        effect.Velocity = effect.Velocity * Sparkle.VelocityMultiplier
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, onEffectUpdate, Sparkle.Variant)