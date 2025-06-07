local function preSpawnCleanReward()
    local room = Game():GetRoom()
    if Resouled:BuffPresent(Resouled.Buffs.RELIC) and room:GetType() == RoomType.ROOM_BOSS then
        Game():GetLevel():InitializeDevilAngelRoom(true, true)
        room:TrySpawnDevilRoomDoor(true, true)
        Resouled:RemoveBuffFromActiveSave(Resouled.Buffs.RELIC)
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, preSpawnCleanReward)