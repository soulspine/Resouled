local EffectDespawnWhitelist = {
    [EffectVariant.TINY_BUG] = true,
    [EffectVariant.WALL_BUG] = true,
    [EffectVariant.TINY_FLY] = true,
}

---@param effect EntityEffect
local function onEffectUpdate(_, effect)
    if Resouled.AfterlifeShop:IsAfterlifeShop() then
        if EffectDespawnWhitelist[effect.Variant] then
            effect:Remove()
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, onEffectUpdate)