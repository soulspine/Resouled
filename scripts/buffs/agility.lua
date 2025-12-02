local SPEED_TO_ADD = 0.3

---@param player EntityPlayer
local function onCacheEval(_, player)
    if Resouled:ActiveBuffPresent(Resouled.Buffs.AGILITY) then
        player.MoveSpeed = player.MoveSpeed + SPEED_TO_ADD
    end
end
Resouled:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, onCacheEval, CacheFlag.CACHE_SPEED)

Resouled:AddBuffToRemoveOnRunEnd(Resouled.Buffs.AGILITY, true)