local CURSES_BLACKLIST = {
    [4] = true, -- curse of the cursed
    [7] = true, -- curse of giant
}

local function postGameStart()
    local room = Resouled.Game:GetRoom()
    local validCurses = {}
    for i = 1, XMLData.GetNumEntries(XMLNode.CURSE) do
        if not CURSES_BLACKLIST[i] then
            table.insert(validCurses, 1<<i-1)
        end
    end
    local randomNum = RNG(room:GetSpawnSeed()):RandomInt(#validCurses) + 1
    local curse = validCurses[randomNum]
    Resouled.Game:GetLevel():AddCurse(curse, false)
    local player = Isaac.GetPlayer()
    player:AddCoins(1)
    player:AddBombs(1)
    player:AddKeys(1)
    if PlayerManager.AnyoneIsPlayerType(PlayerType.PLAYER_BLUEBABY_B) then
        player:AddPoopMana(1)
    end
    Resouled.Game:Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, room:GetCenterPos(), Vector.Zero, nil, 0, room:GetSpawnSeed())
    Resouled:RemoveActiveBuff(Resouled.Buffs.CURSED_SKULL)
end

Resouled:AddBuffCallbackConfig(Resouled.Buffs.CURSED_SKULL, {
    {
        CallbackID = ModCallbacks.MC_POST_GAME_STARTED,
        Function = postGameStart
    }
})