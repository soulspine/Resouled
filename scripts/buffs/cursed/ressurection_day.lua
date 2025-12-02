local REVIVE_CHANCE = 0.1
local REVIVE_HEALTH = 0.5

---@param entity Entity
---@param amount number
local function entityTakeDMG(_, entity, amount)
    local data = entity:GetData()
    if not data.Resouled_RessurectionDayRevive and Resouled:ActiveBuffPresent(Resouled.Buffs.RESSURECTION_DAY) and entity.HitPoints - amount <= 0 and RNG(entity.InitSeed):RandomFloat() < REVIVE_CHANCE then
        local npc = entity:ToNPC()
        if npc and npc:IsActiveEnemy() and npc:IsEnemy() then
            
            npc.HitPoints = npc.MaxHitPoints * REVIVE_HEALTH

            data.Resouled_RessurectionDayRevive = true

            return false
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, entityTakeDMG)