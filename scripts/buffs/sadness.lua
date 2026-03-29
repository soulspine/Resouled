local TEARS_TO_ADD = 0.7

---@param player EntityPlayer
local function onCacheEval(_, player)
    Resouled:AddTears(player, TEARS_TO_ADD)
end

Resouled:AddBuffToRemoveOnRunEnd(Resouled.Buffs.SADNESS, true)

Resouled:AddBuffCallbackConfig(Resouled.Buffs.SADNESS, {
    {
        CallbackID = ModCallbacks.MC_EVALUATE_CACHE,
        Function = onCacheEval,
        CallbackParams = CacheFlag.CACHE_FIREDELAY
    }
})