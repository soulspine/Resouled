local LIBRARY_CARD = Isaac.GetTrinketIdByName("Library Card")

local function onNewFloor()
    local libraryCardPresent = false
    ---@param player EntityPlayer
    Resouled:IterateOverPlayers(function(player)
        if player:HasTrinket(LIBRARY_CARD) then
            libraryCardPresent = true
        end
    end)
    local seed = 1
    if libraryCardPresent and Game():GetLevel() ~= LevelStage.STAGE4_3 then --4_3 blue womb
        ::chooseAgain::
        local level = Game():GetLevel()
        local exploredRooms = {}
        local randomRoom = Game():GetLevel():GetRandomRoomIndex(false, seed)
        if exploredRooms[randomRoom] == true then
            seed = seed + 1
            goto chooseAgain
        end
        exploredRooms[randomRoom] = true
        local roomDescriptor = level:GetRoomByIdx(randomRoom)
        if roomDescriptor.Data.Shape == RoomShape.ROOMSHAPE_1x1 and roomDescriptor.Data.Type == RoomType.ROOM_DEFAULT then
            Game():GetLevel():GetRoomByIdx(randomRoom).Data = RoomConfigHolder.GetRoomByStageTypeAndVariant(StbType.SPECIAL_ROOMS, RoomType.ROOM_LIBRARY, 0)
        else
            seed = seed + 1
            goto chooseAgain
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, onNewFloor)