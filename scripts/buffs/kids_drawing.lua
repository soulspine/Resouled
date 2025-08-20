local function postGameStarted(_, isContinued)
    if Resouled:ActiveBuffPresent(Resouled.Buffs.KIDS_DRAWING) then
        ---@param player EntityPlayer
        Resouled.Iterators:IterateOverPlayers(function(player)
            player:AddSmeltedTrinket(TrinketType.TRINKET_KIDS_DRAWING)
        end)
        Resouled:RemoveActiveBuff(Resouled.Buffs.KIDS_DRAWING)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, postGameStarted)