local function onNewFloor()
    local game = Resouled.Game
    local level = game:GetLevel()
    if level:GetStage() == 1 then
        local roomConfigRoom = RoomConfigHolder.GetRoomByStageTypeAndVariant(StbType.SPECIAL_ROOMS, RoomType.ROOM_PLANETARIUM, 1)
        
        local rng = level:GetDevilAngelRoomRNG()
        local validGridIndexes = level:FindValidRoomPlacementLocations(roomConfigRoom, Dimension.CURRENT, false, false)
        ::reroll::
        
        if validGridIndexes and #validGridIndexes > 0 then
            local tableIndex = rng:RandomInt(#validGridIndexes) + 1
            local roomIndex = validGridIndexes[tableIndex]
            local neighboringRooms = level:GetNeighboringRooms(roomIndex, RoomShape.ROOMSHAPE_1x1, Dimension.CURRENT)
            for _, roomDescriptor in pairs(neighboringRooms) do
                if roomDescriptor.Data.Type == RoomType.ROOM_SECRET or roomDescriptor.Data.Type == RoomType.ROOM_SUPERSECRET and #neighboringRooms == 1 then
                    table.remove(validGridIndexes, tableIndex)
                    goto reroll
                else
                    level:TryPlaceRoom(roomConfigRoom, roomIndex, Dimension.CURRENT, 1, false, false)
                end
            end
        end
    end
end

---@param chance number
local function postPlanetariumChance(_, chance)
    local RUN_SAVE = Resouled.SaveManager.GetRunSave()
    if not RUN_SAVE.Resouled_PlanetariumsVisited then
        RUN_SAVE.Resouled_PlanetariumsVisited = 0
    end
    if RUN_SAVE.Resouled_PlanetariumsVisited < 2 then
        return chance + 0.2
    elseif RUN_SAVE.Resouled_PlanetariumsVisited >= 2 then
        Resouled:RemoveActiveBuff(Resouled.Buffs.HEAVENS_CALL)
        Resouled:RemoveCallback(ModCallbacks.MC_POST_PLANETARIUM_CALCULATE, postPlanetariumChance)
        Resouled:RemoveCallback(ModCallbacks.MC_POST_NEW_LEVEL, onNewFloor)
    end
end
    
local function postNewRoom()
    local RUN_SAVE = Resouled.SaveManager.GetRunSave()
    if not RUN_SAVE.Resouled_PlanetariumsVisited then
        RUN_SAVE.Resouled_PlanetariumsVisited = 0
    end

    local room = Resouled.Game:GetRoom()

    if room:GetType() == RoomType.ROOM_PLANETARIUM and room:IsFirstVisit() then
        RUN_SAVE.Resouled_PlanetariumsVisited = RUN_SAVE.Resouled_PlanetariumsVisited + 1
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, postNewRoom)

Resouled:AddBuffCallbackConfig(Resouled.Buffs.HEAVENS_CALL, {
    {
        CallbackID = ModCallbacks.MC_POST_NEW_LEVEL,
        Function = onNewFloor
    },
    {
        CallbackID = ModCallbacks.MC_POST_PLANETARIUM_CALCULATE,
        Function = postPlanetariumChance
    }
})