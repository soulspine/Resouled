local HP_GAIN_ROOM_COOLDOWN = 2
local HP_GAIN = 1

local EFFECT_OFFSET = Vector(0, -60)
local SFX_VOLUME = 0.7

---@param player EntityPlayer
local function onPlayerUpdate(_, player)
    if not Resouled:HasBlessing(player, Resouled.Blessings.MAGGY) and Resouled:GetEffectiveHP(player) == 1 then
        local playerRunSave = SAVE_MANAGER.GetRunSave(player)
        Resouled:GrantBlessing(player, Resouled.Blessings.MAGGY)
        playerRunSave.Blessings.Maggy = HP_GAIN_ROOM_COOLDOWN
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, onPlayerUpdate)



---@param rng RNG
---@param position Vector
local function onRoomClear(_, rng, position)
    ---@param player EntityPlayer
    Resouled:IterateOverPlayers(function(player, playerId)
        if Resouled:HasBlessing(player, Resouled.Blessings.MAGGY) then
            local playerRunSave = SAVE_MANAGER.GetRunSave(player)
            if playerRunSave.Blessings.Maggy == 0 then
                local validHeartSubTypes = {}

                local fullHearts = player:HasFullHearts()

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

                    Game():Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HEART, player.Position + EFFECT_OFFSET, Vector.Zero, player, 0, rng:GetSeed())
                    playerRunSave.Blessings.Maggy = HP_GAIN_ROOM_COOLDOWN
                    SFXManager():Play(SoundEffect.SOUND_HOLY, SFX_VOLUME)

                end
            else
                playerRunSave.Blessings.Maggy = playerRunSave.Blessings.Maggy - 1
            end
        end
    end)
end
Resouled:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, onRoomClear)