local function preSpawnCleanReward()
    if Resouled:RoomEventPresent(Resouled.RoomEvents.BLOOD_LUST) then
        local player = Isaac.GetPlayer()
        player:UseActiveItem(CollectibleType.COLLECTIBLE_D7, UseFlag.USE_NOANIM | UseFlag.USE_NOHUD)
        local ROOM_SAVE = SAVE_MANAGER.GetRoomFloorSave()
        ROOM_SAVE.RoomEvent = "Null"
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, preSpawnCleanReward)