local LIBRARY_CARD = Isaac.GetTrinketIdByName("Library Card")

local BLACKLISTED_STAGES = {
    [LevelStage.STAGE4_3] = true,
    [LevelStage.STAGE8] = true
}

local function onNewFloor()
    local game = Game()
    local level = game:GetLevel()
    if not game:IsGreedMode() and not level:IsAscent() and not BLACKLISTED_STAGES[level:GetStage()] then
        if PlayerManager.AnyoneHasTrinket(LIBRARY_CARD) then
            local roomConfigRoom = RoomConfigHolder.GetRoomByStageTypeAndVariant(StbType.SPECIAL_ROOMS, RoomType.ROOM_LIBRARY, 1, -1)
            
            --local rng = Isaac.GetPlayer():GetTrinketRNG(LIBRARY_CARD)
            local rng = level:GetDevilAngelRoomRNG()
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
                        local room = level:TryPlaceRoom(roomConfigRoom, roomIndex, Dimension.CURRENT, 1, false, false)
                    end
                end
            end
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, onNewFloor)