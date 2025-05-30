local CURSE = LevelCurse.CURSE_OF_THE_UNKNOWN

local function postGameStart()
    if Resouled:BuffPresent(Resouled.Buffs.DEVILS_HEAD) then
        Game():GetLevel():AddCurse(CURSE, false)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, postGameStart)

local function preSpawnCleanReward()
    local room = Game():GetRoom()
    if Resouled:BuffPresent(Resouled.Buffs.DEVILS_HEAD) and room:GetType() == RoomType.ROOM_BOSS then
        Game():GetLevel():InitializeDevilAngelRoom(false, true)
        room:TrySpawnDevilRoomDoor(true, true)
        Resouled:RemoveBuffFromSave(Resouled.Buffs.DEVILS_HEAD)
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, preSpawnCleanReward)