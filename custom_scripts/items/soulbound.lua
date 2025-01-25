SOULBOUND = Isaac.GetItemIdByName("Soulbound")

print("Loaded Soulbound")

local characterTranslation = {
    [PlayerType.PLAYER_ISAAC] = PlayerType.PLAYER_ISAAC_B,
    [PlayerType.PLAYER_MAGDALENE] = PlayerType.PLAYER_MAGDALENE_B,
    [PlayerType.PLAYER_CAIN] = PlayerType.PLAYER_CAIN_B,
    [PlayerType.PLAYER_JUDAS] = PlayerType.PLAYER_JUDAS_B,
    [PlayerType.PLAYER_EVE] = PlayerType.PLAYER_EVE_B,
    [PlayerType.PLAYER_SAMSON] = PlayerType.PLAYER_SAMSON_B,
    [PlayerType.PLAYER_AZAZEL] = PlayerType.PLAYER_AZAZEL_B,
    [PlayerType.PLAYER_LAZARUS] = PlayerType.PLAYER_LAZARUS_B,
    [PlayerType.PLAYER_EDEN] = PlayerType.PLAYER_EDEN_B,
    [PlayerType.PLAYER_THELOST] = PlayerType.PLAYER_THELOST_B,
    [PlayerType.PLAYER_LAZARUS2] = PlayerType.PLAYER_LAZARUS2_B,
    [PlayerType.PLAYER_LILITH] = PlayerType.PLAYER_LILITH_B,
    [PlayerType.PLAYER_KEEPER] = PlayerType.PLAYER_KEEPER,
    [PlayerType.PLAYER_APOLLYON] = PlayerType.PLAYER_APOLLYON,
    [PlayerType.PLAYER_THEFORGOTTEN] = PlayerType.PLAYER_THEFORGOTTEN,
    [PlayerType.PLAYER_THESOUL] = PlayerType.PLAYER_THESOUL,
    [PlayerType.PLAYER_BETHANY] = PlayerType.PLAYER_BETHANY,
    [PlayerType.PLAYER_JACOB] = PlayerType.PLAYER_JACOB,
    [PlayerType.PLAYER_ESAU] = PlayerType.PLAYER_ESAU,

    [PlayerType.PLAYER_ISAAC_B] = PlayerType.PLAYER_ISAAC,
    [PlayerType.PLAYER_MAGDALENE_B] = PlayerType.PLAYER_MAGDALENE,
    [PlayerType.PLAYER_CAIN_B] = PlayerType.PLAYER_CAIN,
    [PlayerType.PLAYER_JUDAS_B] = PlayerType.PLAYER_JUDAS,
    [PlayerType.PLAYER_EVE_B] = PlayerType.PLAYER_EVE,
    [PlayerType.PLAYER_SAMSON_B] = PlayerType.PLAYER_SAMSON,
    [PlayerType.PLAYER_AZAZEL_B] = PlayerType.PLAYER_AZAZEL,
    [PlayerType.PLAYER_LAZARUS_B] = PlayerType.PLAYER_LAZARUS,
    [PlayerType.PLAYER_EDEN_B] = PlayerType.PLAYER_EDEN,
    [PlayerType.PLAYER_THELOST_B] = PlayerType.PLAYER_THELOST,
    [PlayerType.PLAYER_LAZARUS2_B] = PlayerType.PLAYER_LAZARUS2,
    [PlayerType.PLAYER_LILITH_B] = PlayerType.PLAYER_LILITH,
    [PlayerType.PLAYER_KEEPER_B] = PlayerType.PLAYER_KEEPER,
    [PlayerType.PLAYER_APOLLYON_B] = PlayerType.PLAYER_APOLLYON,
    [PlayerType.PLAYER_THEFORGOTTEN_B] = PlayerType.PLAYER_THEFORGOTTEN,
    [PlayerType.PLAYER_THESOUL_B] = PlayerType.PLAYER_THESOUL,
    [PlayerType.PLAYER_BETHANY_B] = PlayerType.PLAYER_BETHANY,
    [PlayerType.PLAYER_JACOB_B] = PlayerType.PLAYER_JACOB,

    [PlayerType.PLAYER_BLACKJUDAS] = PlayerType.PLAYER_JUDAS,
}

local function onDeath(_)
    local player = Isaac.GetPlayer()
    if not player:HasCollectible(SOULBOUND) or player:WillPlayerRevive()
    then
        return
    end

    player:RemoveCollectible(SOULBOUND)
    player:AnimateSad()
    SFXManager():Play(SoundEffect.SOUND_LAZARUS_FLIP_ALIVE, 1, 10)
    player:Revive()

    --local x = Isaac.GetItemIdByName("unlockCheck474")


    --local configcard = Isaac.GetItemConfig()
    --local x = configcard:GetCollectible(CollectibleType.COLLECTIBLE_DEATH_CERTIFICATE)

    --for k,v in pairs(x) do
    --    print(k,v)
    --end
    --pobrac mod do check unlock i zmeinic na no eden
    --configcard:AchievementID(GetItemIdByName("Death Certificate"))

    local whoami = characterTranslation[player:GetPlayerType()]
    player:ChangePlayerType(whoami)
end 
MOD:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, onDeath)