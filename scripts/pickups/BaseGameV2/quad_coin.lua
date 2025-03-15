local QUAD_COIN_TYPE = Isaac.GetEntityTypeByName("Triple Coin")
local QUAD_COIN_VARIANT = Isaac.GetEntityVariantByName("Triple Coin")
local QUAD_COIN_SUBTYPE = 9
local TRIPLE_COIN_SUBTYPE = 8

---@param pickup EntityPickup
local function onPickupInit(_, pickup)
    local humbleingBundlePresent = false
    local greedsGulletPresent = false
    local deepPocketsPresent = false
    Resouled:IterateOverPlayers(
        ---@param player EntityPlayer
    function(player)
        if player:HasCollectible(CollectibleType.COLLECTIBLE_HUMBLEING_BUNDLE) then
            humbleingBundlePresent = true
        end
        if player:HasCollectible(CollectibleType.COLLECTIBLE_GREEDS_GULLET) then
            greedsGulletPresent = true
        end
        if player:HasCollectible(CollectibleType.COLLECTIBLE_DEEP_POCKETS) then
            deepPocketsPresent = true
        end
    end)
    if pickup.Type == QUAD_COIN_TYPE and pickup.Variant == QUAD_COIN_VARIANT and pickup.SubType == TRIPLE_COIN_SUBTYPE and humbleingBundlePresent and greedsGulletPresent and deepPocketsPresent then
        pickup:Morph(QUAD_COIN_TYPE, QUAD_COIN_VARIANT, QUAD_COIN_SUBTYPE, true, true, false)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, onPickupInit)

---@param pickup EntityPickup
---@param collider Entity
---@param low boolean
local function onPickupCollision(_, pickup, collider, low)
    if pickup.Type == QUAD_COIN_TYPE and pickup.Variant == QUAD_COIN_VARIANT and pickup.SubType == QUAD_COIN_SUBTYPE then
        if collider.Type == EntityType.ENTITY_PLAYER then
            collider:ToPlayer():AddCoins(4)
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, onPickupCollision)