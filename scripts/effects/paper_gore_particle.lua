local PARTICLE = Resouled:GetEntityByName("Paper Gore Particle")

local TTL = 1000 -- in updates, how much time before they despawn, will fade out gradually

---@param effect EntityEffect
Resouled:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, function(_, effect)
    if not Resouled:MatchesEntityDesc(effect, PARTICLE) then return end

    effect:GetSprite():Play(tostring(math.random(10)))
    effect:GetData().Resouled__PaperGoreTTL = TTL
end, PARTICLE.Variant)

---@param effect EntityEffect
Resouled:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, effect)
    local data = effect:GetData()
    if data.Resouled__PaperGoreTTL then
        data.Resouled__PaperGoreTTL = data.Resouled__PaperGoreTTL - 1

        if data.Resouled__PaperGoreTTL == 0 then
            effect:Remove()
            return
        end

        local targetOpacity = data.Resouled__PaperGoreTTL / TTL
        local currentOpacity = effect.Color.A

        if math.floor(100 * currentOpacity) ~= math.floor(100 * targetOpacity) then
            effect.Color = Color(effect.Color.R, effect.Color.G, effect.Color.B, targetOpacity)
        end
    end
end, PARTICLE.Variant)
