local STRAWBERRY = Isaac.GetItemIdByName("Strawberry")

local POSITION_OFFSET = Vector(0,-30)
local CONSUME_SPEED_THRESHOLD = 0.01
local CONSUME_FRAME_THRESHOLD = 20
local LUCK_GAIN_PAST_1UP = 5
local NEW_RUN_INVINCIBILITY_FRAMES = 120
local ROOM_ENTER_SPAWN_CHANCE = 10 -- in %

local CONSUME_EARLY_SCORE_END_FRAME = 4

if EID then
    EID:addCollectible(STRAWBERRY, "While held, Isaac can collect strawberries that will follow him.#" .. ROOM_ENTER_SPAWN_CHANCE .. "% chance to spawn a Strawberry in every room.#On use turns pedestal items into Strawberries.#Upon entering a new floor, spawns a Golden Berry that disappears when Isaac takes any damage.#{{Warning}} Standing still will make berries count up score. The higher the score, the higher quality item will spawn.", "Strawberry")
end

local STRAWBERRY_VARIANT = Isaac.GetEntityVariantByName("Red Strawberry Pickup")
local sfx = SFXManager()

---@class StrawberrySubtype
local STRAWBERRY_SUBTYPE = {
    RED = 0,
    BLUE = 1,
    GOLDEN = 2
}

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

local SFX_STRAWBERRY_GOLDEN_1000 = Isaac.GetSoundIdByName("Golden Strawberry 1000")
local SFX_STRAWBERRY_GOLDEN_2000 = Isaac.GetSoundIdByName("Golden Strawberry 2000")
local SFX_STRAWBERRY_GOLDEN_3000 = Isaac.GetSoundIdByName("Golden Strawberry 3000")
local SFX_STRAWBERRY_GOLDEN_4000 = Isaac.GetSoundIdByName("Golden Strawberry 4000")
local SFX_STRAWBERRY_GOLDEN_5000 = Isaac.GetSoundIdByName("Golden Strawberry 5000")
local SFX_STRAWBERRY_GOLDEN_1UP = Isaac.GetSoundIdByName("Golden Strawberry 1UP")

local SFX_UI_POSTGAME_STRAWBERRY_TOTAL = Isaac.GetSoundIdByName("UI Postgame Strawberry Total")
local SFX_UI_POSTGAME_STRAWBERRY_COUNT = Isaac.GetSoundIdByName("UI Postgame Strawberry Count")
local SFX_UI_GAME_INCREMENT_STRAWBERRY = Isaac.GetSoundIdByName("UI Game Increment Strawberry")
local SFX_FUSEBOX_HIT_2_2D = Isaac.GetSoundIdByName("Fusebox Hit 2 2D")

local VOLUME_KEY_GET = 0.7
local VOLUME_STRAWBERRY_TOUCH = 0.7
local VOLUME_STRAWBERRY_PULSE = 0.7
local VOLUME_STRAWBERRY_SCORE = 0.7
local VOLUME_ACTIVE_USE = 0.7
local LOSE_GOLDEN_BERRY_VOLUME = 0.7

local ANIMATION_IDLE = "Idle"
local ANIMATION_CONSUME = "Consume"
local ANIMATION_1UP_LOOP = "1UP LOOP"
local ANIMATION_1UP_END = "1UP END"
local ANIMATION_NONE = "None"
local THRESHOLD_1UP = 5
local FRAME_STRAWBERRY_PULSE = 60
local FRAME_STRAWBERRY_GOLDEN_PULSE = 66

---@param subtype integer
---@param position Vector
---@param player EntityPlayer
local function spawnBerryFamiliar(subtype, position, player)
    Game():Spawn(EntityType.ENTITY_FAMILIAR, STRAWBERRY_VARIANT, position, Vector.Zero, player, subtype, player:GetCollectibleRNG(STRAWBERRY):GetSeed())
end



---@param subtype integer
---@param position Vector
---@param seed integer
local function spawnBerryPickup(subtype, position, seed)
    Game():Spawn(EntityType.ENTITY_PICKUP, STRAWBERRY_VARIANT, position, Vector.Zero, nil, subtype, seed)
end



---@param pickup EntityPickup
local function onBerryPickupInit(_, pickup)
    local sprite = pickup:GetSprite()
    sprite:Play(ANIMATION_IDLE, true)
    sprite:SetFrame(math.random(0,15))
    pickup.PositionOffset = POSITION_OFFSET
    pickup.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
    Game():Spawn(EntityType.ENTITY_EFFECT, EffectVariant.RIPPLE_POOF, pickup.Position, Vector.Zero, nil, 0, 0)
end    
MOD:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, onBerryPickupInit, STRAWBERRY_VARIANT)



