local function cleanAward()
    if not Resouled:ActiveBuffPresent(Resouled.Buffs.PRIDE) then return end
    local room = Game():GetRoom()
    if room:GetType() == RoomType.ROOM_BOSS then
        local seed = room:GetAwardSeed()
        Game():Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, room:GetCenterPos(), Vector.Zero, nil, Resouled:GetUnlockedTrikets():PickOutcome(RNG(seed)), seed)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_ROOM_TRIGGER_CLEAR, cleanAward)

Resouled:AddBuffToRemoveOnRunEnd(Resouled.Buffs.PRIDE)