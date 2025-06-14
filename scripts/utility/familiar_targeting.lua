---@class FamiliarTargetingModule
local familiarTargeting = {}

--- Sets targeet of the familiar to a random enemy in the room. It is stored in its data as an `EntityRef`. \
--- Returns `true` if a target was found, `false` otherwise
---@param familiar EntityFamiliar
---@return boolean
function familiarTargeting:SelectRandomEnemyTarget(familiar)
    local data = familiar:GetData()
    local room = Game():GetRoom()
    local entities = room:GetEntities()
    
    local validEnemies = {}
            
    for i = 1, entities.Size do
        local entity = entities:Get(i)
        if entity then
            if entity:IsVulnerableEnemy() and entity:IsActiveEnemy() and entity:IsVisible() then
                table.insert(validEnemies, EntityRef(entity))
            end
        end
    end
    if #validEnemies == 0 then
        return false
    else

    end

    ---@type EntityRef
    data.familiarTargetingTarget = validEnemies[math.random(#validEnemies)]
    return true
end

--- Returns the target of the familiar. If the target is not set, returns `nil`
--- @param familiar EntityFamiliar
--- @return EntityNPC | nil
function familiarTargeting:GetEnemyTarget(familiar)
    local data = familiar:GetData()
    if data.familiarTargetingTarget then
        ---@type EntityNPC
        local npc = data.familiarTargetingTarget.Entity:ToNPC()

        if npc and npc:IsVulnerableEnemy() and npc:IsActiveEnemy() and npc:IsVisible() and not npc:IsDead() then
            return npc
        end
    end
end

---@param familiar EntityFamiliar
function familiarTargeting:ClearEnemyTarget(familiar)
    familiar:GetData().familiarTargetingTarget = nil
end

return familiarTargeting
