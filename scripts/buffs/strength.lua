local DMG_TO_ADD = 1

---@param player EntityPlayer
local function onCacheEval(_, player)
    if Resouled:ActiveBuffPresent(Resouled.Buffs.STRENGTH) then
        player.Damage = player.Damage + DMG_TO_ADD
    end
end
Resouled:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, onCacheEval, CacheFlag.CACHE_DAMAGE)

local function postGameEnd()
    if Resouled:ActiveBuffPresent(Resouled.Buffs.STRENGTH) then
        Resouled:RemoveActiveBuff(Resouled.Buffs.STRENGTH)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_GAME_END, postGameEnd)

Resouled:AddBuffDescription(Resouled.Buffs.STRENGTH, "Grants +1 Damage")