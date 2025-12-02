local LUCK_TO_ADD = 1

---@param player EntityPlayer
local function onCacheEval(_, player)
    if Resouled:ActiveBuffPresent(Resouled.Buffs.FORTUNE) then
        player.Luck = player.Luck + LUCK_TO_ADD
    end
end
Resouled:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, onCacheEval, CacheFlag.CACHE_LUCK)

Resouled:AddBuffToRemoveOnRunEnd(Resouled.Buffs.FORTUNE, true)