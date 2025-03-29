local TRICK_PENNY = Isaac.GetItemIdByName("Trick Penny")

local DECREASE = 1
local MIN_PRICE = 1

local PENNY_OBTAIN_CHANCE = 0.25

---@param pickup EntityPickup
local function onPickupUpdate(_, pickup) --Post steam sale
    local currentDecrease = Resouled:GetPickupFlatPriceDecrease(pickup)
    local anyoneHasCollectible = PlayerManager.AnyoneHasCollectible(TRICK_PENNY)
    if anyoneHasCollectible and not currentDecrease then
        Resouled:FlatDecreaseShopPickupPrice(pickup, DECREASE)
    end

    if not anyoneHasCollectible and currentDecrease then
        Resouled:UndoShopPickupFlatPriceDecrease(pickup)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, onPickupUpdate)

---@param variant integer
---@param subtype integer
---@param shopItemId integer
---@param price integer
local function onGetShopItemPrice(_, variant, subtype, shopItemId, price) --Pre steam sale
    if PlayerManager.AnyoneHasCollectible(TRICK_PENNY) then
        return math.max(price - DECREASE, MIN_PRICE)
    end
end
--Resouled:AddCallback(ModCallbacks.MC_GET_SHOP_ITEM_PRICE, onGetShopItemPrice)

local function onUpdate()
    if PlayerManager.AnyoneHasCollectible(TRICK_PENNY) then
        local player = Isaac.GetPlayer(0)
        local data = player:GetData()
        data.ResouledTPCoinsPostUpdate = player:GetNumCoins()
        if data.ResouledTPCoins.PreUpdate then
            if data.ResouledTPCoins.PostUpdate == data.ResouledTPCoins.PreUpdate -1 then
                local chance = math.random()
                if chance < PENNY_OBTAIN_CHANCE then
                    player:AddCoins(1)
                end
            elseif data.ResouledTPCoins.PostUpdate < data.ResouledTPCoins.PreUpdate - 1 then
                player:AddCoins(1)
            end
        end
        data.ResouledTPCoins.PreUpdate = player:GetNumCoins()
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_UPDATE, onUpdate)