local STRAWBERRY = Isaac.GetItemIdByName("Strawberry")

local POSITION_OFFSET = Vector(0,-30)
local CONSUME_SPEED_THRESHOLD = 0.01
local LUCK_GAIN_PAST_1UP = 5
local NEW_RUN_INVINCIBILITY_FRAMES = 120

local CONSUME_EARLY_SCORE_END_FRAME = 4

if EID then
    EID:addCollectible(STRAWBERRY, "Not implemented yet", "Strawberry")
end

local STRAWBERRY_VARIANT = Isaac.GetEntityVariantByName("Red Strawberry Pickup")
local sfx = SFXManager()

local SFX_KEY_GET = Isaac.GetSoundIdByName("Key Get")

local SFX_STRAWBERRY_RED_TOUCH = Isaac.GetSoundIdByName("Red Strawberry Touch")
local SFX_STRAWBERRY_RED_PULSE = Isaac.GetSoundIdByName("Red Strawberry Pulse")
local SFX_STRAWBERRY_RED_1000 = Isaac.GetSoundIdByName("Red Strawberry 1000")
local SFX_STRAWBERRY_RED_2000 = Isaac.GetSoundIdByName("Red Strawberry 2000")
local SFX_STRAWBERRY_RED_3000 = Isaac.GetSoundIdByName("Red Strawberry 3000")
local SFX_STRAWBERRY_RED_4000 = Isaac.GetSoundIdByName("Red Strawberry 4000")
local SFX_STRAWBERRY_RED_5000 = Isaac.GetSoundIdByName("Red Strawberry 5000")
local SFX_STRAWBERRY_RED_1UP = Isaac.GetSoundIdByName("Red Strawberry 1UP")

local SFX_STRAWBERRY_BLUE_TOUCH = Isaac.GetSoundIdByName("Blue Strawberry Touch")
local SFX_STRAWBERRY_BLUE_PULSE = Isaac.GetSoundIdByName("Blue Strawberry Pulse")
local SFX_STRAWBERRY_BLUE_1000 = Isaac.GetSoundIdByName("Blue Strawberry 1000")
local SFX_STRAWBERRY_BLUE_2000 = Isaac.GetSoundIdByName("Blue Strawberry 2000")
local SFX_STRAWBERRY_BLUE_3000 = Isaac.GetSoundIdByName("Blue Strawberry 3000")
local SFX_STRAWBERRY_BLUE_4000 = Isaac.GetSoundIdByName("Blue Strawberry 4000")
local SFX_STRAWBERRY_BLUE_5000 = Isaac.GetSoundIdByName("Blue Strawberry 5000")
local SFX_STRAWBERRY_BLUE_1UP = Isaac.GetSoundIdByName("Blue Strawberry 1UP")

local VOLUME_KEY_GET = 0.7
local VOLUME_STRAWBERRY_TOUCH = 0.7
local VOLUME_STRAWBERRY_PULSE = 0.7
local VOLUME_STRAWBERRY_SCORE = 0.7

local ANIMATION_IDLE = "Idle"
local ANIMATION_CONSUME = "Consume"
local ANIMATION_1UP_LOOP = "1UP LOOP"
local ANIMATION_1UP_END = "1UP END"
local ANIMATION_NONE = "None"
local THRESHOLD_1UP = 5
local FRAME_STRAWBERRY_PULSE = 60

---@param pickup EntityPickup
local function onBerryPickupInit(_, pickup)
    local sprite = pickup:GetSprite()
    sprite:Play(ANIMATION_IDLE, true)
    sprite:SetFrame(math.random(0,15))
    pickup.PositionOffset = POSITION_OFFSET
    pickup.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
end    
MOD:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, onBerryPickupInit, STRAWBERRY_VARIANT)



---@param pickup EntityPickup
---@param collider Entity
---@param low boolean
local function onBerryPickupCollision(_, pickup, collider, low)
    --print(collider.Type)
    if collider.Type == EntityType.ENTITY_PLAYER then
        local player = collider:ToPlayer()

        if player == nil then
            return
        end

        if player:HasCollectible(STRAWBERRY) then
            pickup:Remove()
            local touchSFX
            if pickup.SubType == 0 then
                touchSFX = SFX_STRAWBERRY_RED_TOUCH
            elseif pickup.SubType == 1 then
                touchSFX = SFX_STRAWBERRY_BLUE_TOUCH
            end
            sfx:Play(touchSFX, VOLUME_STRAWBERRY_TOUCH)
            Isaac.Spawn(EntityType.ENTITY_FAMILIAR, STRAWBERRY_VARIANT, pickup.SubType, pickup.Position, Vector.Zero, player)
        end
        return true
    end
