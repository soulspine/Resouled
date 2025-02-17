local ISAACS_LAST_WILL = Isaac.GetItemIdByName("Isaac's last will")

if EID then
    EID:addCollectible(ISAACS_LAST_WILL, "Grants {{Guppy}} Guppy transformation when Isaac dies.", "Isaac's last will")
end

---@param entity Entity
local function onEntityDeath(_, entity)
    local player = entity:ToPlayer()
    if player then
        MOD:GrantGuppyTransformation(player)
    end
end
MOD:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, onEntityDeath)