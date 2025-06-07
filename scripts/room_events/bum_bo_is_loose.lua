local function postNewRoom()
    if Resouled:RoomEventPresent(Resouled.RoomEvents.BUM_BO_IS_LOOSE) then
        local bumbo = Game():Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BUMBO, Isaac.GetFreeNearPosition(Game():GetRoom():GetCenterPos(), 0), Vector.Zero, nil, 0, Game():GetRoom():GetAwardSeed())
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, postNewRoom)