local CLEAN_REWARD_POOL = {
    [1] = {["Variant"] = PickupVariant.PICKUP_CHEST, ["SubType"] = 0},
    [2] = {["Variant"] = PickupVariant.PICKUP_TRINKET, ["SubType"] = 0},
    [3] = {["Variant"] = PickupVariant.PICKUP_TAROTCARD, ["SubType"] = 0},
    [4] = {["Variant"] = PickupVariant.PICKUP_PILL, ["SubType"] = 0},
    [5] = {["Variant"] = PickupVariant.PICKUP_WOODENCHEST, ["SubType"] = 0},
    [6] = {["Variant"] = PickupVariant.PICKUP_COIN, ["SubType"] = CoinSubType.COIN_DIME},
    [7] = {["Variant"] = PickupVariant.PICKUP_KEY, ["SubType"] = KeySubType.KEY_CHARGED},
    [8] = {["Variant"] = PickupVariant.PICKUP_BOMB, ["SubType"] = BombSubType.BOMB_GIGA},
}

local function preSpawnCleanReward()
    if Resouled:RoomEventPresent(Resouled.RoomEvents.BLESSING_OF_GLUTTONY) then
        local randomNum = RNG(Game():GetRoom():GetAwardSeed()):RandomInt(#CLEAN_REWARD_POOL) + 1
        Game():Spawn(EntityType.ENTITY_PICKUP, CLEAN_REWARD_POOL[randomNum]["Variant"], Isaac.GetFreeNearPosition(Game():GetRoom():GetCenterPos(), 0), Vector.Zero, nil, CLEAN_REWARD_POOL[randomNum]["SubType"], Game():GetRoom():GetAwardSeed())
        return true
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, preSpawnCleanReward)