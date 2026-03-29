local function postGameStarted()
    ---@param player EntityPlayer
    Resouled.Iterators:IterateOverPlayers(function(player)
        player:AddSmeltedTrinket(TrinketType.TRINKET_KIDS_DRAWING)
    end)
    Resouled:RemoveActiveBuff(Resouled.Buffs.KIDS_DRAWING)
    Resouled:RemoveCallback(ModCallbacks.MC_POST_GAME_STARTED, postGameStarted)
end

Resouled:AddBuffCallbackConfig(Resouled.Buffs.KIDS_DRAWING, {
    {
        CallbackID = ModCallbacks.MC_POST_GAME_STARTED,
        Function = postGameStarted
    }
})