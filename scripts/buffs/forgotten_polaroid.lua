local function postGameStarted()
    if Resouled:ActiveBuffPresent(Resouled.Buffs.FORGOTTEN_POLAROID) then
        Resouled.Game:Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_OLDCHEST, Resouled.Game:GetRoom():GetCenterPos(), Vector.Zero, nil, 0, Resouled.Game:GetRoom():GetAwardSeed())
        Resouled:RemoveActiveBuff(Resouled.Buffs.FORGOTTEN_POLAROID)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, postGameStarted)