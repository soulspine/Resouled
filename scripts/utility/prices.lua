---@class PricesModule
local pricesModule = {}

local MOD = Resouled

---@param pickup EntityPickup
---@param decrease integer
---@param minPrice? integer --default `1` 
function pricesModule:FlatDecreaseShopPickupPrice(pickup, decrease, minPrice)
    pickup:GetData().FlatPriceDecrease = {
        Decrease = decrease,
        MinPrice = minPrice and minPrice or 1,
        OriginalPrice = nil -- will be set in the first update cycle
    }
    pickup.AutoUpdatePrice = true
end

---@param pickup EntityPickup
MOD:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, function(_, pickup)
    local data = pickup:GetData()
    if data.FlatPriceDecrease and pickup:IsShopItem() and pickup.Price > 0 then
        if pickup.AutoUpdatePrice == true then
            data.FlatPriceDecrease.OriginalPrice = pickup.Price
            pickup.AutoUpdatePrice = false
            pickup.Price = math.max(data.FlatPriceDecrease.MinPrice, data.FlatPriceDecrease.OriginalPrice - data.FlatPriceDecrease.Decrease)
        else
            pickup.AutoUpdatePrice = true
        end
    end
end)

---@param pickup EntityPickup
function pricesModule:UndoShopPickupFlatPriceDecrease(pickup)
    pickup:GetData().FlatPriceDecrease = nil
    pickup.AutoUpdatePrice = true
end

---@param pickup EntityPickup
---@return integer | nil
function pricesModule:GetPickupFlatPriceDecrease(pickup)
    return pickup:GetData().FlatPriceDecrease and pickup:GetData().FlatPriceDecrease.Decrease or nil
end

return pricesModule