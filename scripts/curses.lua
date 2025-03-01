local customCurses = {}
local CUSTOM_CURSE_CHANCE = 1

local GREED_NAME = "Curse of Greed"
local CURSE_OF_GREED = Isaac.GetCurseIdByName(GREED_NAME)
customCurses[1 << CURSE_OF_GREED] = GREED_NAME

local PAIN_NAME = "Curse of Pain"
local CURSE_OF_PAIN = Isaac.GetCurseIdByName(PAIN_NAME)
customCurses[1 << CURSE_OF_PAIN] = PAIN_NAME

local GREED_COIN_DROP_AMOUNT_MIN = 4
local GREED_COIN_DROP_AMOUNT_MAX = 6
local GREED_COIN_TIMEOUT = 60 -- frames
local GREED_POSITION_STEP = 10
local GREED_COIN_VECTOR_SIZE = 2

---@param rng RNG
local function rollCurse(rng)
    local curses = {}
    for i, _ in pairs(customCurses) do
        table.insert(curses, i)
    end
    return curses[rng:RandomInt(#curses) + 1]
end

local function cursePresent(curse)
    local curseShifted = 1 << curse
    return Game():GetLevel():GetCurses() & curseShifted == curseShifted
end


---@param curses integer
local function onCurseEval(_, curses)
    local currentStage = Game():GetLevel():GetStage()
    local stageSeed = Game():GetSeeds():GetStageSeed(currentStage)
    local rng = RNG()
    rng:SetSeed(stageSeed, 0)
    if curses == 0 and rng:RandomFloat() < CUSTOM_CURSE_CHANCE then
        curses = rollCurse(rng)
        -- TODO: MAKE BETTER CURSE DISPLAY
        local level = Game():GetLevel()
        --Game():GetHUD():ShowFortuneText("Custom curse", customCurses[curse])
        level:AddCurse(curses, false)
        end
    return curses
end
Resouled:AddCallback(ModCallbacks.MC_POST_CURSE_EVAL, onCurseEval)



---@param entity Entity
---@param amount number
---@param flags integer
---@param source EntityRef
---@param countdown integer
local function GREED_onPlayerDamage(_, entity, amount, flags, source, countdown)
    local player = entity:ToPlayer()
    if player and cursePresent(CURSE_OF_GREED) and flags & DamageFlag.DAMAGE_FAKE == 0 then
        local coins = player:GetNumCoins()
        if coins > 0 then
            local rng = player:GetDropRNG()
            local greedCoins = math.min(rng:RandomInt(GREED_COIN_DROP_AMOUNT_MAX - GREED_COIN_DROP_AMOUNT_MIN + 1) + GREED_COIN_DROP_AMOUNT_MIN, player:GetNumCoins())
            player:AddCoins(-greedCoins)
            for _ = 1, greedCoins do
                local spawnPos = Isaac.GetFreeNearPosition(player.Position, GREED_POSITION_STEP)
                local spawnVel = Vector(player.Position.X - spawnPos.X, player.Position.Y - spawnPos.Y):Resized(GREED_COIN_VECTOR_SIZE)
                local coin = Game():Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, spawnPos, spawnVel, nil, CoinSubType.COIN_PENNY, Game():GetSeeds():GetStageSeed(Game():GetLevel():GetStage()))
                coin:ToPickup().Timeout = GREED_COIN_TIMEOUT
            end
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, GREED_onPlayerDamage, EntityType.ENTITY_PLAYER)

---@param entity Entity
---@param amount number
---@param flags integer
---@param source EntityRef
---@param countdown integer
local function PAIN_onPlayerHit(_, entity, amount, flags, source, countdown)
    local player = entity:ToPlayer()
    if not entity:ToPlayer():HasCollectible(CollectibleType.COLLECTIBLE_WAFER) then
        if player and cursePresent(CURSE_OF_PAIN) and flags & DamageFlag.DAMAGE_FAKE == 0 then
            if Resouled:GetEffectiveBlackHP(player) > 0 then
                player:AddBlackHearts(-1)
            elseif Resouled:GetEffectiveBlackHP(player) <= 0 and Resouled:GetEffectiveSoulHP(player) > 0 then
                player:AddSoulHearts(-1)
            elseif Resouled:GetEffectiveBlackHP(player) <= 0 and Resouled:GetEffectiveSoulHP(player) <= 0 and Resouled:GetEffectiveRedHP(player) > 0 then
                player:AddHearts(-1)
            end
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, PAIN_onPlayerHit, EntityType.ENTITY_PLAYER)