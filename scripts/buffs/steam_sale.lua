---@param price integer
local function onGetShopItemPrice(_, variant, subtype, shopId, price)
    if Resouled:BuffPresent(Resouled.Buffs.STEAM_SALE) and Game():GetRoom():GetType() == RoomType.ROOM_SHOP and Game():GetLevel():GetStage() == 1 then
        return math.floor(price/2)
    end
end
Resouled:AddCallback(ModCallbacks.MC_GET_SHOP_ITEM_PRICE, onGetShopItemPrice)

local function postNewFloor()
    if Resouled:BuffPresent(Resouled.Buffs.STEAM_SALE) then
        if Game():GetLevel():GetStage() ~= 1 then
            Resouled:RemoveBuffFromSave(Resouled.Buffs.STEAM_SALE)
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, postNewFloor)