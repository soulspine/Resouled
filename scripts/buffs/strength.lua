local DMG_TO_ADD = 1

---@param player EntityPlayer
local function onCacheEval(_, player)
    if Resouled:ActiveBuffPresent(Resouled.Buffs.STRENGTH) then
        player.Damage = player.Damage + DMG_TO_ADD
    end
end
Resouled:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, onCacheEval, CacheFlag.CACHE_DAMAGE)

Resouled:AddBuffToRemoveOnRunEnd(Resouled.Buffs.STRENGTH, true)