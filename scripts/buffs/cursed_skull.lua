local CURSES_BLACKLIST = {
    [4] = true, -- curse of the cursed
    [7] = true, -- curse of giant
}

local function postGameStart()
    if Resouled:ActiveBuffPresent(Resouled.Buffs.CURSED_SKULL) then
        local validCurses = {}
        for i = 1, XMLData.GetNumEntries(XMLNode.CURSE) do
            if not CURSES_BLACKLIST[i] then
                table.insert(validCurses, 1<<i-1)
            end
        end
        local randomNum = RNG(Game():GetRoom():GetSpawnSeed()):RandomInt(#validCurses) + 1
        local curse = validCurses[randomNum]
        Game():GetLevel():AddCurse(curse, false)
        local player = Isaac.GetPlayer()
        player:AddCoins(1)
        player:AddBombs(1)
        player:AddKeys(1)
        if PlayerManager.AnyoneIsPlayerType(PlayerType.PLAYER_BLUEBABY_B) then
            player:AddPoopMana(1)
        end
        Game():Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, Game():GetRoom():GetCenterPos(), Vector.Zero, nil, 0, Game():GetRoom():GetSpawnSeed())
        Resouled:RemoveActiveBuff(Resouled.Buffs.CURSED_SKULL)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, postGameStart)

Resouled:AddBuffDescription(Resouled.Buffs.CURSED_SKULL, Resouled.EID:AutoIcons("You're guaranteed to get a curse first floor, but you will gain one of each pickup and a random trinket spawns"))