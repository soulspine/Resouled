local clearPool = {}

---@param variant integer
---@param subType integer
local function addToClearPool(variant, subType)
    table.insert(clearPool,
        {
            variant,
            subType,
        }
    )
end

addToClearPool(PickupVariant.PICKUP_CHEST, 0)
addToClearPool(PickupVariant.PICKUP_TRINKET, 0)
addToClearPool(PickupVariant.PICKUP_TAROTCARD, 0)
addToClearPool(PickupVariant.PICKUP_PILL, 0)
addToClearPool(PickupVariant.PICKUP_WOODENCHEST, 0)
addToClearPool(PickupVariant.PICKUP_COIN, CoinSubType.COIN_DIME)
addToClearPool(PickupVariant.PICKUP_KEY, KeySubType.KEY_CHARGED)
addToClearPool(PickupVariant.PICKUP_BOMB, BombSubType.BOMB_GIGA)

local function preSpawnCleanReward()
    if Resouled:RoomEventPresent(Resouled.RoomEvents.BLESSING_OF_GLUTTONY) then
        local config = clearPool[RNG(Game():GetRoom():GetAwardSeed()):RandomInt(#clearPool) + 1]
        Game():Spawn(EntityType.ENTITY_PICKUP, config[1], Isaac.GetFreeNearPosition(Game():GetRoom():GetCenterPos(), 0), Vector.Zero, nil, config[2], Game():GetRoom():GetAwardSeed())
        return true
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, preSpawnCleanReward)