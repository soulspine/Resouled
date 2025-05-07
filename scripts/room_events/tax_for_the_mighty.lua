---@param variant integer
---@param subtype integer
---@param shopItemId integer
---@param price integer
local function onGetShopItemPrice(_, variant, subtype, shopItemId, price) --Pre steam sale
    if Resouled:RoomEventPresent(Resouled.RoomEvents.TAX_FOR_THE_MIGHTY) then
        local priceToRaise = 0
        ---@param player EntityPlayer
        Resouled.Iterators:IterateOverPlayers(function(player)
            local itemsList = player:GetHistory():GetCollectiblesHistory()
            for i = 1, #itemsList do
                local item = itemsList[i]:GetItemID()
                local quality = Isaac.GetItemConfig():GetCollectible(item).Quality
                if quality >= 3 then
                    priceToRaise = priceToRaise + 1
                end
            end
        end)
        local newPrice = math.max((price + priceToRaise), 0)
        if newPrice > 99 then
            newPrice = 99
        end
        return newPrice
    end
end
Resouled:AddCallback(ModCallbacks.MC_GET_SHOP_ITEM_PRICE, onGetShopItemPrice)