local AUCTION_GAVEL = Isaac.GetItemIdByName("Auction Gavel")

local ITEM_DISAPPEAR_EFFECT_OFFSET = Vector(0, -60)

local GAVEL_VARIANT = Isaac.GetEntityVariantByName("Gavel")
local GAVEL_SUBTYPE = Isaac.GetEntitySubTypeByName("Gavel")

---@param collectibleHistory HistoryItem[]
---@return integer[]
local function getValidCollectibles(collectibleHistory)
    local newTable = {}

    for i = 1, #collectibleHistory do
        local item = Isaac.GetItemConfig():GetCollectible(collectibleHistory[i]:GetItemID())

        if item.Type == ItemType.ITEM_PASSIVE or item.Type == ItemType.ITEM_FAMILIAR then
            table.insert(newTable, collectibleHistory[i]:GetItemID())
        end
    end
    return newTable
end

---@param rng RNG
---@param player EntityPlayer
local function onActiveUse(_, _, rng, player)
    local validCollectibles = getValidCollectibles(player:GetHistory():GetCollectiblesHistory())

    ::RollCollectible::
    Resouled:NewSeed()
    local collectibleIndexToRemove = validCollectibles[rng:RandomInt(#validCollectibles) + 1]

    if collectibleIndexToRemove == AUCTION_GAVEL then
        goto RollCollectible
    end

    player:RemoveCollectible(collectibleIndexToRemove)

    local RUN_SAVE = SAVE_MANAGER.GetRunSave(player)
    if not RUN_SAVE.Resouled_AuctionGavel then
        RUN_SAVE.Resouled_AuctionGavel = collectibleIndexToRemove
    else
        RUN_SAVE.Resouled_AuctionGavel = collectibleIndexToRemove
    end

    local effectPos = player.Position + ITEM_DISAPPEAR_EFFECT_OFFSET + player.SpriteOffset
    local gavel = Game():Spawn(EntityType.ENTITY_EFFECT, GAVEL_VARIANT, effectPos, Vector.Zero, nil, GAVEL_SUBTYPE, rng:GetSeed())
    gavel.DepthOffset = 1000
    gavel:GetData().Resouled_DisappearItem = collectibleIndexToRemove
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
            RUN_SAVE.Resouled_AuctionGavel = nil
        end
    end)
    local room = Game():GetRoom()
    local ROOM_SAVE = SAVE_MANAGER.GetRoomFloorSave(pickup)
    if Game():GetRoom():GetType() == RoomType.ROOM_SHOP and room:IsFirstVisit() and auctionGavelItem then
        pickup:Morph(pickup.Type, pickup.Variant, auctionGavelItem, true)
        ROOM_SAVE.AuctionGavelPrice = 15
    end
    if ROOM_SAVE.AuctionGavelPrice then
        Resouled.Prices:FlatDecreaseShopPickupPrice(pickup, 0, ROOM_SAVE.AuctionGavelPrice)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, postPickupInit, PickupVariant.PICKUP_COLLECTIBLE)

---@param pickup EntityPickup
local function onPickupUpdate(_, pickup)
    local ROOM_SAVE = SAVE_MANAGER.GetRoomFloorSave(pickup)
    if ROOM_SAVE.AuctionGavelPrice then
        Resouled.Prices:FlatDecreaseShopPickupPrice(pickup, 0, ROOM_SAVE.AuctionGavelPrice)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, onPickupUpdate)

---@param pickup EntityPickup
local function postPurchase(_, pickup)
    local ROOM_SAVE = SAVE_MANAGER.GetRoomFloorSave(pickup)
    if ROOM_SAVE.AuctionGavelPrice then
        ROOM_SAVE.AuctionGavelPrice = nil
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PICKUP_SHOP_PURCHASE, postPurchase)