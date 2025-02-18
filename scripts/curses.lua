local customCurses = {}
local CUSTOM_CURSE_CHANCE = 1

local GREED_NAME = "Curse of Greed"
local CURSE_OF_GREED = Isaac.GetCurseIdByName(GREED_NAME)
customCurses[1 << CURSE_OF_GREED] = GREED_NAME

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

if EID then
    -- no idea how to make EID work with custom curses
    --EID:addCurse(CURSE_OF_GREED, "On hit, Isaac drops 1/4 of his coins as ", "Curse of Greed")
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
        Game():GetHUD():ShowFortuneText("Custom curse", customCurses[curses])
    end
    return curses
end
MOD:AddCallback(ModCallbacks.MC_POST_CURSE_EVAL, onCurseEval)



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
            local greedCoins = math.floor(coins / 4)
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
MOD:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, GREED_onPlayerDamage, EntityType.ENTITY_PLAYER)

--Samson's Blessing
local hasSamsonsBlessing = false
local dmg = 0
local blessingDmg = 0
local damageBonus = 0
local samsonsBlessingPower = 0

local function getPlayerDamageStats()
    local player = Isaac.GetPlayer()
    dmg = player.Damage
    dmg = dmg / dmg / dmg
    blessingDmg = dmg * 3.5
    damageBonus = player.Damage - blessingDmg
    print(blessingDmg)
end
MOD:AddCallback(ModCallbacks.MC_POST_UPDATE, getPlayerDamageStats)

local function samsonsBlessingPostDamageEffectsDamageFix()
    local player = Isaac.GetPlayer()
    if hasSamsonsBlessing == true then
        player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
        player.Damage = blessingDmg + 0.005 * samsonsBlessingPower
    end
end
MOD:AddCallback(ModCallbacks.MC_POST_UPDATE, samsonsBlessingPostDamageEffectsDamageFix)

local function samsonsBlessingMechanic(_, EntityNPC)
    local player = Isaac.GetPlayer()
    local rng = RNG()
    rng:SetSeed(Game():GetSeeds():GetStartSeed(), 0)
    local randNum = rng:RandomInt(1)
    print(randNum)
    if hasSamsonsBlessing == true and randNum == 0 then
        player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
        player.Damage = (blessingDmg + 0.005) + damageBonus
        samsonsBlessingPower = samsonsBlessingPower + 1
    end
end
MOD:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, samsonsBlessingMechanic)

local function grantSamsonsBlessing()
    local player = Isaac.GetPlayer()
    if player.Damage <= 0.75 and hasSamsonsBlessing == false then
        Game():GetHUD():ShowFortuneText("Custom blessing", "Samson's Blessing!")
        hasSamsonsBlessing = true
    end
end
MOD:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, grantSamsonsBlessing)

local function samsonsBlessingStatsResetOnNewRun()
    dmg = 0
    damageBonus = 0
    samsonsBlessingPower = 0
end
MOD:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, samsonsBlessingStatsResetOnNewRun)