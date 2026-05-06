local COIN_THRESHOLD = 10

---@param roomConf RoomConfigRoom
local function prePlaceRoom(_, _, roomConf)

    local save = Resouled.SaveManager.GetFloorSave().Shop_Visited or false
    if not save or Isaac.GetPlayer():GetNumCoins() < COIN_THRESHOLD then return end
    
    if roomConf.Type ~= RoomType.ROOM_SHOP then return end

    local id = nil
    for i = 1, 5 do
        if roomConf.Name:find(('L'..i)) then id = 6 + i break end --6 because t.greed shop ids start from 7 and i starts on 1 not 0
    end

    if id then

        return RoomConfig.GetRoomByStageTypeAndVariant(StbType.SPECIAL_ROOMS, RoomType.ROOM_SHOP, id, -1)
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_LEVEL_PLACE_ROOM, prePlaceRoom)

Resouled:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()

    local room = Resouled.Game:GetRoom()

    if not room:GetType() == RoomType.ROOM_SHOP then return end
    Resouled.SaveManager.GetFloorSave().Shop_Visited = true
end)