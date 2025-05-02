local HP_GAIN_ROOM_COOLDOWN = 2
local HP_GAIN = 1

local EFFECT_OFFSET = Vector(0, -70)
local SFX_VOLUME = 0.7

local DEFAULT_ACTIVAION_VALUE = 2
local CHARACTER_ACTIVATION_VALUES = {
    [PlayerType.PLAYER_ISAAC] = 1,
    [PlayerType.PLAYER_ISAAC_B] = 1,
    [PlayerType.PLAYER_MAGDALENE] = 1,
    [PlayerType.PLAYER_MAGDALENE_B] = 1,
    [PlayerType.PLAYER_CAIN] = 1,
    [PlayerType.PLAYER_CAIN_B] = 1,
    [PlayerType.PLAYER_JUDAS] = 1,
    [PlayerType.PLAYER_JUDAS_B] = 1,
    [PlayerType.PLAYER_BLUEBABY] = 1,
    [PlayerType.PLAYER_BLUEBABY_B] = 1,
    [PlayerType.PLAYER_EVE] = 1,
    [PlayerType.PLAYER_EVE_B] = 1,
    [PlayerType.PLAYER_SAMSON] = 1,
    [PlayerType.PLAYER_SAMSON_B] = 1,
    [PlayerType.PLAYER_AZAZEL] = 1,
    [PlayerType.PLAYER_AZAZEL_B] = 1,
    [PlayerType.PLAYER_LAZARUS] = 1,
    [PlayerType.PLAYER_LAZARUS2] = 1, -- dead lazarus
    [PlayerType.PLAYER_LAZARUS_B] = 1,
    [PlayerType.PLAYER_LAZARUS2_B] = 1,
    [PlayerType.PLAYER_EDEN] = 1,
    [PlayerType.PLAYER_EDEN_B] = 1,
    [PlayerType.PLAYER_THELOST] = 999,
    [PlayerType.PLAYER_THELOST_B] = 999,
    [PlayerType.PLAYER_LILITH] = 1,
    [PlayerType.PLAYER_LILITH_B] = 1,
    [PlayerType.PLAYER_KEEPER] = 2,
    [PlayerType.PLAYER_KEEPER_B] = 2,
    [PlayerType.PLAYER_APOLLYON] = 1,
    [PlayerType.PLAYER_APOLLYON_B] = 1,
    [PlayerType.PLAYER_THEFORGOTTEN] = 1,
    [PlayerType.PLAYER_THESOUL] = 1,
    [PlayerType.PLAYER_THEFORGOTTEN_B] = 1,
    [PlayerType.PLAYER_THESOUL_B] = 999,
    [PlayerType.PLAYER_BETHANY] = 1,
    [PlayerType.PLAYER_BETHANY_B] = 1,
    [PlayerType.PLAYER_JACOB] = 1,
    [PlayerType.PLAYER_ESAU] = 1,
    [PlayerType.PLAYER_JACOB_B] = 1,
}

---@param player EntityPlayer
local function onPlayerUpdate(_, player)
    local activationValue = CHARACTER_ACTIVATION_VALUES[player:GetPlayerType()]
    if activationValue == nil then
        activationValue = DEFAULT_ACTIVAION_VALUE
    end
    local playerRunSave = SAVE_MANAGER.GetRunSave(player)

    if not Resouled:HasBlessing(player, Resouled.Blessings.Maggy) and Resouled:GetEffectiveHP(player) == activationValue then
        Resouled:GrantBlessing(player, Resouled.Blessings.Maggy)
        playerRunSave.Blessings.Maggy = HP_GAIN_ROOM_COOLDOWN
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, onPlayerUpdate)



---@param rng RNG
---@param position Vector
local function onRoomClear(_, rng, position)
    ---@param player EntityPlayer
    Resouled.Iterators:IterateOverPlayers(function(player)
        if Resouled:HasBlessing(player, Resouled.Blessings.Maggy) then
            player = player:ToPlayer():GetMainTwin()
            local playerRunSave = SAVE_MANAGER.GetRunSave(player)
            if Resouled:GetEffectiveHP(player) < player:GetHeartLimit() // 3 and playerRunSave.Blessings.Maggy == 0 then
                local validHeartSubTypes = {}

                local fullHearts = player:HasFullHearts()
                local preHP = Resouled:GetEffectiveHP(player)

                if Resouled:GetEffectiveRedHP(player) > 0 and not fullHearts then
                    table.insert(validHeartSubTypes, HeartSubType.HEART_FULL)
                end

                if Resouled:GetEffectiveSoulHP(player) > 0 then
                    table.insert(validHeartSubTypes, HeartSubType.HEART_SOUL)
                end

                if Resouled:GetEffectiveBlackHP(player) > 0 then
                    table.insert(validHeartSubTypes, HeartSubType.HEART_BLACK)
                end

                if player:GetRottenHearts() > 0 and not fullHearts then
                    table.insert(validHeartSubTypes, HeartSubType.HEART_ROTTEN)
                end

                if player:GetBoneHearts() > 0 then
                    table.insert(validHeartSubTypes, HeartSubType.HEART_BONE)
                end

                if player:GetEternalHearts() > 0 then
                    table.insert(validHeartSubTypes, HeartSubType.HEART_ETERNAL)
                end

                if #validHeartSubTypes ~= 0 then
                    local chosenHeart = validHeartSubTypes[rng:RandomInt(#validHeartSubTypes) + 1]
                
                    if chosenHeart == HeartSubType.HEART_FULL then
                        player:AddHearts(HP_GAIN)
                    elseif chosenHeart == HeartSubType.HEART_SOUL then
                        player:AddSoulHearts(HP_GAIN)
                    elseif chosenHeart == HeartSubType.HEART_BLACK then
                        player:AddBlackHearts(HP_GAIN)
                    elseif chosenHeart == HeartSubType.HEART_ROTTEN then
                        player:AddRottenHearts(HP_GAIN)
                    elseif chosenHeart == HeartSubType.HEART_BONE then
                        player:AddBoneHearts(HP_GAIN)
                    elseif chosenHeart == HeartSubType.HEART_ETERNAL then
                        player:AddEternalHearts(HP_GAIN)
                    end

                    print(chosenHeart)

                    if Resouled:GetEffectiveHP(player) > preHP then
                        Game():Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HEART, player.Position + EFFECT_OFFSET, Vector.Zero, player, 0, rng:GetSeed())
                        playerRunSave.Blessings.Maggy = HP_GAIN_ROOM_COOLDOWN
                        SFXManager():Play(SoundEffect.SOUND_VAMP_GULP, SFX_VOLUME)
                    end

                end
            else
                playerRunSave.Blessings.Maggy = math.max(0, playerRunSave.Blessings.Maggy - 1)
            end
        end
    end)
end
Resouled:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, onRoomClear)