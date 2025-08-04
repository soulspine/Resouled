local CURSE = LevelCurse.CURSE_OF_THE_UNKNOWN

local function postGameStart()
    if Resouled:ActiveBuffPresent(Resouled.Buffs.DEVILS_HEAD) then
        Game():GetLevel():AddCurse(CURSE, false)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, postGameStart)

local function preSpawnCleanReward()
    local room = Game():GetRoom()
    if Resouled:ActiveBuffPresent(Resouled.Buffs.DEVILS_HEAD) and room:GetType() == RoomType.ROOM_BOSS then
        Game():GetLevel():InitializeDevilAngelRoom(false, true)
        room:TrySpawnDevilRoomDoor(true, true)
        Resouled:RemoveActiveBuff(Resouled.Buffs.DEVILS_HEAD)
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, preSpawnCleanReward)

Resouled:AddBuffDescription(Resouled.Buffs.DEVILS_HEAD, Resouled.EID:AutoIcons("The first floor has a guaranteed devil deal. You get a curse of unknown"))