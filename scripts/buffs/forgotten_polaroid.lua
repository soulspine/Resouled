local function postGameStarted()
    if Resouled:ActiveBuffPresent(Resouled.Buffs.FORGOTTEN_POLAROID) then
        Game():Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_OLDCHEST, Game():GetRoom():GetCenterPos(), Vector.Zero, nil, 0, Game():GetRoom():GetAwardSeed())
        Resouled:RemoveActiveBuff(Resouled.Buffs.FORGOTTEN_POLAROID)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, postGameStarted)

Resouled:AddBuffDescription(Resouled.Buffs.FORGOTTEN_POLAROID, "Spawns a dire chest at the start")