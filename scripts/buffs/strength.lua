local DMG_TO_ADD = 1

---@param player EntityPlayer
local function onCacheEval(_, player)
    player.Damage = player.Damage + DMG_TO_ADD
end

Resouled:AddBuffToRemoveOnRunEnd(Resouled.Buffs.STRENGTH, true)

Resouled:AddBuffCallbackConfig(Resouled.Buffs.STRENGTH, {
    {
        CallbackID = ModCallbacks.MC_EVALUATE_CACHE,
        Function = onCacheEval,
        CallbackParams = CacheFlag.CACHE_DAMAGE
    }
})