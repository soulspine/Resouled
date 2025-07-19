local DAMAGE_PER_NOT_POSESSED_SOUL = 0.01

local function postNewRoom()
    if Resouled:RoomEventPresent(Resouled.RoomEvents.MIGHT_FOR_THE_MEEK) then
        ---@param player EntityPlayer
        Resouled.Iterators:IterateOverPlayers(function(player)
            player:AddCacheFlags(CacheFlag.CACHE_DAMAGE, true)
        end)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, postNewRoom)

---@param player EntityPlayer
local function onCacheEval(_, player)
    if Resouled:RoomEventPresent(Resouled.RoomEvents.MIGHT_FOR_THE_MEEK) then
        local damageMult = DAMAGE_PER_NOT_POSESSED_SOUL * (99 - Resouled:GetPossessedSoulsNum())
        player.Damage = player.Damage + (player.Damage * damageMult)
    end
end
Resouled:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, onCacheEval, CacheFlag.CACHE_DAMAGE)