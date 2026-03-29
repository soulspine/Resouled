local function postGameStarted()
    Resouled.Game:Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_OLDCHEST, Resouled.Game:GetRoom():GetCenterPos(), Vector.Zero, nil, 0, Resouled.Game:GetRoom():GetAwardSeed())
    Resouled:RemoveActiveBuff(Resouled.Buffs.FORGOTTEN_POLAROID)
    Resouled:RemoveCallback(ModCallbacks.MC_POST_GAME_STARTED, postGameStarted)
end

Resouled:AddBuffCallbackConfig(Resouled.Buffs.FORGOTTEN_POLAROID, {
    {
        CallbackID = ModCallbacks.MC_POST_GAME_STARTED,
        Function = postGameStarted
    }
})