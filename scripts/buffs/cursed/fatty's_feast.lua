local SPEED_PER_RED_HEART = 0.08

local function curseActive()
    return Resouled:ActiveBuffPresent(Resouled.Buffs.FATTYS_FEAST) or Resouled:IsSpecialSeedEffectActive(Resouled.SpecialSeedEffects.EverythingIsCursed)
end

---@param player EntityPlayer
local function cacheEval(_, player)
    if not curseActive() then return end
    player.MoveSpeed = player.MoveSpeed - player:GetMaxHearts()/2 * SPEED_PER_RED_HEART
end
Resouled:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, cacheEval, CacheFlag.CACHE_SPEED)

---@param player EntityPlayer
local function postPlayerInit(_, player)
    if not curseActive() then return end
    player:AddCacheFlags(CacheFlag.CACHE_SPEED, true)
end
Resouled:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, postPlayerInit)

Resouled:AddBuffToRemoveOnRunEnd(Resouled.Buffs.FATTYS_FEAST)