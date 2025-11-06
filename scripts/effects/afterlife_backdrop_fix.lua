local config = Resouled.Stats.AfterlifeBackdropFix

---@param effect EntityEffect
local function postEffectInit(_, effect)
    if effect.SubType == config.SubType then
        effect:GetSprite():Play("Idle", true)
        effect:AddEntityFlags(EntityFlag.FLAG_BACKDROP_DETAIL)
        effect.DepthOffset = -100000000
        effect.RenderZOffset = -100000000000
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, postEffectInit, config.Variant)