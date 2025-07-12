local Note = {
    Variant = Isaac.GetEntityVariantByName("Music Note"),
    SubType = Isaac.GetEntitySubTypeByName("Music Note"),
    LowestColorValue = 25,
}

---@param effect EntityEffect
local function onEffectInit(_, effect)
    if effect.SubType == Note.SubType then
        local sprite = effect:GetSprite()
        local r = math.random(255)
        local g = math.random(255)
        local b = math.random(255)

        if r < Note.LowestColorValue then r = Note.LowestColorValue end
        if g < Note.LowestColorValue then g = Note.LowestColorValue end
        if b < Note.LowestColorValue then b = Note.LowestColorValue end

        sprite.Color = Color(r/255, g/255, b/255, 1)

        sprite:Play("Wave", true)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, onEffectInit, Note.Variant)

---@param effect EntityEffect
local function onEffectUpdate(_, effect)
    if effect.SubType == Note.SubType and effect:GetSprite():IsFinished("Wave") then
        effect:Remove()
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, onEffectUpdate, Note.Variant)