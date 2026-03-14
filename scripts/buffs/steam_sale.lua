---@param price integer
local function onGetShopItemPrice(_, variant, subtype, shopId, price)
    if Resouled.Game:GetRoom():GetType() == RoomType.ROOM_SHOP and Resouled.Game:GetLevel():GetStage() == 1 then
        return math.floor(price/2)
    end
end

local function postNewFloor()
    if Resouled.Game:GetLevel():GetStage() ~= 1 then
        Resouled:RemoveActiveBuff(Resouled.Buffs.STEAM_SALE)
        Resouled:RemoveCallback(ModCallbacks.MC_GET_SHOP_ITEM_PRICE, onGetShopItemPrice)
        Resouled:RemoveCallback(ModCallbacks.MC_POST_NEW_LEVEL, postNewFloor)
    end
end

Resouled:AddBuffCallbackConfig(Resouled.Buffs.STEAM_SALE, {
    {
        CallbackID = ModCallbacks.MC_GET_SHOP_ITEM_PRICE,
        Function = onGetShopItemPrice
    },
    {
        CallbackID = ModCallbacks.MC_POST_NEW_LEVEL,
        Function = postNewFloor
    }
})