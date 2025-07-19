local maxSouls = Resouled.Stats.Soul.Max

local function postNewRoom()
    if Resouled:RoomEventPresent(Resouled.RoomEvents.PITY_FOR_THE_POOR) then
        local RoomSave = SAVE_MANAGER.GetRoomSave()
        if not RoomSave.PityForThePoor then
            RoomSave.PityForThePoor = (maxSouls - Resouled:GetPossessedSoulsNum())/maxSouls
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
        local RoomSave = SAVE_MANAGER.GetRoomSave()
        if RoomSave.PityForThePoor then
            return math.floor(math.max(price * (1 - RoomSave.PityForThePoor)) + 0.5)
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_GET_SHOP_ITEM_PRICE, onGetShopItemPrice)