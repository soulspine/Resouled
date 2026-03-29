local CURSE = LevelCurse.CURSE_OF_THE_UNKNOWN

local function postGameStart()
    Resouled.Game:GetLevel():AddCurse(CURSE, false)
end

local function preSpawnCleanReward()
    local room = Resouled.Game:GetRoom()
    if room:GetType() == RoomType.ROOM_BOSS then
        Resouled.Game:GetLevel():InitializeDevilAngelRoom(false, true)
        room:TrySpawnDevilRoomDoor(true, true)
        Resouled:RemoveActiveBuff(Resouled.Buffs.DEVILS_HEAD)
    end
end

Resouled:AddBuffCallbackConfig(Resouled.Buffs.DEVILS_HEAD, {
    {
        CallbackID = ModCallbacks.MC_POST_GAME_STARTED,
        Function = postGameStart
    },
    {
        CallbackID = ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD,
        Function = preSpawnCleanReward
    }
})