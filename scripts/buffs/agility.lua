local SPEED_TO_ADD = 0.3

---@param player EntityPlayer
local function onCacheEval(_, player)
    player.MoveSpeed = player.MoveSpeed + SPEED_TO_ADD
end

Resouled:AddBuffCallbackConfig(Resouled.Buffs.AGILITY, {
    {
        CallbackID = ModCallbacks.MC_EVALUATE_CACHE,
        CallbackParams = CacheFlag.CACHE_SPEED,
        Function = onCacheEval
    }
})

Resouled:AddBuffToRemoveOnRunEnd(Resouled.Buffs.AGILITY, true)