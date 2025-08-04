local RANGE_TO_ADD = 3

---@param player EntityPlayer
local function onCacheEval(_, player)
    if Resouled:ActiveBuffPresent(Resouled.Buffs.SIGHT) then
        Resouled:AddRange(player, RANGE_TO_ADD)
    end
end
Resouled:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, onCacheEval, CacheFlag.CACHE_RANGE)

local function postGameEnd()
    if Resouled:ActiveBuffPresent(Resouled.Buffs.SIGHT) then
        Resouled:RemoveActiveBuff(Resouled.Buffs.SIGHT)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_GAME_END, postGameEnd)

Resouled:AddBuffDescription(Resouled.Buffs.SIGHT, Resouled.EID:AutoIcons("Grants +3 Range"))