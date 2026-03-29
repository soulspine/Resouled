local function preSpawnCleanReward()
    local room = Resouled.Game:GetRoom()
    if room:GetType() == RoomType.ROOM_BOSS then
        Resouled.Game:GetLevel():InitializeDevilAngelRoom(true, true)
        room:TrySpawnDevilRoomDoor(true, true)
        Resouled:RemoveActiveBuff(Resouled.Buffs.RELIC)
        Resouled:RemoveCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, preSpawnCleanReward)
    end
end

Resouled:AddBuffCallbackConfig(Resouled.Buffs.RELIC, {
    {
        CallbackID = ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD,
        Function = preSpawnCleanReward
    }
})