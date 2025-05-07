---@param rng RNG
---@param spawnPos Vector
local function preSpawnCleanReward(rng, spawnPos)
    if Resouled:RoomEventPresent(Resouled.RoomEvents.SPOILS_OF_WAR) then
        rng = Game():GetLevel():GetDevilAngelRoomRNG()
        spawnPos = Isaac.GetFreeNearPosition(Game():GetRoom():GetCenterPos(), 0)
        Resouled:SpawnItemFromPool(Game():GetRoom():GetItemPool(Game():GetRoom():GetAwardSeed()), rng, spawnPos, nil)
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, preSpawnCleanReward)