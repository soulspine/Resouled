local multiplier = 1.1

---@param player EntityPlayer
---@param cacheFlag CacheFlag
Resouled:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player, cacheFlag)
    if not Resouled:ActiveBuffPresent(Resouled.Buffs.BIG_CAP) then return end

    if cacheFlag & CacheFlag.CACHE_SPEED ~= 0 then

        player.MoveSpeed = player.MoveSpeed * multiplier

    elseif cacheFlag & CacheFlag.CACHE_DAMAGE ~= 0 then
        
        player.Damage = player.Damage * multiplier

    elseif cacheFlag & CacheFlag.CACHE_FIREDELAY ~= 0 then

        Resouled:AddTears(player, Resouled.AccurateStats:GetFireRate(player) * (multiplier - 1))

    elseif cacheFlag & CacheFlag.CACHE_RANGE ~= 0 then

        Resouled:AddRange(player, player.TearRange/40 * (multiplier - 1))

    elseif cacheFlag & CacheFlag.CACHE_LUCK ~= 0 then

        player.Luck = player.Luck * multiplier

    elseif cacheFlag & CacheFlag.CACHE_SHOTSPEED ~= 0 then

        player.ShotSpeed = player.ShotSpeed * multiplier

    elseif cacheFlag & CacheFlag.CACHE_SIZE ~= 0 then

        player.SpriteScale = player.SpriteScale * Vector(multiplier, multiplier)

    end
end)

Resouled:AddBuffToRemoveOnRunEnd(Resouled.Buffs.BIG_CAP, true)