end
MOD:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, onBerryPickupCollision, STRAWBERRY_VARIANT)


---@param pickup EntityPickup
local function onBerryPickupUpdate(_, pickup)
    local sprite = pickup:GetSprite()
    if sprite:IsPlaying(ANIMATION_IDLE) then
        if sprite:GetFrame() == FRAME_STRAWBERRY_PULSE then
            local pulseSfx
            if pickup.SubType == 0 then
                pulseSfx = SFX_STRAWBERRY_RED_PULSE
            elseif pickup.SubType == 1 then
                pulseSfx = SFX_STRAWBERRY_BLUE_PULSE
            end

            sfx:Play(pulseSfx, VOLUME_STRAWBERRY_PULSE)
        end    
    end    
end    
MOD:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, onBerryPickupUpdate, STRAWBERRY_VARIANT)



---@param familiar EntityFamiliar
local function onBerryFamiliarInit(_, familiar)
    familiar.PositionOffset = POSITION_OFFSET
    familiar:GetSprite():SetFrame(math.random(0,15))
    familiar:AddToFollowers()
    
    local player = familiar.Player:ToPlayer()
    if player == nil then
        return
    end    

    local playerRunSave = SAVE_MANAGER.GetRunSave(player)

    table.insert(playerRunSave.Strawberry.Berries, EntityPtr(familiar))
end    
MOD:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, onBerryFamiliarInit, STRAWBERRY_VARIANT)



---@param familiar EntityFamiliar
local function onBerryFamiliarUpdate(_, familiar)
    --print("Familiar update")
    local sprite = familiar:GetSprite()
    if sprite:IsPlaying(ANIMATION_IDLE) then
        if sprite:GetFrame() == FRAME_STRAWBERRY_PULSE then
            local pulseSfx
            if familiar.SubType == 0 then
                pulseSfx = SFX_STRAWBERRY_RED_PULSE
            elseif familiar.SubType == 1 then
                pulseSfx = SFX_STRAWBERRY_BLUE_PULSE
            end

            sfx:Play(pulseSfx, VOLUME_STRAWBERRY_PULSE)
        end    
    end    
    familiar:FollowParent()
    --print(#activeBerries[GetPtrHash(familiar.Player)])
end    
MOD:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, onBerryFamiliarUpdate, STRAWBERRY_VARIANT)



local berryInvincibilityFramesLeft = NEW_RUN_INVINCIBILITY_FRAMES

