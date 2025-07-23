local SoulLantern = {
    Variant = Isaac.GetEntityVariantByName("Soul Lantern"),
    SubType = Isaac.GetEntitySubTypeByName("Soul Lantern"),
    MinOffset = 140,
    MaxOffset = 160,
    StartSpeed = 5,
    MinRotateSpeed = 0.04,
    SoulSpeed = 15
}

---@param effect EntityEffect
local function onEffectInit(_, effect)
    if effect.SubType == SoulLantern.SubType then
        local sprite = effect:GetSprite()
        sprite:Play("Idle", true)
        sprite.Offset = Vector(0, -math.random(SoulLantern.MinOffset, SoulLantern.MaxOffset))

        effect:GetData().Resouled_SpritePlaybackSpeed = math.random(-25, 25)/100
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, onEffectInit, SoulLantern.Variant)

---@param effect EntityEffect
local function onEffectRender(_, effect)
    if not Game():IsPaused() then
        if effect.SubType == SoulLantern.SubType then
            local data = effect:GetData()
            
            if data.Resouled_SpritePlaybackSpeed then
                local sprite = effect:GetSprite()
                
                if not data.Resouled_SoulLantern then
                    data.Resouled_SoulLantern = {
                        Rotation = data.Resouled_SpritePlaybackSpeed,
                        Speed = SoulLantern.MinRotateSpeed,
                        CurrentSpeed = data.Resouled_SpritePlaybackSpeed * SoulLantern.StartSpeed,
                    }
                end
                
                if data.Resouled_SoulLantern.Rotation > 0 then
                    data.Resouled_SoulLantern.CurrentSpeed = data.Resouled_SoulLantern.CurrentSpeed - data.Resouled_SoulLantern.Speed
                else
                    data.Resouled_SoulLantern.CurrentSpeed = data.Resouled_SoulLantern.CurrentSpeed + data.Resouled_SoulLantern.Speed
                end
                
                data.Resouled_SoulLantern.Rotation = data.Resouled_SoulLantern.Rotation + data.Resouled_SoulLantern.CurrentSpeed
                
                sprite.Rotation = data.Resouled_SoulLantern.Rotation

                local soul = sprite:GetLayer("Soul")
                if soul then
                    soul:SetRotation(soul:GetRotation() + SoulLantern.SoulSpeed)
                end
            end
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_EFFECT_RENDER, onEffectRender, SoulLantern.Variant)