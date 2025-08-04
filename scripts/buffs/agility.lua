local SPEED_TO_ADD = 0.3

---@param player EntityPlayer
local function onCacheEval(_, player)
    if Resouled:ActiveBuffPresent(Resouled.Buffs.AGILITY) then
        player.MoveSpeed = player.MoveSpeed + SPEED_TO_ADD
    end
end
Resouled:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, onCacheEval, CacheFlag.CACHE_SPEED)

local function postGameEnd()
    if Resouled:ActiveBuffPresent(Resouled.Buffs.AGILITY) then
        Resouled:RemoveActiveBuff(Resouled.Buffs.AGILITY)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_GAME_END, postGameEnd)

Resouled:AddBuffDescription(Resouled.Buffs.AGILITY, Resouled.EID:AutoIcons("Grants +0.3 speed"))