---@param player EntityPlayer
---@param playerID any
local function onUpdate(player, playerID)

    if player:HasCollectible(STRAWBERRY) then
        local playerRunSave = SAVE_MANAGER.GetRunSave(player)

        if playerRunSave.Strawberry == nil then
            playerRunSave.Strawberry = {
                Streak = 0,
                IsConsuming = false,
                Berries = {},
                Luck = 0
            }
        end

        if berryInvincibilityFramesLeft > 0 then
            berryInvincibilityFramesLeft = berryInvincibilityFramesLeft - 1
            return
        end

        local berries = playerRunSave.Strawberry.Berries
        local streak = playerRunSave.Strawberry.Streak

        --print("Streak: " .. streak)

        local scoreAnimation = ""

        if (#berries > 0 and player:GetVelocityBeforeUpdate():Length() < CONSUME_SPEED_THRESHOLD) or playerRunSave.Strawberry.IsConsuming then
            ---@type EntityFamiliar
            local firstBerry = berries[1].Ref:ToFamiliar()
            if firstBerry == nil then
                return
            end

            local sprite = firstBerry:GetSprite()

            playerRunSave.Strawberry.IsConsuming = true

            if sprite:IsPlaying(ANIMATION_1UP_END) then
                return
            elseif sprite:IsFinished(ANIMATION_1UP_END) then
                goto noScore
            end

            -- play consume if in idle
            if sprite:IsPlaying(ANIMATION_IDLE) then
                sprite:Play(ANIMATION_CONSUME, true)

                local scoreSFX = nil

                if firstBerry.SubType == 0 then
                    if streak == 0 then
                        scoreSFX = SFX_STRAWBERRY_RED_1000
                    elseif streak == 1 then
                        scoreSFX = SFX_STRAWBERRY_RED_2000
                    elseif streak == 2 then
                        scoreSFX = SFX_STRAWBERRY_RED_3000
                    elseif streak == 3 then
                        scoreSFX = SFX_STRAWBERRY_RED_4000
                    elseif streak == 4 then
                        scoreSFX = SFX_STRAWBERRY_RED_5000
                    elseif streak == 5 then
                            scoreSFX = SFX_STRAWBERRY_RED_1UP
                    end
                elseif firstBerry.SubType == 1 then
                    if streak == 0 then
                        scoreSFX = SFX_STRAWBERRY_BLUE_1000
                    elseif streak == 1 then
                        scoreSFX = SFX_STRAWBERRY_BLUE_2000
                    elseif streak == 2 then
                        scoreSFX = SFX_STRAWBERRY_BLUE_3000
                    elseif streak == 3 then
                        scoreSFX = SFX_STRAWBERRY_BLUE_4000
                    elseif streak == 4 then
                        scoreSFX = SFX_STRAWBERRY_BLUE_5000
                    elseif streak == 5 then
                        scoreSFX = SFX_STRAWBERRY_BLUE_1UP
                    end
                end
                
                if scoreSFX ~= nil then                
                    sfx:Play(scoreSFX, VOLUME_STRAWBERRY_SCORE)
                end

                return
            end

            -- skip if consume is playing
            if sprite:IsPlaying(ANIMATION_CONSUME) then
                return
            end

            -- decide what to do based on streak
            if streak < THRESHOLD_1UP then
                scoreAnimation = tostring(1000*(streak+1))
            elseif streak == THRESHOLD_1UP then
                if #berries == 1 then
                    scoreAnimation = ANIMATION_1UP_END
                else
                    scoreAnimation = ANIMATION_1UP_LOOP
                end

                player:AnimateCollectible(CollectibleType.COLLECTIBLE_1UP)
                player:AddCollectible(CollectibleType.COLLECTIBLE_1UP)

            else -- berryStreak > THRESHOLD_1UP
                -- this can be the 1UP berry at the end
                --print(#playerBerries)
                if #berries == 1 then
                    sprite:Play(ANIMATION_1UP_END, true)
                    return
                else
                    scoreAnimation = ANIMATION_NONE
                end
            end

            --print(scoreAnimation)

            -- do not animate score if there is 1up played already
            if scoreAnimation == ANIMATION_NONE then
                goto noScore
            end

            if sprite:IsFinished(ANIMATION_CONSUME) then
                sprite:Play(scoreAnimation, true)
            end

            -- special case for 1up loop
            if scoreAnimation ~= ANIMATION_1UP_LOOP and sprite:IsPlaying(scoreAnimation) then
                if #berries == 1 then
                    return
                elseif sprite:GetFrame() > CONSUME_EARLY_SCORE_END_FRAME then
                    sprite:Stop()
                else return
                end
            end

            ::noScore::

            -- remove first berry
            if scoreAnimation == ANIMATION_1UP_LOOP then
                --print("Insert 1up at the end")
                table.insert(berries, EntityPtr(firstBerry))
            else
                firstBerry:Remove()
            end
            table.remove(berries, 1)

            --print("Player berries: " .. #berries .. " " .. "Streak: " .. streak)

            -- update streak
            if #berries == 0 then
                
                MOD:SpawnItemOfQuality(math.min(streak,4), player:GetCollectibleRNG(STRAWBERRY), firstBerry.Position)
                sfx:Play(SFX_KEY_GET, VOLUME_KEY_GET)

                playerRunSave.Strawberry.Streak = 0
                playerRunSave.Strawberry.IsConsuming = false
            else
                --give luck up for each streak over threshold
                playerRunSave.Strawberry.Streak = streak + 1
                if streak >= THRESHOLD_1UP then
                    playerRunSave.Strawberry.Luck = playerRunSave.Strawberry.Luck + LUCK_GAIN_PAST_1UP
                    player:AddCacheFlags(CacheFlag.CACHE_LUCK)
                    player:EvaluateItems()
                end
            end
        end
    end
end
MOD:AddCallback(ModCallbacks.MC_POST_UPDATE, function() IterateOverPlayers(onUpdate) end)


---@param player EntityPlayer
---@param cacheFlag CacheFlag
local function onCacheEval(_, player, cacheFlag)
    if cacheFlag == CacheFlag.CACHE_LUCK then
        if player:HasCollectible(STRAWBERRY) then
            local playerRunSave = SAVE_MANAGER.GetRunSave(player)
            player.Luck = player.Luck + playerRunSave.Strawberry.Luck
        end
    end
end
MOD:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, onCacheEval)



local function onGameStart()
    -- give berries invulnerability so player doesnt instantly despawn them
    berryInvincibilityFramesLeft = NEW_RUN_INVINCIBILITY_FRAMES
end
MOD:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, onGameStart)


