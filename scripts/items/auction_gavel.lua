local AUCTION_GAVEL = Isaac.GetItemIdByName("Auction Gavel")

local COINS_ON_USE = 10

---@param collectibleHistory HistoryItem[]
---@return HistoryItem[]
local GET_VALID_COLLECTIBLES = function(collectibleHistory)
    local newTable = {}

    for i = 1, #collectibleHistory do
        local item = Isaac.GetItemConfig():GetCollectible(collectibleHistory[i]:GetItemID())

        if item.Type == ItemType.ITEM_PASSIVE or item.Type == ItemType.ITEM_FAMILIAR then
            table.insert(newTable, collectibleHistory[i])
        end
    end
    return newTable
end

---@param rng RNG
---@param player EntityPlayer
local function onActiveUse(_, _, rng, player)
    player:AddCoins(COINS_ON_USE)

    local validCollectibles = GET_VALID_COLLECTIBLES(player:GetHistory():GetCollectiblesHistory())

    ::RollCollectible::
    Resouled:NewSeed()
    local collectibleIndexToRemove = rng:RandomInt(#validCollectibles) + 1
    local itemID = validCollectibles[collectibleIndexToRemove]:GetItemID()

    if itemID == AUCTION_GAVEL then
        goto RollCollectible
    end

    player:RemoveCollectibleByHistoryIndex(collectibleIndexToRemove)

    local RUN_SAVE = SAVE_MANAGER.GetRunSave(player)
    if not RUN_SAVE.Resouled_AuctionGavel then
        RUN_SAVE.Resouled_AuctionGavel = itemID
    else
        RUN_SAVE.Resouled_AuctionGavel = itemID
    end
    return true
end
Resouled:AddCallback(ModCallbacks.MC_USE_ITEM, onActiveUse, AUCTION_GAVEL)

---@param player EntityPlayer
local function preUseCollectible(_, _, _, player)
    local collectibles = player:GetHistory():GetCollectiblesHistory()

    local passiveItemPresent = false

    local i = 1
    while i <= #collectibles do
        local item = Isaac.GetItemConfig():GetCollectible(collectibles[i]:GetItemID())


        if item.Type == ItemType.ITEM_PASSIVE or item.Type == ItemType.ITEM_FAMILIAR then
            passiveItemPresent = true
            break
        end
        i = i + 1
    end

    if not passiveItemPresent then
        return true
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_USE_ITEM, preUseCollectible, AUCTION_GAVEL)

---@param pickup EntityPickup
local function postPickupInit(_, pickup)
    local auctionGavelItem = nil
    ---@param player EntityPlayer
    Resouled.Iterators:IterateOverPlayers(function(player)
        local RUN_SAVE = SAVE_MANAGER.GetRunSave(player)
        if not auctionGavelItem and RUN_SAVE.Resouled_AuctionGavel then
            auctionGavelItem = RUN_SAVE.Resouled_AuctionGavel
        end
    end)
    if Game():GetRoom():GetType() == RoomType.ROOM_SHOP and pickup:IsShopItem() and auctionGavelItem then
        pickup:Morph(pickup.Type, pickup.Variant, auctionGavelItem, true)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, postPickupInit, PickupVariant.PICKUP_COLLECTIBLE)