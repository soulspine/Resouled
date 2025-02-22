local SOULBOUND = Isaac.GetItemIdByName("Soulbound")

-- TODO FIX THIS BECAUSE ITS BROKEN FOR FORGOTTEN

if EID then
    EID:addCollectible(SOULBOUND, "Not implemented yet", "Soulbound")
end

local unlockTranslation =  {
    [PlayerType.PLAYER_ISAAC_B] = "taintedIsaacCheck",
    [PlayerType.PLAYER_MAGDALENE_B] = "taintedMaggyCheck",
    [PlayerType.PLAYER_CAIN_B] = "taintedCainCheck",
    [PlayerType.PLAYER_JUDAS_B] = "taintedJudasCheck",
    [PlayerType.PLAYER_BLUEBABY_B] = "taintedBlueBabyCheck",
    [PlayerType.PLAYER_EVE_B] = "taintedEveCheck",
    [PlayerType.PLAYER_SAMSON_B] = "taintedSamsonCheck",
    [PlayerType.PLAYER_AZAZEL_B] = "taintedAzazelCheck",
    [PlayerType.PLAYER_LAZARUS_B] = "taintedLazarusCheck",
    [PlayerType.PLAYER_EDEN_B] = "taintedEdenCheck",
    [PlayerType.PLAYER_THELOST_B] = "taintedLostCheck",
    [PlayerType.PLAYER_LAZARUS2_B] = "taintedLazarusCheck",
    [PlayerType.PLAYER_LILITH_B] = "taintedLilithCheck",
    [PlayerType.PLAYER_KEEPER_B] = "taintedKeeperCheck",
    [PlayerType.PLAYER_APOLLYON_B] = "taintedApollyonCheck",
    [PlayerType.PLAYER_THEFORGOTTEN_B] = "taintedForgottenCheck",
    [PlayerType.PLAYER_THESOUL_B] = "taintedForgottenCheck",
    [PlayerType.PLAYER_BETHANY_B] = "taintedBethanyCheck",
    [PlayerType.PLAYER_JACOB_B] = "taintedJacobCheck",
}

local characterTranslation = {
    [PlayerType.PLAYER_ISAAC] = PlayerType.PLAYER_ISAAC_B,
    [PlayerType.PLAYER_MAGDALENE] = PlayerType.PLAYER_MAGDALENE_B,
    [PlayerType.PLAYER_CAIN] = PlayerType.PLAYER_CAIN_B,
    [PlayerType.PLAYER_JUDAS] = PlayerType.PLAYER_JUDAS_B,
    [PlayerType.PLAYER_BLUEBABY] = PlayerType.PLAYER_BLUEBABY_B,
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
    [PlayerType.PLAYER_THEFORGOTTEN] = PlayerType.PLAYER_THEFORGOTTEN_B,
    [PlayerType.PLAYER_THESOUL] = PlayerType.PLAYER_THEFORGOTTEN_B,
    [PlayerType.PLAYER_BETHANY] = PlayerType.PLAYER_BETHANY_B,
    [PlayerType.PLAYER_JACOB] = PlayerType.PLAYER_JACOB_B,
    
    [PlayerType.PLAYER_ISAAC_B] = PlayerType.PLAYER_ISAAC,
    [PlayerType.PLAYER_MAGDALENE_B] = PlayerType.PLAYER_MAGDALENE,
    [PlayerType.PLAYER_CAIN_B] = PlayerType.PLAYER_CAIN,
    [PlayerType.PLAYER_JUDAS_B] = PlayerType.PLAYER_JUDAS,
    [PlayerType.PLAYER_BLUEBABY_B] = PlayerType.PLAYER_BLUEBABY,
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
    [PlayerType.PLAYER_THESOUL_B] = PlayerType.PLAYER_THEFORGOTTEN,
    [PlayerType.PLAYER_BETHANY_B] = PlayerType.PLAYER_BETHANY,
    [PlayerType.PLAYER_JACOB_B] = PlayerType.PLAYER_JACOB,
}

local function getSwappedCharacter(InputPlayerType)
    local itemConfig = Isaac.GetItemConfig()
    
    if InputPlayerType == PlayerType.PLAYER_BLACKJUDAS then
        local targetItemName = unlockTranslation[PlayerType.PLAYER_JUDAS_B]
        local targetItemID = Isaac.GetItemIdByName(targetItemName)
        local item = itemConfig:GetCollectible(targetItemID)
        if item:IsAvailable() then
            return PlayerType.PLAYER_JUDAS_B
        else
            return PlayerType.PLAYER_JUDAS
        end
    end

    print("InputPlayerType: " .. InputPlayerType)

    if InputPlayerType <= 20 then -- normal characters
        local taintedCharacterID = characterTranslation[InputPlayerType]

        if taintedCharacterID == nil then
            return nil
        end

        local targetItemName = unlockTranslation[taintedCharacterID]
        local targetItemID = Isaac.GetItemIdByName(targetItemName)
        local item = itemConfig:GetCollectible(targetItemID)

        print(item:IsAvailable())

        if item:IsAvailable() then
            return characterTranslation[InputPlayerType]
        else
            return nil
        end
    else
        return characterTranslation[InputPlayerType]
    end
end
function GetMaxItemID()
    local itemConfig = Isaac.GetItemConfig()
    local maxItemId = CollectibleType.NUM_COLLECTIBLES

    while true do
        if itemConfig:GetCollectible(maxItemId) == nil then
            break
        end
        maxItemId = maxItemId + 1
    end

    return maxItemId - 1
end

local function onDeath(_)
    local game = Game()
    local playerID = game:GetNumPlayers() - 1
    ::checkAnotherPlayer::
    if playerID < 0 -- no more players
    then
        return
    end
    local player = Isaac.GetPlayer(playerID)
    if not player:HasCollectible(SOULBOUND) or not player:IsDead() or player:WillPlayerRevive()
    then
        playerID = playerID - 1
        goto checkAnotherPlayer
    end
    
    
    local currentCharacter = player:GetPlayerType()
    local targetCharacter = getSwappedCharacter(currentCharacter)
    
    player:RemoveCollectible(SOULBOUND)
    SFXManager():Play(SoundEffect.SOUND_LAZARUS_FLIP_ALIVE, 1, 10)
    player:Revive()
    if targetCharacter ~= nil
    then
        if targetCharacter == PlayerType.PLAYER_THEFORGOTTEN --swapping from t forgotten
        then
            player = Isaac.GetPlayer(playerID+1)
            player:ChangePlayerType(PlayerType.PLAYER_THEFORGOTTEN)

            print("Lower PlayerID: " .. playerID+1 .. " Character: " .. player:GetPlayerType())
            print("Lower number of players" .. game:GetNumPlayers())
            
        else
            player:ChangePlayerType(targetCharacter)
        end
    end
end

    
Resouled:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, onDeath, EntityType.ENTITY_PLAYER)