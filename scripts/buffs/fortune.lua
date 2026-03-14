local LUCK_TO_ADD = 1

---@param player EntityPlayer
local function onCacheEval(_, player)
    player.Luck = player.Luck + LUCK_TO_ADD
end

Resouled:AddBuffToRemoveOnRunEnd(Resouled.Buffs.FORTUNE, true)

Resouled:AddBuffCallbackConfig(Resouled.Buffs.FORTUNE, {
    {
        CallbackID = ModCallbacks.MC_EVALUATE_CACHE,
        Function = onCacheEval,
        CallbackParams = CacheFlag.CACHE_LUCK
    }
})