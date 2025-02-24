local CHUNK_OF_AMBER = Isaac.GetCardIdByName("Chunk of Amber")

local PICKUP_SPAWN_STEP = 1
local PICKUP_VELOCITY = 50

if EID then
    EID:addCard(CHUNK_OF_AMBER, "SPAWNS ALL PICKUPS PLAYER HAS IN THEIR INVENTORY#TODO FIX", "Chunk of Amber")
    -- TODO EID.addIcon
end

local function spawnPickups(variant, subtype, amount, position)
    for _ = 1, amount do
        Game():Spawn(EntityType.ENTITY_PICKUP, variant, Isaac.GetFreeNearPosition(position, PICKUP_SPAWN_STEP), Vector(math.random(-PICKUP_VELOCITY, PICKUP_VELOCITY), math.random(-PICKUP_VELOCITY, PICKUP_VELOCITY)), nil, subtype, Game():GetRoom():GetSpawnSeed())
    end
end
---@param cardId Card
---@param player EntityPlayer
---@param useFlags integer
local function onRuneUse(_, cardId, player, useFlags)
    local position = player.Position
    spawnPickups(PickupVariant.PICKUP_COIN, CoinSubType.COIN_PENNY, player:GetNumCoins(), position)
    spawnPickups(PickupVariant.PICKUP_BOMB, BombSubType.BOMB_NORMAL, player:GetNumBombs(), position)
    spawnPickups(PickupVariant.PICKUP_BOMB, BombSubType.BOMB_GIGA, player:GetNumGigaBombs(), position)
    spawnPickups(PickupVariant.PICKUP_KEY, KeySubType.KEY_NORMAL, player:GetNumKeys(), position)
    spawnPickups(PickupVariant.PICKUP_POOP, PoopPickupSubType.POOP_SMALL, player:GetPoopMana(), position)
    spawnPickups(PickupVariant.PICKUP_HEART, HeartSubType.HEART_HALF_SOUL, player:GetSoulCharge(), position)
    spawnPickups(PickupVariant.PICKUP_HEART, HeartSubType.HEART_HALF, player:GetBloodCharge(), position)
end
Resouled:AddCallback(ModCallbacks.MC_USE_CARD, onRuneUse, CHUNK_OF_AMBER)