local TEARS_TO_ADD = 0.7

---@param player EntityPlayer
local function onCacheEval(_, player)
    if Resouled:ActiveBuffPresent(Resouled.Buffs.SADNESS) then
        Resouled:AddTears(player, TEARS_TO_ADD)
    end
end
Resouled:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, onCacheEval, CacheFlag.CACHE_FIREDELAY)

local function postGameEnd()
    if Resouled:ActiveBuffPresent(Resouled.Buffs.SADNESS) then
        Resouled:RemoveActiveBuff(Resouled.Buffs.SADNESS)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_GAME_END, postGameEnd)