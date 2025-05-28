local function postRoomClear()
    if Resouled:RoomEventPresent(Resouled.RoomEvents.BLIND_RAGE) then
        if Game():GetLevel():GetNonCompleteRoomIndex() then 
            Game():StartRoomTransition(Game():GetLevel():GetNonCompleteRoomIndex(), Direction.NO_DIRECTION, RoomTransitionAnim.TELEPORT)
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, postRoomClear)