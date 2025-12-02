local DAMAGE_REDUCTION = 0.5
local REDUCTION_CHANCE = 0.5

---@param entity Entity
---@param amount number
---@param flags DamageFlag
---@param source EntityRef
---@param countDown integer
local function entityTakeDMG(_, entity, amount, flags, source, countDown)
    local data = entity:GetData()

    if data.Resouled_Masquerade then
        data.Resouled_Masquerade = nil
        return
    end

    local npc = entity:ToNPC()
    local src = source.Entity
    if npc and npc:IsEnemy() and npc:IsActiveEnemy() then

        if math.random() < REDUCTION_CHANCE then
            
            local angle = npc.Velocity:Rotated(-src.Velocity:GetAngleDegrees())%360
            if angle > 90 and angle < 270 then

                entity:TakeDamage(amount * DAMAGE_REDUCTION, flags, source, countDown)

                data.Resouled_Masquerade = true

                return false
            end
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, entityTakeDMG)