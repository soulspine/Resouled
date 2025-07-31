local function postGameEnd()
    ---@param player EntityPlayer
    Resouled.Iterators:IterateOverPlayers(function(player)
        local startingStats = Resouled:GetPlayerStartingStats(player)

        if startingStats.Damage > player.Damage then
            Resouled.AfterlifeShop:AddSpecialBuffToSpawn(Resouled.Buffs.STRENGTH)
        end

        if startingStats.Tears < player.MaxFireDelay then
            Resouled.AfterlifeShop:AddSpecialBuffToSpawn(Resouled.Buffs.SADNESS)
        end

        if startingStats.Speed > player.MoveSpeed then
            Resouled.AfterlifeShop:AddSpecialBuffToSpawn(Resouled.Buffs.AGILITY)
        end

        if startingStats.Luck > player.Luck then
            Resouled.AfterlifeShop:AddSpecialBuffToSpawn(Resouled.Buffs.FORTUNE)
        end

        if startingStats.Range > player.TearRange then
            Resouled.AfterlifeShop:AddSpecialBuffToSpawn(Resouled.Buffs.SIGHT)
        end
    end)
end
Resouled:AddCallback(ModCallbacks.MC_POST_GAME_END, postGameEnd)