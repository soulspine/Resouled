---@class FamiliarTargetingModule
local familiarTargeting = {}

--- Sets targeet of the familiar to a random enemy in the room. It is stored in its data as an `EntityRef`. \
--- Returns `true` if a target was found, `false` otherwise
---@param familiar EntityFamiliar
---@return boolean
function familiarTargeting:SelectRandomEnemyTarget(familiar)
    local data = familiar:GetData()
    
    local validEnemies = {}
    
    ---@param npc EntityNPC
    Resouled.Iterators:IterateOverRoomNpcs(function(npc)
        if Resouled:IsValidEnemy(npc) then
            table.insert(validEnemies, EntityRef(npc))
        end
    end)
    if #validEnemies <= 0 then
        return false
    else
        ---@type EntityRef
        data.familiarTargetingTarget = validEnemies[math.random(#validEnemies)]
        return true
    end
end

--- Returns the target of the familiar. If the target is not set, returns `nil`
--- @param familiar EntityFamiliar
--- @return EntityNPC | nil
function familiarTargeting:GetEnemyTarget(familiar)
    local data = familiar:GetData()
    if data.familiarTargetingTarget then
        ---@type EntityNPC
        local npc = data.familiarTargetingTarget.Entity:ToNPC()

        if npc and Resouled:IsValidEnemy(npc) and not npc:IsDead() then
            return npc
        else
            data.familiarTargetingTarget = nil
        end
    end
end

---@param familiar EntityFamiliar
function familiarTargeting:ClearEnemyTarget(familiar)
    familiar:GetData().familiarTargetingTarget = nil
end

---@param familiar EntityFamiliar
function familiarTargeting:SelectNearestEnemyTarget(familiar)
    ---@type nil | EntityNPC
    local nearestEnemy = Resouled:TryFindNearestEnemyByFindInRadius(familiar, 10)

    return nearestEnemy
end

return familiarTargeting