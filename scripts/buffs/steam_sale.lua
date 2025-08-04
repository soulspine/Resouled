---@param price integer
local function onGetShopItemPrice(_, variant, subtype, shopId, price)
    if Resouled:ActiveBuffPresent(Resouled.Buffs.STEAM_SALE) and Game():GetRoom():GetType() == RoomType.ROOM_SHOP and Game():GetLevel():GetStage() == 1 then
        return math.floor(price/2)
    end
end
Resouled:AddCallback(ModCallbacks.MC_GET_SHOP_ITEM_PRICE, onGetShopItemPrice)

local function postNewFloor()
    if Resouled:ActiveBuffPresent(Resouled.Buffs.STEAM_SALE) then
        if Game():GetLevel():GetStage() ~= 1 then
            Resouled:RemoveActiveBuff(Resouled.Buffs.STEAM_SALE)
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, postNewFloor)

Resouled:AddBuffDescription(Resouled.Buffs.STEAM_SALE, Resouled.EID:AutoIcons("First floor shop has a steam sale effect"))