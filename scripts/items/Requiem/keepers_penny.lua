local KEEPERS_PENNY = Isaac.GetItemIdByName("Keeper's Penny")

---@param type CollectibleType
---@param rng RNG
---@param player EntityPlayer
---@param flags UseFlag
---@param slot ActiveSlot
---@param data integer
local function onActiveUse(_, type, rng, player, flags, slot, data)
    player:AnimateCollectible(type, "UseItem", "PlayerPickupSparkle")
    local itemDesc = player:GetActiveItemDesc(slot)
    for _ = 1, itemDesc.VarData do
        Game():Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, Isaac.GetFreeNearPosition(player.Position, 0), Vector.Zero, nil, CoinSubType.COIN_PENNY, Resouled:NewSeed())
    end
    if itemDesc.VarData + 1 > 12 then
        itemDesc.VarData = player:GetActiveMaxCharge(slot)
    else
        itemDesc.VarData = player:GetActiveMaxCharge(slot) + 1
    end
end
Resouled:AddCallback(ModCallbacks.MC_USE_ITEM, onActiveUse, KEEPERS_PENNY)

---@param type CollectibleType
---@param player EntityPlayer
---@param data integer
---@param currentMaxCharge integer
local function playerGetActiveMaxCharge(_, type, player, data, currentMaxCharge)
    local slot = player:GetActiveItemSlot(type)
    if slot > -1 then
        local itemDesc = player:GetActiveItemDesc(slot)
        if itemDesc.VarData == 0 then
            itemDesc.VarData = 1
        end
        return itemDesc.VarData
    end
end
Resouled:AddCallback(ModCallbacks.MC_PLAYER_GET_ACTIVE_MAX_CHARGE, playerGetActiveMaxCharge, KEEPERS_PENNY)