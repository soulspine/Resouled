---@param slot LevelGeneratorRoom
---@param roomConfig RoomConfigRoom
---@param seed integer
local function prePlaceRoom(_, slot, roomConfig, seed)
    if roomConfig.Type == RoomType.ROOM_TREASURE and Resouled:ActiveBuffPresent(Resouled.Buffs.CONSTELLATION) then
        local newRoom = RoomConfig.GetRandomRoom(seed, false, StbType.SPECIAL_ROOMS, RoomType.ROOM_PLANETARIUM, roomConfig.Shape)
        Resouled:RemoveActiveBuff(Resouled.Buffs.CONSTELLATION)
        return newRoom
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_LEVEL_PLACE_ROOM, prePlaceRoom)