---@param pickup EntityPickup
---@param collider Entity
---@param low boolean
local function onBerryPickupCollision(_, pickup, collider, low)
    --print(collider:ToPlayer():GetName())
    if collider.Type == EntityType.ENTITY_PLAYER then
        local player = collider:ToPlayer()

        if player == nil then
            return
        end
        
        if player:GetPlayerType() == PlayerType.PLAYER_THESOUL_B then
            player = player:GetMainTwin()
        end

        if player:HasCollectible(STRAWBERRY) then
            pickup:Remove()
            local touchSFX
            if pickup.SubType == STRAWBERRY_SUBTYPE.RED then
                touchSFX = SFX_STRAWBERRY_RED_TOUCH
            elseif pickup.SubType == STRAWBERRY_SUBTYPE.BLUE then
                touchSFX = SFX_STRAWBERRY_BLUE_TOUCH
            elseif pickup.SubType == STRAWBERRY_SUBTYPE.GOLDEN then
                touchSFX = SFX_STRAWBERRY_RED_TOUCH
            end
            sfx:Play(touchSFX, VOLUME_STRAWBERRY_TOUCH)
            spawnBerryFamiliar(pickup.SubType, pickup.Position, player)
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
            if pickup.SubType == STRAWBERRY_SUBTYPE.RED then
                pulseSfx = SFX_STRAWBERRY_RED_PULSE
            elseif pickup.SubType == STRAWBERRY_SUBTYPE.BLUE then
                pulseSfx = SFX_STRAWBERRY_BLUE_PULSE
            elseif pickup.SubType == STRAWBERRY_SUBTYPE.GOLDEN then
                pulseSfx = SFX_STRAWBERRY_RED_PULSE
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
            if familiar.SubType == STRAWBERRY_SUBTYPE.RED then
                pulseSfx = SFX_STRAWBERRY_RED_PULSE
            elseif familiar.SubType == STRAWBERRY_SUBTYPE.BLUE then
                pulseSfx = SFX_STRAWBERRY_BLUE_PULSE
            elseif familiar.SubType == STRAWBERRY_SUBTYPE.GOLDEN then
                pulseSfx = SFX_STRAWBERRY_RED_PULSE
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
                Luck = 0,
                NoMovementFrames = 0,
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

        playerRunSave.Strawberry.NoMovementFrames = (player:GetVelocityBeforeUpdate():Length() < CONSUME_SPEED_THRESHOLD) and playerRunSave.Strawberry.NoMovementFrames + 1 or 0

        if (#berries > 0 and playerRunSave.Strawberry.NoMovementFrames > CONSUME_FRAME_THRESHOLD) or playerRunSave.Strawberry.IsConsuming then
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

                if firstBerry.SubType == STRAWBERRY_SUBTYPE.RED then
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
                elseif firstBerry.SubType == STRAWBERRY_SUBTYPE.BLUE then
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
                elseif firstBerry.SubType == STRAWBERRY_SUBTYPE.GOLDEN then
                    if streak == 0 then
                        scoreSFX = SFX_STRAWBERRY_GOLDEN_1000
                    elseif streak == 1 then
                        scoreSFX = SFX_STRAWBERRY_GOLDEN_2000
                    elseif streak == 2 then
                        scoreSFX = SFX_STRAWBERRY_GOLDEN_3000
                    elseif streak == 3 then
                        scoreSFX = SFX_STRAWBERRY_GOLDEN_4000
                    elseif streak == 4 then
                        scoreSFX = SFX_STRAWBERRY_GOLDEN_5000
                    elseif streak == 5 then
                        scoreSFX = SFX_STRAWBERRY_GOLDEN_1UP
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
                player:AddCollectible(CollectibleType.COLLECTIBLE_1UP, nil, false)

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
                
                -- TODO FIX THIS BECAUSE SPAWNS QUEST AND HIDDEN ITEMS
                MOD:SpawnItemOfQuality(math.min(streak,4), player:GetCollectibleRNG(STRAWBERRY), firstBerry.Position)
                sfx:Play(SFX_KEY_GET, VOLUME_KEY_GET)

                if playerRunSave.Strawberry.Streak >= THRESHOLD_1UP then
                    playerRunSave.Strawberry.Luck = playerRunSave.Strawberry.Luck + LUCK_GAIN_PAST_1UP * (math.max(playerRunSave.Strawberry.Streak - THRESHOLD_1UP,1))
                    player:AddCacheFlags(CacheFlag.CACHE_LUCK)
                    player:EvaluateItems()
                end

                playerRunSave.Strawberry.Streak = 0
                playerRunSave.Strawberry.IsConsuming = false
            else
                --give luck up for each streak over threshold
                playerRunSave.Strawberry.Streak = streak + 1
                
            end
        end
    end
end
MOD:AddCallback(ModCallbacks.MC_POST_UPDATE, function() IterateOverPlayers(onUpdate) end)


---@param player EntityPlayer
---@param cacheFlag CacheFlag
local function onCacheEval(_, player, cacheFlag)
    if player:HasCollectible(STRAWBERRY) then
        if cacheFlag & CacheFlag.CACHE_LUCK == CacheFlag.CACHE_LUCK then
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



local function onNewFloorEnter()
    berryInvincibilityFramesLeft = NEW_RUN_INVINCIBILITY_FRAMES

    ---@param player EntityPlayer
    IterateOverPlayers(function(player, playerID)
        if player:HasCollectible(STRAWBERRY) then
            spawnBerryFamiliar(STRAWBERRY_SUBTYPE.GOLDEN, Game():GetRoom():GetRandomPosition(10), player)
        end
    end)
end
MOD:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, onNewFloorEnter)



