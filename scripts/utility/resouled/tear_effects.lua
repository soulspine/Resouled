---@enum ResouledTearEffects
Resouled.TearEffects = {
    CHEESE_GRATER = 0
}

--- Applies a custom tear effect to the tear entity
--- @param tear EntityTear | EntityLaser
--- @param effect ResouledTearEffects
function Resouled:ApplyCustomTearEffect(tear, effect)
    local data = tear:GetData()
    if not data.ResouledTearEffect then
        data.ResouledTearEffect = {}
    end
    data.ResouledTearEffect[effect] = true
end

--- Returns an bitmask representing custom tear effects applied to the tear entity
--- @param tear EntityTear | EntityLaser
--- @return table
function Resouled:GetCustomTearEffects(tear)
    return tear:GetData().ResouledTearEffect
end

--- Applies a cooldown so that the custom tear effect can't be applied again for the specified duration
--- @param npc EntityNPC
--- @param effect ResouledTearEffects
--- @param duration integer
function Resouled:ApplyCustomTearEffectCooldown(npc, effect, duration)
    local data = npc:GetData()
    if not data.ResouledTearEffectCooldown then
        data.ResouledTearEffectCooldown = {}
    end

    data.ResouledTearEffectCooldown[effect] = duration
end

--- Returns whether the custom tear effect is on cooldown
--- @param npc EntityNPC
--- @param effect ResouledTearEffects
--- @return boolean
function Resouled:IsCustomTearEffectOnCooldown(npc, effect)
    local data = npc:GetData()
    if data.ResouledTearEffectCooldown then
        if data.ResouledTearEffectCooldown[effect] > 0 then
            return true
        end
    end
    return false
end

---@param npc EntityNPC
Resouled:AddCallback(ModCallbacks.MC_NPC_UPDATE, function(_, npc)
    local data = npc:GetData()
    if data.ResouledTearEffectCooldown then
        for effect, cooldown in pairs(data.ResouledTearEffectCooldown) do
            if cooldown > 0 then
                data.ResouledTearEffectCooldown[effect] = cooldown - 1
                if cooldown == 0 then
                    data.ResouledTearEffectCooldown[effect] = nil
                end
            end
        end
    end
end)