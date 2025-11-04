local DeathStatue = Resouled.Stats.DeathStatue

---@param effect EntityEffect
local function onEffectUpdate(_, effect)
    if effect.SubType == DeathStatue.SubType then
        local players = Isaac.FindInRadius(effect.Position, DeathStatue.Size, EntityPartition.PLAYER)

        for _, player in ipairs(players) do
            player.Velocity = player.Velocity + (player.Position - effect.Position):Normalized() * player.Velocity:Length()
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, onEffectUpdate, DeathStatue.Variant)