local function onBerryActiveUse(_, itemID, rng, player, useFlags, activeSlot, customVarData)
    for _, entity in ipairs(Isaac.GetRoomEntities()) do
        if entity.Type == EntityType.ENTITY_PICKUP and entity.Variant == PickupVariant.PICKUP_COLLECTIBLE and entity.SubType ~= CollectibleType.COLLECTIBLE_NULL and not entity:ToPickup():IsShopItem() then
            --print(entity:ToPickup().SubType)
            spawnBerryPickup(STRAWBERRY_SUBTYPE.BLUE, entity.Position, player:GetCollectibleRNG(STRAWBERRY):GetSeed())
            entity:Remove()
        end
    end

    local transformSfx = {SFX_UI_GAME_INCREMENT_STRAWBERRY, SFX_UI_POSTGAME_STRAWBERRY_COUNT, SFX_UI_POSTGAME_STRAWBERRY_TOTAL}
    sfx:Play(transformSfx[math.random(1,3)], VOLUME_ACTIVE_USE)

    return true
end
MOD:AddCallback(ModCallbacks.MC_USE_ITEM, onBerryActiveUse, STRAWBERRY)



local function onRoomEnter()
    local triedToSpawn = false
    IterateOverPlayers(function(player, playerID)
        local room = Game():GetRoom()
        if player:HasCollectible(STRAWBERRY) and not triedToSpawn and room:IsFirstVisit() then
            if player:GetCollectibleRNG(STRAWBERRY):RandomInt(100) < ROOM_ENTER_SPAWN_CHANCE then
                triedToSpawn = true
                spawnBerryPickup(STRAWBERRY_SUBTYPE.RED, room:GetRandomPosition(10), player:GetCollectibleRNG(STRAWBERRY):GetSeed())
            end
        end
    end)

end
MOD:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, onRoomEnter)



---@param entity Entity
---@param amount number
---@param damageFlags integer
---@param source EntityRef
---@param countdownFrames integer
local function onEntityDamage(_, entity, amount, damageFlags, source, countdownFrames)
    local player = entity:ToPlayer()

    if player == nil then
        return
    end

    local function goldenRemoveOnHit()
        local numberOfGoldens = 0
        local playerRunSave = SAVE_MANAGER.GetRunSave(player)
        for i, berry in ipairs(playerRunSave.Strawberry.Berries) do
            local berry = berry.Ref
            local sprite = berry:GetSprite()
            if berry.SubType == STRAWBERRY_SUBTYPE.GOLDEN then
                numberOfGoldens = numberOfGoldens + 1
                if sprite:IsPlaying("Consume") then
                    goto continue
                end
                
                if sprite:IsFinished("Consume") then
                    berry:Remove()
                    table.remove(playerRunSave.Strawberry.Berries, i)
                    goto continue
                end
                ::continue::
            end
        end
        --print(numberOfGoldens)
        if numberOfGoldens == 0 then
            MOD:RemoveCallback(ModCallbacks.MC_POST_UPDATE, goldenRemoveOnHit)
        end
    end

    if player:HasCollectible(STRAWBERRY) then
        local hadGolden = false
        for _, berry in ipairs(SAVE_MANAGER.GetRunSave(player).Strawberry.Berries) do
            if berry.Ref.SubType == STRAWBERRY_SUBTYPE.GOLDEN then
                hadGolden = true
                sfx:Play(SFX_FUSEBOX_HIT_2_2D, LOSE_GOLDEN_BERRY_VOLUME, 15)
                berry.Ref:GetSprite():Play("Consume", true)
            end
        end
        if hadGolden then
            MOD:AddCallback(ModCallbacks.MC_POST_UPDATE, goldenRemoveOnHit)
        end
    end
end
MOD:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, onEntityDamage, EntityType.ENTITY_PLAYER)


