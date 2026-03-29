local RANGE_TO_ADD = 3

---@param player EntityPlayer
local function onCacheEval(_, player)
    Resouled:AddRange(player, RANGE_TO_ADD)
end

Resouled:AddBuffToRemoveOnRunEnd(Resouled.Buffs.SIGHT)

Resouled:AddBuffCallbackConfig(Resouled.Buffs.SIGHT, {
    {
        CallbackID = ModCallbacks.MC_EVALUATE_CACHE,
        Function = onCacheEval,
        CallbackParams = CacheFlag.CACHE_RANGE
    }
})