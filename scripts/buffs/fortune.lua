local LUCK_TO_ADD = 1

---@param player EntityPlayer
local function onCacheEval(_, player)
    if Resouled:ActiveBuffPresent(Resouled.Buffs.FORTUNE) then
        player.Luck = player.Luck + LUCK_TO_ADD
    end
end
Resouled:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, onCacheEval, CacheFlag.CACHE_LUCK)

local function postGameEnd()
    if Resouled:ActiveBuffPresent(Resouled.Buffs.FORTUNE) then
        Resouled:RemoveActiveBuff(Resouled.Buffs.FORTUNE)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_GAME_END, postGameEnd)