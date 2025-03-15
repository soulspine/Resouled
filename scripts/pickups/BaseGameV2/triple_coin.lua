local TRIPLE_COIN_TYPE = Isaac.GetEntityTypeByName("Triple Coin")
local TRIPLE_COIN_VARIANT = Isaac.GetEntityVariantByName("Triple Coin")
local TRIPLE_COIN_SUBTYPE = 8
local DOUBLE_COIN_SUBTYPE = 4

---@param pickup EntityPickup
local function onPickupInit(_, pickup)
    local humbleingBundlePresent = false
    local greedsGulletPresent = false
    Resouled:IterateOverPlayers(
        ---@param player EntityPlayer
    function(player)
        if player:HasCollectible(CollectibleType.COLLECTIBLE_HUMBLEING_BUNDLE) then
            humbleingBundlePresent = true
        end
        if player:HasCollectible(CollectibleType.COLLECTIBLE_GREEDS_GULLET) then
            greedsGulletPresent = true
        end
    end)
    if pickup.Type == TRIPLE_COIN_TYPE and pickup.Variant == TRIPLE_COIN_VARIANT and pickup.SubType == DOUBLE_COIN_SUBTYPE and humbleingBundlePresent and greedsGulletPresent then
        pickup:Morph(TRIPLE_COIN_TYPE, TRIPLE_COIN_VARIANT, TRIPLE_COIN_SUBTYPE, true, true, false)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, onPickupInit)

---@param pickup EntityPickup
---@param collider Entity
---@param low boolean
local function onPickupCollision(_, pickup, collider, low)
    if pickup.Type == TRIPLE_COIN_TYPE and pickup.Variant == TRIPLE_COIN_VARIANT and pickup.SubType == TRIPLE_COIN_SUBTYPE then
        if collider.Type == EntityType.ENTITY_PLAYER then
            collider:ToPlayer():AddCoins(3)
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, onPickupCollision)