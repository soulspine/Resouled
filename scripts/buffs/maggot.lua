function Resouled:GivePlayerRandomWormTrinket(player)
    player:AddTrinket(Resouled.Stats.WormTrinkets.Sorted[RNG(player.InitSeed):RandomInt(#Resouled.Stats.WormTrinkets.Sorted) + 1])
end

function Resouled:GiveAllPlayersRandomWormTrinkets()
    ---@param player EntityPlayer
    Resouled.Iterators:IterateOverPlayers(function(player)
        Resouled:GivePlayerRandomWormTrinket(player)
    end)
end

Resouled:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function()
    if not Resouled:ActiveBuffPresent(Resouled.Buffs.MAGGOT) then return end

    Resouled:GiveAllPlayersRandomWormTrinkets()

    Resouled:RemoveActiveBuff(Resouled.Buffs.MAGGOT)
end)