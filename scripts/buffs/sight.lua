local RANGE_TO_ADD = 3

---@param player EntityPlayer
local function onCacheEval(_, player)
    if Resouled:ActiveBuffPresent(Resouled.Buffs.SIGHT) then
        Resouled:AddRange(player, RANGE_TO_ADD)
    end
end
Resouled:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, onCacheEval, CacheFlag.CACHE_RANGE)

Resouled:AddBuffToRemoveOnRunEnd(Resouled.Buffs.SIGHT)