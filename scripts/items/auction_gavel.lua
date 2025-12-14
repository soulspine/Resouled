local AUCTION_GAVEL = Isaac.GetItemIdByName("Auction Gavel")

local effectOffsets = {
    [1] = Vector(0, -60),
    [2] = Vector(-30, -60),
    [3] = Vector(30, -60)
}

local GAVEL_VARIANT = Isaac.GetEntityVariantByName("Gavel")
local GAVEL_SUBTYPE = Isaac.GetEntitySubTypeByName("Gavel")

local COLLECTIBLES_TO_NOT_REMOVE = {
    [CollectibleType.COLLECTIBLE_CAR_BATTERY] = true,
    [AUCTION_GAVEL] = true,
    [CollectibleType.COLLECTIBLE_SCHOOLBAG] = true
}

---@param collectibleHistory HistoryItem[]
---@return integer[]
local function getValidCollectibles(collectibleHistory)
    local newTable = {}

    for i = 1, #collectibleHistory do
        local item = Isaac.GetItemConfig():GetCollectible(collectibleHistory[i]:GetItemID())

        local id = collectibleHistory[i]:GetItemID()
        if (item.Type == ItemType.ITEM_PASSIVE or item.Type == ItemType.ITEM_FAMILIAR) and not COLLECTIBLES_TO_NOT_REMOVE[id] then
            table.insert(newTable, id)
        end
    end
    return newTable
end

local function doItemEffect(player, rng, i)
    local validCollectibles = getValidCollectibles(player:GetHistory():GetCollectiblesHistory())

    Resouled:NewSeed()
    local collectibleIndexToRemove = validCollectibles[rng:RandomInt(#validCollectibles) + 1]

    if collectibleIndexToRemove then
        player:RemoveCollectible(collectibleIndexToRemove)
        
        local RUN_SAVE = Resouled.SaveManager.GetRunSave(player)
        table.insert(RUN_SAVE.Resouled_AuctionGavel, collectibleIndexToRemove)
        
        local effectPos = player.Position + effectOffsets[i] + player.SpriteOffset
        local gavel = Game():Spawn(EntityType.ENTITY_EFFECT, GAVEL_VARIANT, effectPos, Vector.Zero, nil, GAVEL_SUBTYPE, rng:GetSeed())
        gavel.DepthOffset = 1000
        gavel:GetData().Resouled_DisappearItem = collectibleIndexToRemove
    end
end

---@param rng RNG
---@param player EntityPlayer
local function onActiveUse(_, _, rng, player)
    local carBattery = player:HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY) and 1 or 0
    local i = 1 + carBattery

    local RUN_SAVE = Resouled.SaveManager.GetRunSave(player)
    RUN_SAVE.Resouled_AuctionGavel = {}

    for j = i, 1 + (carBattery * 2) do
        doItemEffect(player, rng, j)
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

        local RUN_SAVE = Resouled.SaveManager.GetRunSave(player)

        if not auctionGavelItem and RUN_SAVE.Resouled_AuctionGavel and pickup.SubType ~= RUN_SAVE.Resouled_AuctionGavel[1] then
            auctionGavelItem = RUN_SAVE.Resouled_AuctionGavel[1]
            RUN_SAVE.Resouled_AuctionGavel[1] = RUN_SAVE.Resouled_AuctionGavel[2]
            RUN_SAVE.Resouled_AuctionGavel[2] = nil
        end
    end)

    if not auctionGavelItem then return end

    local room = Game():GetRoom()
    local ROOM_SAVE = Resouled.SaveManager.GetRoomFloorSave(pickup)

    if room:GetType() == RoomType.ROOM_SHOP and room:IsFirstVisit() then

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
    local ROOM_SAVE = Resouled.SaveManager.GetRoomFloorSave(pickup)
    if ROOM_SAVE.AuctionGavelPrice then
        Resouled.Prices:FlatDecreaseShopPickupPrice(pickup, 0, ROOM_SAVE.AuctionGavelPrice)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, onPickupUpdate)

---@param pickup EntityPickup
local function postPurchase(_, pickup)
    local ROOM_SAVE = Resouled.SaveManager.GetRoomFloorSave(pickup)
    if ROOM_SAVE.AuctionGavelPrice then
        ROOM_SAVE.AuctionGavelPrice = nil
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PICKUP_SHOP_PURCHASE, postPurchase)