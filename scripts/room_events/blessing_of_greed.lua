local MIN_VELOCITY = 7
local MAX_VELOCITY = 12

local FADING_COIN_TIMEOUT = 60

---@param npc EntityNPC
local function postNpcDeath(_, npc)
    if Resouled:RoomEventPresent(Resouled.RoomEvents.BLESSING_OF_GREED) then
        local coin = Game():Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, npc.Position, Vector(1 ,0):Rotated(math.random(0, 360) * math.random(MIN_VELOCITY, MAX_VELOCITY)), nil, CoinSubType.COIN_PENNY, npc.InitSeed)
        coin:ToPickup().Timeout = FADING_COIN_TIMEOUT
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, postNpcDeath)