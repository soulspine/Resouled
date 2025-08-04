local function postGameStarted()
    if Resouled:ActiveBuffPresent(Resouled.Buffs.CROSS) then
        ---@param player EntityPlayer
        Resouled.Iterators:IterateOverPlayers(function(player)
            if player:GetPlayerType() ~= PlayerType.PLAYER_THELOST and player:GetPlayerType() ~= PlayerType.PLAYER_THELOST_B then
                player:AddEternalHearts(1)
            elseif player:GetPlayerType() == PlayerType.PLAYER_THELOST or player:GetPlayerType() == PlayerType.PLAYER_THELOST_B then
                player:AddCard(Card.CARD_HOLY)
            end
        end)
        Resouled:RemoveActiveBuff(Resouled.Buffs.CROSS)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, postGameStarted)

local e = Resouled.EID

Resouled:AddBuffDescription(Resouled.Buffs.CROSS, e:AutoIcons("You spawn with an eternal heart#"..e:FadePurple("Holy card for lost and tainted lost")))