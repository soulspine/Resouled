local COIN_DROP_AMOUNT_MIN = 4
local COIN_DROP_AMOUNT_MAX = 6
local COIN_TIMEOUT = 60 -- frames
local COIN_POSITION_STEP = 10
local COIN_SPAWN_VECTOR_SIZE = 2

---@param entity Entity
---@param amount number
---@param flags integer
---@param source EntityRef
---@param countdown integer
local function onPlayerDamage(_, entity, amount, flags, source, countdown)
    print("Curse: " .. Game():GetLevel():GetCurses())
    print(Game():GetLevel():GetCurseName())
    local player = entity:ToPlayer()
    if player and Resouled:CustomCursePresent(Resouled.Curses.CURSE_OF_GREED) and flags & DamageFlag.DAMAGE_FAKE == 0 then
        local coins = player:GetNumCoins()
        if coins > 0 then
            local rng = player:GetDropRNG()
            local greedCoins = math.min(rng:RandomInt(COIN_DROP_AMOUNT_MAX - COIN_DROP_AMOUNT_MIN + 1) + COIN_DROP_AMOUNT_MIN, player:GetNumCoins())
            player:AddCoins(-greedCoins)
            for _ = 1, greedCoins do
                local spawnPos = Isaac.GetFreeNearPosition(player.Position, COIN_POSITION_STEP)
                local spawnVel = Vector(player.Position.X - spawnPos.X, player.Position.Y - spawnPos.Y):Resized(COIN_SPAWN_VECTOR_SIZE)
                local coin = Game():Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, spawnPos, spawnVel, nil, CoinSubType.COIN_PENNY, Game():GetSeeds():GetStageSeed(Game():GetLevel():GetStage()))
                coin:ToPickup().Timeout = COIN_TIMEOUT
            end
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, onPlayerDamage, EntityType.ENTITY_PLAYER)