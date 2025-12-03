local REDUCTION_CHANCE = 0.25

local COUNT_AS_FACE_AREA = 75

local function curseActive()
    return Resouled:ActiveBuffPresent(Resouled.Buffs.MASQUERADE) or Resouled:IsSpecialSeedEffectActive(Resouled.SpecialSeedEffects.EverythingIsCursed)
end

---@param entity Entity
---@param amount number
---@param flags DamageFlag
---@param source EntityRef
---@param countDown integer
local function entityTakeDMG(_, entity, amount, flags, source, countDown)

    if not curseActive() then return end

    local npc = entity:ToNPC()
    local src = source.Entity
    if src and npc and npc:IsEnemy() and npc:IsActiveEnemy() then

        if math.random() < REDUCTION_CHANCE then
            
            local angle = npc.Velocity:Rotated(-src.Velocity:GetAngleDegrees()):GetAngleDegrees()%360
            if angle > 180 - COUNT_AS_FACE_AREA/2 and angle < 180 + COUNT_AS_FACE_AREA/2 then
                local c = npc:GetColor()
                npc:SetColor(Color(c.R, c.G, c.B, c.A, c.RO + 0.25098, c.GO + 0.25098, c.BO + 0.501961), 15, 1, true, true)
                return false
            end
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, entityTakeDMG)

Resouled:AddBuffToRemoveOnRunEnd(Resouled.Buffs.MASQUERADE)