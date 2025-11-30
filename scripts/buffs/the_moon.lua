local CONFIG = {
    PhaseDuration = 1800, -- in updates (30 updates = 1 second)
    StatUpdateInterval = 360,
    MaxGainMult = 0.5,
    MoonIconOffset = Vector(0, -56)
}

local INDICATOR_SPRITE = Resouled:CreateLoadedSprite("gfx_resouled/ui/moon_buff_ui.anm2", "Idle")

local PHASES = {
    New = 0,
    WaxingCrescent = 1,
    FirstQuarter = 2,
    WaxingGibbous = 3,
    Full = 4,
    WaningGibbous = 5,
    ThirdQuarter = 6,
    WaningCrescent = 7,
}

local render = false

---@return integer
local function getPhase()
    return math.floor(Game():GetFrameCount() / CONFIG.PhaseDuration) % 8
end

local function getPhaseProgression()
    return Game():GetFrameCount() % CONFIG.PhaseDuration / CONFIG.PhaseDuration
end

---@return number
local function getDarkSideLevel()
    return math.abs(1 - (((getPhase() + 4) % 8 + getPhaseProgression()) / 4))
end

---@return number
local function getBrightSideLevel()
    return 1 - getDarkSideLevel()
end

local function onUpdate()
    if not Resouled:ActiveBuffPresent(Resouled.Buffs.THE_MOON) then
        render = false
        return
    end
    render = true

    INDICATOR_SPRITE:SetFrame(getPhase())
    if Game():GetFrameCount() % CONFIG.StatUpdateInterval == 0 then
        Resouled.Iterators:IterateOverPlayers(function(player)
            ---@diagnostic disable-next-line: param-type-mismatch
            player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_FIREDELAY, true)
        end)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_UPDATE, onUpdate)

---@param player EntityPlayer
local function onRender(_, player)
    if not render then return end
    INDICATOR_SPRITE:Render(Isaac.WorldToScreen(player.Position + player.SpriteOffset + CONFIG.MoonIconOffset + player:GetFlyingOffset()))
end
Resouled:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, onRender)

---@param player EntityPlayer
---@param cacheFlag CacheFlag
local function onCacheEval(_, player, cacheFlag)
    if not Resouled:ActiveBuffPresent(Resouled.Buffs.THE_MOON) then return end
    if cacheFlag & CacheFlag.CACHE_FIREDELAY ~= 0 then
        Resouled.AccurateStats:AddTears(player, Resouled.AccurateStats:GetFireRate(player) * CONFIG.MaxGainMult * getBrightSideLevel()
        )
    end

    if cacheFlag & CacheFlag.CACHE_DAMAGE ~= 0 then
        player.Damage = player.Damage * (1 + CONFIG.MaxGainMult * getDarkSideLevel())
    end
end
Resouled:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, onCacheEval, CacheFlag.CACHE_FIREDELAY)
Resouled:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, onCacheEval, CacheFlag.CACHE_DAMAGE)

local function postGameEnd()
    if Resouled:ActiveBuffPresent(Resouled.Buffs.THE_MOON) then
        Resouled:RemoveActiveBuff(Resouled.Buffs.THE_MOON)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_GAME_END, postGameEnd)