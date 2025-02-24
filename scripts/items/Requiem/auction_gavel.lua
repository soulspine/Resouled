local AUCTION_GAVEL = Isaac.GetItemIdByName("Auction Gavel")

if EID then
    EID:addCollectible(AUCTION_GAVEL, "Not implemented yet", "Auction Gavel")
end

local BID_TIME = 150

local PRE_SHOP_VALUE_BID_CHANCE = 0.5
local POST_99_VALUE_BID_CHANCE = 0.1

local SFX_AUCTION_GAVEL_SOLD = Isaac.GetSoundIdByName("Auction Gavel Sold")
local SFX_SOLD_VOLUME = 1.5



---@param rng RNG
local function npcTryBid(rng)
    local roomSave = SAVE_MANAGER.GetRoomSave()
    local bidValue = roomSave.AuctionGavel.BidValue
    local shopValue = roomSave.AuctionGavel.ShopValue

    local compareVal = PRE_SHOP_VALUE_BID_CHANCE

    if bidValue > shopValue and bidValue < 99 then
        compareVal = PRE_SHOP_VALUE_BID_CHANCE - (PRE_SHOP_VALUE_BID_CHANCE - POST_99_VALUE_BID_CHANCE) * ((bidValue - shopValue)/(99 - shopValue))^2
    elseif bidValue >= 99 then
        compareVal = POST_99_VALUE_BID_CHANCE
    end

    return rng:RandomFloat() < compareVal
end


local function onUpdate()
    local roomSave = SAVE_MANAGER.GetRoomSave()
    if roomSave.AuctionGavel == nil then
        Resouled:RemoveCallback(ModCallbacks.MC_POST_UPDATE, onUpdate)
        return
    end

    roomSave.AuctionGavel.BidTime = roomSave.AuctionGavel.BidTime - 1
    npcTryBid(roomSave.AuctionGavel.RNG)
    if roomSave.AuctionGavel.BidTime <= 0 then
        Resouled:RemoveCallback(ModCallbacks.MC_POST_UPDATE, onUpdate)

        for _, item in ipairs(roomSave.AuctionGavel.Items) do
            Game():Spawn(EntityType.ENTITY_PICKUP, item.Variant, item.Position, Vector.Zero, nil, item.Subtype, Game():GetRoom():GetSpawnSeed())
        end
        Resouled:ForceOpenDoors()

        Isaac.GetPlayer(0):AddCoins(-roomSave.AuctionGavel.BidValue)

    end
end



---@param itemID CollectibleType
---@param rng RNG
---@param player EntityPlayer
---@param useFlags number
---@param activeSlot ActiveSlot
---@param customVarData any
local function onActiveUse(_, itemID, rng, player, useFlags, activeSlot, customVarData)
    local roomSave = SAVE_MANAGER.GetRoomSave()
    
    if roomSave.AuctionGavel ~= nil then
        roomSave.AuctionGavel.BidValue = roomSave.AuctionGavel.BidValue + 1
        roomSave.AuctionGavel.IsPlayerBid = true
        roomSave.AuctionGavel.BidTime = BID_TIME
        player:AnimateCollectible(CollectibleType.COLLECTIBLE_DOLLAR)
        return false
    end

    local shopValue = 0
    local shopItems = {}

    for _, entity in ipairs(Isaac.GetRoomEntities()) do
        if entity.Type == EntityType.ENTITY_PICKUP and entity:ToPickup():IsShopItem() then
            local price = entity:ToPickup().Price
            if price > 0 then
                shopValue = shopValue + price

                local itemEntry = {
                    Variant = entity.Variant,
                    Subtype = entity.SubType,
                    Position = entity.Position,
                }

                entity:Remove()
                table.insert(shopItems, itemEntry)
            end
        end
    end 

    if shopValue > 0 then
        SFXManager():Play(SFX_AUCTION_GAVEL_SOLD, SFX_SOLD_VOLUME)
    else
        return false
    end

    Resouled:ForceShutDoors()

    
    roomSave.AuctionGavel = {
        Finished = false,
        ShopValue = shopValue,
        BidValue = 1,
        IsPlayerBid = true,
        BidTime = BID_TIME,
        Items = shopItems,
        RNG = player:GetCollectibleRNG(AUCTION_GAVEL),
    }
    Resouled:AddCallback(ModCallbacks.MC_POST_UPDATE, onUpdate)

    return true
end
Resouled:AddCallback(ModCallbacks.MC_USE_ITEM, onActiveUse, AUCTION_GAVEL)