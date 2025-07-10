local LIBRARY_CARD = Isaac.GetTrinketIdByName("Library Card")

if EID then
    EID:addTrinket(LIBRARY_CARD, "Spawns a library every floor")
end

local BLACKLISTED_STAGES = {
    [LevelStage.STAGE4_3] = true,
    [LevelStage.STAGE8] = true
}

local function onNewFloor()
    local game = Game()
    local level = game:GetLevel()
    if not game:IsGreedMode() and not level:IsAscent() and not BLACKLISTED_STAGES[level:GetStage()] and PlayerManager.AnyoneHasTrinket(LIBRARY_CARD) then
        local roomConfigRoom = RoomConfigHolder.GetRoomByStageTypeAndVariant(StbType.SPECIAL_ROOMS, RoomType.ROOM_LIBRARY, 1, -1)
        
        local rng = Isaac.GetPlayer():GetTrinketRNG(LIBRARY_CARD)
        --local rng = level:GetDevilAngelRoomRNG() -- no idea why it was using deal rng
        local validGridIndexes = level:FindValidRoomPlacementLocations(roomConfigRoom, Dimension.CURRENT, false, false)
        ::reroll::
        
        if validGridIndexes and #validGridIndexes > 0 then
            local tableIndex = rng:RandomInt(#validGridIndexes) + 1
            local roomIndex = validGridIndexes[tableIndex]
            local neighboringRooms = level:GetNeighboringRooms(roomIndex, RoomShape.ROOMSHAPE_1x1, Dimension.CURRENT)
            for doorSlot, roomDescriptor in pairs(neighboringRooms) do
                if roomDescriptor.Data.Type == RoomType.ROOM_SECRET or roomDescriptor.Data.Type == RoomType.ROOM_SUPERSECRET and #neighboringRooms == 1 then
                    table.remove(validGridIndexes, tableIndex)
                    goto reroll
                else
                    local newRoomDesc = level:TryPlaceRoom(roomConfigRoom, roomIndex, Dimension.CURRENT, 0, false, false)

                    if newRoomDesc then
                        local currentRoom = level:GetCurrentRoom()
                        
                        for i = 0, DoorSlot.NUM_DOOR_SLOTS - 1 do
                            local door = currentRoom:GetDoor(i)

                            if door and door.TargetRoomIndex == newRoomDesc.SafeGridIndex then -- cant check if door state is closed because its not set yet, all doors are marked as closed at this point
                                SFXManager():Stop(SoundEffect.SOUND_UNLOCK00) -- stop the sound because it still plays
                                door:SetLocked(true)
                            end
                        end
                    end

                end
            end
        end
    end
end
---@diagnostic disable-next-line: param-type-mismatch
Resouled:AddPriorityCallback(ModCallbacks.MC_POST_NEW_LEVEL, -300, onNewFloor)