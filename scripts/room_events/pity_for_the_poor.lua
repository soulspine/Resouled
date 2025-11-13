local function postNewRoom()
    if Resouled:RoomEventPresent(Resouled.RoomEvents.PITY_FOR_THE_POOR) then
        print("THis happened", 1 - Resouled:GetPossessedSoulsNum()/100)
        local RoomSave = Resouled.SaveManager.GetRoomSave()
        if not RoomSave.PityForThePoor then
            RoomSave.PityForThePoorDiscount = 1 - Resouled:GetPossessedSoulsNum()/100
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, postNewRoom)

---@param variant integer
---@param subtype integer
---@param shopItemId integer
---@param price integer
local function onGetShopItemPrice(_, variant, subtype, shopItemId, price) --Pre steam sale
    if Resouled:RoomEventPresent(Resouled.RoomEvents.PITY_FOR_THE_POOR) then
        local RoomSave = Resouled.SaveManager.GetRoomSave()
        if RoomSave.PityForThePoorDiscount then
            return math.floor(price * (1 - RoomSave.PityForThePoorDiscount) + 0.5)
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_GET_SHOP_ITEM_PRICE, onGetShopItemPrice)