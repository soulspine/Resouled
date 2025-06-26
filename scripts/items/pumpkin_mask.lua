local PUMPKIN_MASK = Isaac.GetItemIdByName("Pumpkin Mask")

local FEAR_TIME = 180

---@param entity Entity
---@param amount number
---@param flags DamageFlag
local function playerTakeDamage(_, entity, amount, flags)
    local player = entity:ToPlayer()
    if player:HasCollectible(PUMPKIN_MASK) then
        ---@param entity2 Entity
        Resouled.Iterators:IterateOverRoomEntities(function(entity2)
            local npc = entity2:ToNPC()
            if npc and npc:IsEnemy() and npc:IsActiveEnemy() and npc:IsVulnerableEnemy() then
                npc:AddFear(EntityRef(player), FEAR_TIME)
                ItemOverlay.Show(Isaac.GetGiantBookIdByName("Pumpkin Mask"), 0, player)
            end
        end)
    end
end
Resouled:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, playerTakeDamage, EntityType.ENTITY_PLAYER)