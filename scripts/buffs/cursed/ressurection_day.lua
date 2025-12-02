local REVIVE_CHANCE = 0.2
local REVIVE_HEALTH = 0.5

local function curseActive()
    return Resouled:ActiveBuffPresent(Resouled.Buffs.RESSURECTION_DAY) or Resouled:IsSpecialSeedEffectActive(Resouled.SpecialSeedEffects.EverythingIsCursed)
end

---@param c Color
---@return Color
local reviveColor = function(c)
    c.R = c.R - 0.125
    c.G = c.G - 0.125
    c.B = c.B - 0.125
    c.RO = c.RO + 255/255
    c.GO = c.GO + 247.1/255
    c.BO = c.BO + 176.3/255
    return c
end

---@param entity Entity
---@param amount number
local function entityTakeDMG(_, entity, amount)
    local data = entity:GetData()
    if not data.Resouled_RessurectionDayRevive and curseActive() and entity.HitPoints - amount <= 0 and RNG(entity.InitSeed):RandomFloat() < REVIVE_CHANCE then
        local npc = entity:ToNPC()
        if npc and npc:IsActiveEnemy() and npc:IsEnemy() and not npc:IsBoss() then
            
            npc.HitPoints = npc.MaxHitPoints * REVIVE_HEALTH

            data.Resouled_RessurectionDayRevive = true

            local color = reviveColor(npc:GetColor())
            npc:SetColor(color, 25, 100, true, true)
            EntityEffect.CreateLight(npc.Position, 3, 12, nil, color)

            return false
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, entityTakeDMG)

Resouled:AddBuffToRemoveOnRunEnd(Resouled.Buffs.RESSURECTION_DAY)