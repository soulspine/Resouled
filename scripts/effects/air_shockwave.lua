local AIR_SHOCKWAVE_VARIANT = Isaac.GetEntityVariantByName("Air Shockwave")
local AIR_SHOCKWAVE_SUBTYPE = Isaac.GetEntitySubTypeByName("Air Shockwave")

---@param effect EntityEffect
local function onUpdate(_, effect)
    if effect.SubType == AIR_SHOCKWAVE_SUBTYPE then
        local sprite = effect:GetSprite()
        if sprite:IsFinished("Idle") then
            effect:Remove()
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, onUpdate, AIR_SHOCKWAVE_VARIANT)