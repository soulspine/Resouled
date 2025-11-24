local function preSpawnCleanReward()
    if Resouled:RoomEventPresent(Resouled.RoomEvents.BLOOD_LUST) then
        local player = Isaac.GetPlayer()
        player:UseActiveItem(CollectibleType.COLLECTIBLE_D7, UseFlag.USE_NOANIM | UseFlag.USE_NOHUD)
        SFXManager():Play(SoundEffect.SOUND_BERSERK_START)
        local ROOM_SAVE = Resouled.SaveManager.GetRoomFloorSave()
        ROOM_SAVE.RoomEvent = nil
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, preSpawnCleanReward)