local ISAACS_LAST_WILL = Isaac.GetItemIdByName("Isaac's last will")

local COINS = 2

if EID then
    EID:addCollectible(ISAACS_LAST_WILL, "Grants {{Guppy}} Guppy transformation and {{Coin}} " .. COINS .." cents when Isaac dies.", "Isaac's last will")
end

---@param entity Entity
local function onEntityDeath(_, entity)
    local player = entity:ToPlayer()
    if player and player:HasCollectible(ISAACS_LAST_WILL) then
        Resouled:GrantGuppyTransformation(player)
        player:AddCoins(COINS)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, onEntityDeath)