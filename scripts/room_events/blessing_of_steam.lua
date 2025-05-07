local DISCOUNT = 0.25

---@param variant integer
---@param subtype integer
---@param shopItemId integer
---@param price integer
local function onGetShopItemPrice(_, variant, subtype, shopItemId, price) --Pre steam sale
    if Resouled:RoomEventPresent(Resouled.RoomEvents.BLESSING_OF_STEAM) then
        return math.floor(math.max(price - (price * 0.25), 0))
    end
end
Resouled:AddCallback(ModCallbacks.MC_GET_SHOP_ITEM_PRICE, onGetShopItemPrice)