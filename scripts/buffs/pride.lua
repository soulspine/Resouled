local function cleanAward()
    local room = Resouled.Game:GetRoom()
    if room:GetType() == RoomType.ROOM_BOSS then
        local seed = room:GetAwardSeed()
        Resouled.Game:Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, room:GetCenterPos(), Vector.Zero, nil, Resouled:GetUnlockedTrikets():PickOutcome(RNG(seed)), seed)
    end
end

Resouled:AddBuffToRemoveOnRunEnd(Resouled.Buffs.PRIDE)

Resouled:AddBuffCallbackConfig(Resouled.Buffs.PRIDE, {
    {
        CallbackID = ModCallbacks.MC_POST_ROOM_TRIGGER_CLEAR,
        Function = cleanAward
    }
})