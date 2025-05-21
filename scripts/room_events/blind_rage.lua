local function postRoomClear()
    if Resouled:RoomEventPresent(Resouled.RoomEvents.BLIND_RAGE) then
        local unclearedRooms = {}
        ---@param roomIndex integer
        Resouled.Iterators:IterateOverRooms(function(roomIndex)
            local room = Game():GetLevel():GetRoomByIdx(roomIndex)
            if room.Data then
                if not room.Clear then
                    table.insert(unclearedRooms, room.GridIndex)
                end
            end
        end)
        if #unclearedRooms > 0 then
            local nearestUnclearedRoom = nil
            for i = 1, #unclearedRooms do
                if nearestUnclearedRoom == nil then
                    nearestUnclearedRoom = Resouled:GetGridRoomDistance(Game():GetLevel():GetCurrentRoomIndex(), unclearedRooms[i])
                end
                if Resouled:GetGridRoomDistance(Game():GetLevel():GetCurrentRoomIndex(), unclearedRooms[i]) < nearestUnclearedRoom then
                    nearestUnclearedRoom = unclearedRooms[i]
                end
            end
            Game():GetLevel():ChangeRoom(nearestUnclearedRoom)
        end 
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, postRoomClear)