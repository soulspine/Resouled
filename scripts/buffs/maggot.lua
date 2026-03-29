function Resouled:GivePlayerRandomWormTrinket(player)
    player:AddTrinket(Resouled.Stats.WormTrinkets.Sorted[RNG(player.InitSeed):RandomInt(#Resouled.Stats.WormTrinkets.Sorted) + 1])
end

function Resouled:GiveAllPlayersRandomWormTrinkets()
    ---@param player EntityPlayer
    Resouled.Iterators:IterateOverPlayers(function(player)
        Resouled:GivePlayerRandomWormTrinket(player)
    end)
end

local function postGameStarted()
    Resouled:GiveAllPlayersRandomWormTrinkets()

    Resouled:RemoveActiveBuff(Resouled.Buffs.MAGGOT)
    Resouled:RemoveCallback(ModCallbacks.MC_POST_GAME_STARTED, postGameStarted)
end

Resouled:AddBuffCallbackConfig(Resouled.Buffs.MAGGOT, {
    {
        CallbackID = ModCallbacks.MC_POST_GAME_STARTED,
        Function = postGameStarted
    }
})