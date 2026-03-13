local function preSpawnCleanReward()
    local room = Resouled.Game:GetRoom()
    if Resouled:ActiveBuffPresent(Resouled.Buffs.RELIC) and room:GetType() == RoomType.ROOM_BOSS then
        Resouled.Game:GetLevel():InitializeDevilAngelRoom(true, true)
        room:TrySpawnDevilRoomDoor(true, true)
        Resouled:RemoveActiveBuff(Resouled.Buffs.RELIC)
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, preSpawnCleanReward)