local function postNewRoom()
    if not Resouled:RoomEventPresent(Resouled.RoomEvents.EVERYTHING_MUST_GO) then return end
    local roomSave = Resouled.SaveManager.GetRoomFloorSave()
    roomSave.EverythingMustGoPrices = {}
    ---@param pickup EntityPickup
    Resouled.Iterators:IterateOverRoomPickups(function(pickup)
        if pickup:IsShopItem() then
            roomSave.EverythingMustGoPrices[tostring(pickup.ShopItemId)] = 0.5
        end
    end)
end
Resouled:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, postNewRoom)

local function preRoomExit()
    if not Resouled:RoomEventPresent(Resouled.RoomEvents.EVERYTHING_MUST_GO) then return end
    local roomSave = Resouled.SaveManager.GetRoomFloorSave()
    if not roomSave.EverythingMustGoPrices then return end

    ---@param pickup EntityPickup
    Resouled.Iterators:IterateOverRoomPickups(function(pickup)
        if roomSave.EverythingMustGoPrices[tostring(pickup.ShopItemId)] then
            pickup:Remove()
        end
    end)
    roomSave.EverythingMustGoPrices = nil
end
Resouled:AddCallback(ModCallbacks.MC_PRE_ROOM_EXIT, preRoomExit)

---@param variant integer
---@param subtype integer
---@param shopItemId integer
---@param price integer
local function onGetShopItemPrice(_, variant, subtype, shopItemId, price)
    if not Resouled:RoomEventPresent(Resouled.RoomEvents.EVERYTHING_MUST_GO) then return end
    local roomSave = Resouled.SaveManager.GetRoomFloorSave()
    local key = tostring(shopItemId)
    if roomSave.EverythingMustGoPrices[key] then
        return math.floor(price * roomSave.EverythingMustGoPrices[key] + 0.5)
    end
end
Resouled:AddCallback(ModCallbacks.MC_GET_SHOP_ITEM_PRICE, onGetShopItemPrice)