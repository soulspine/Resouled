local ITEM_COST_RAISE_PRECENT = 0.25

local function preRoomLeave()
    if Resouled:RoomEventPresent(Resouled.RoomEvents.GREED_LOOMS) then
        local ROOM_SAVE = SAVE_MANAGER.GetRoomFloorSave()
        if not ROOM_SAVE.ResouledRoomVisited then
            ROOM_SAVE.ResouledRoomVisited = true
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_ROOM_EXIT, preRoomLeave)

local function postNewRoom()
    local ROOM_SAVE = SAVE_MANAGER.GetRoomFloorSave()
    if Resouled:RoomEventPresent(Resouled.RoomEvents.GREED_LOOMS) and ROOM_SAVE.ResouledRoomVisited then
        ROOM_SAVE.ResouledGreedLoomsRaisedPrice = true
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, postNewRoom)

---@param variant integer
---@param subtype integer
---@param shopItemId integer
---@param price integer
local function onGetShopItemPrice(_, variant, subtype, shopItemId, price) --Pre steam sale
    local ROOM_SAVE = SAVE_MANAGER.GetRoomFloorSave()
    if ROOM_SAVE.ResouledGreedLoomsRaisedPrice == true then
        return math.floor(math.max(price + (price * ITEM_COST_RAISE_PRECENT), 0))
    end
end
Resouled:AddCallback(ModCallbacks.MC_GET_SHOP_ITEM_PRICE, onGetShopItemPrice)