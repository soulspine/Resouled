local ISAAC8 = Isaac.GetChallengeIdByName("ISAAC-8")
local COSTUME = Isaac.GetCostumeIdByPath("gfx/characters/isaac-8.anm2")

local FINISH_CONDITION_1UP_COUNT = 5
local ROOM_ENTER_SPAWN_CHANCE = 0.3
local ROOM_ENTER_WINGED_REPLACE_CHANCE = 0.4

local RED_BERRY_SPAWN_DISTANCE_THRESHOLD = 10

local STARTING_NO_MOVEMENT_FRAMES = -500

local LUCK_GAIN_PAST_1UP = 1

local PICKUP_SHOP_PRICE = 15
local PICKUP_DEVIL_PRICE = -1

local CONSUME_SPEED_THRESHOLD = 0.01
local CONSUME_FRAME_THRESHOLD = 30
local CONSUME_EARLY_SCORE_END_FRAME = 4

-- SFX
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

local SFX_STRAWBERRY_WING_FLAP_1 = Isaac.GetSoundIdByName("Strawberry Wing Flap 1")
local SFX_STRAWBERRY_WING_FLAP_2 = Isaac.GetSoundIdByName("Strawberry Wing Flap 2")
local SFX_STRAWBERRY_WING_FLAP_3 = Isaac.GetSoundIdByName("Strawberry Wing Flap 3")
local SFX_STRAWBERRY_LAUGH = Isaac.GetSoundIdByName("Strawberry Laugh")
local SFX_STRAWBERRY_FLY_AWAY = Isaac.GetSoundIdByName("Strawberry Fly Away")

local SFX_UI_POSTGAME_STRAWBERRY_TOTAL = Isaac.GetSoundIdByName("UI Postgame Strawberry Total")
local SFX_UI_POSTGAME_STRAWBERRY_COUNT = Isaac.GetSoundIdByName("UI Postgame Strawberry Count")
local SFX_UI_GAME_INCREMENT_STRAWBERRY = Isaac.GetSoundIdByName("UI Game Increment Strawberry")
local SFX_FUSEBOX_HIT_2_2D = Isaac.GetSoundIdByName("Fusebox Hit 2 2D")

local VOLUME_KEY_GET = 0.7
local VOLUME_STRAWBERRY_TOUCH = 0.7
local VOLUME_STRAWBERRY_PULSE = 0.7
local VOLUME_STRAWBERRY_SCORE = 0.7
local VOLUME_ACTIVE_USE = 0.7
local VOLUME_LOSE_GOLDEN = 0.7
local VOLUME_STRAWBERRY_FLAP = 0.7
local VOLUME_STRAWBERRY_LAUGH = 0.7
local VOLUME_STRAWBERRY_FLY_AWAY = 0.7

local ANIMATION_RED_IDLE = "RedIdle"
local ANIMATION_RED_CONSUME = "RedConsume"
local ANIMATION_BLUE_IDLE = "BlueIdle"
local ANIMATION_BLUE_CONSUME = "BlueConsume"
local ANIMATION_GOLDEN_IDLE = "GoldenIdle"
local ANIMATION_GOLDEN_CONSUME = "GoldenConsume"
local ANIMATION_WINGED_IDLE = "WingedIdle"
local ANIMATION_1UP_LOOP = "1UP LOOP"
local ANIMATION_1UP_END = "1UP END"
local ANIMATION_WINGED_RUN_AWAY = "WingedRunAway"
local ANIMATION_NONE = "None"
local THRESHOLD_1UP = 5
local FRAME_STRAWBERRY_RED_PULSE = 60
local FRAME_STRAWBERRY_BLUE_PULSE = 60
local FRAME_STRAWBERRY_WINGED_PULSE = 51
local FRAME_STRAWBERRY_GOLDEN_PULSE = 66
local FRAME_STRAWBERRY_WINGED_LOOP = 24
local FRAME_STRAWBERRY_WINGED_FLAP = 3

local STRAWBERRY_VARIANT = Isaac.GetEntityVariantByName("Red Strawberry Pickup")

---@class StrawberrySubtype
local STRAWBERRY_SUBTYPE = {
    RED = 0,
    BLUE = 1,
    GOLDEN = 2,
    WINGED = 3,
}

---@param entity Entity
---@return string
local function GetIdleAnimationString(entity)
    local animationName = ""
    if entity.SubType == STRAWBERRY_SUBTYPE.RED then
        animationName = ANIMATION_RED_IDLE
    elseif entity.SubType == STRAWBERRY_SUBTYPE.BLUE then
        animationName = ANIMATION_BLUE_IDLE
    elseif entity.SubType == STRAWBERRY_SUBTYPE.GOLDEN then
        animationName = ANIMATION_GOLDEN_IDLE
    elseif entity.SubType == STRAWBERRY_SUBTYPE.WINGED then
        animationName = ANIMATION_WINGED_IDLE
    end
    return animationName
end

---@param entity Entity
---@return string
local function GetConsumeAnimationString(entity)
    local animationName = ""
    if entity.SubType == STRAWBERRY_SUBTYPE.RED then
        animationName = ANIMATION_RED_CONSUME
    elseif entity.SubType == STRAWBERRY_SUBTYPE.BLUE then
        animationName = ANIMATION_BLUE_CONSUME
    elseif entity.SubType == STRAWBERRY_SUBTYPE.GOLDEN then
        animationName = ANIMATION_GOLDEN_CONSUME
    end
    return animationName
end

---@param player EntityPlayer
local function onPlayerInit(_, player)
    if Isaac.GetChallenge() == ISAAC8 then
        player:ClearCostumes()
        player:AddNullCostume(COSTUME)

        local playerRunSave = SAVE_MANAGER.GetRunSave(player)
        if playerRunSave.ISAAC8 == nil then
            playerRunSave.ISAAC8 = {
            Streak = 0,
            IsConsuming = false,
            Berries = {},
            Luck = 0,
            NoMovementFrames = STARTING_NO_MOVEMENT_FRAMES,
        }
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, onPlayerInit)

local function onUpdate()
    if Isaac.GetChallenge() == ISAAC8 then
        Resouled:IterateOverPlayers(function(player)
            -- TODO replace jump animation with custom one

            local playerRunSave = SAVE_MANAGER.GetRunSave(player)
            
            if playerRunSave.ISAAC8 == nil then
                return
            end
        
            playerRunSave.ISAAC8.NoMovementFrames = (player:GetVelocityBeforeUpdate():Length() < CONSUME_SPEED_THRESHOLD) and math.min(CONSUME_FRAME_THRESHOLD,playerRunSave.ISAAC8.NoMovementFrames + 1) or 0
        
            if #playerRunSave.ISAAC8.Berries > 0 or playerRunSave.ISAAC8.IsConsuming then
            
                local berries = playerRunSave.ISAAC8.Berries
                local streak = playerRunSave.ISAAC8.Streak
            
                local scoreAnimation = ""
            
                if playerRunSave.ISAAC8.NoMovementFrames == CONSUME_FRAME_THRESHOLD or playerRunSave.ISAAC8.IsConsuming then
                    ---@type EntityFamiliar
                    local firstBerry = berries[1].Ref:ToFamiliar()
                    if firstBerry == nil then
                        return
                    end
                
                    local sprite = firstBerry:GetSprite()
                    local idleAnimation = GetIdleAnimationString(firstBerry)
                    local consumeAnimation = GetConsumeAnimationString(firstBerry)

                    playerRunSave.ISAAC8.IsConsuming = true
                
                    if sprite:IsPlaying(ANIMATION_1UP_END) then
                        return
                    elseif sprite:IsFinished(ANIMATION_1UP_END) then
                        goto noScore
                    end
                
                    -- play consume if in idle
                    if sprite:IsPlaying(idleAnimation) then
                        sprite:Play(consumeAnimation, true)
                    
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
                            SFXManager():Play(scoreSFX, VOLUME_STRAWBERRY_SCORE)
                        end
                    
                        return
                    end
                
                    -- skip if consume is playing
                    if sprite:IsPlaying(consumeAnimation) then
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
                        if #berries == 1 then
                            sprite:Play(ANIMATION_1UP_END, true)
                            return
                        else
                            scoreAnimation = ANIMATION_NONE
                        end
                    end
                
                    -- do not animate score if there is 1up played already
                    if scoreAnimation == ANIMATION_NONE then
                        goto noScore
                    end
                
                    if sprite:IsFinished(consumeAnimation) then
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
                        table.insert(berries, EntityPtr(firstBerry))
                    else
                        firstBerry:Remove()
                    end
                    table.remove(berries, 1)
                
                    -- update streak
                    if #berries == 0 then
                        local entity = Resouled:SpawnChaosItemOfQuality(math.min(streak, 4), firstBerry:GetDropRNG(), Game():GetRoom():GetRandomPosition(10), player)
                        local runFloorSave = SAVE_MANAGER.GetRoomFloorSave(entity)
                        runFloorSave.SpawnedByPlayer = true
                        SFXManager():Play(SFX_KEY_GET, VOLUME_KEY_GET)
                    
                        if playerRunSave.ISAAC8.Streak >= THRESHOLD_1UP then
                            playerRunSave.ISAAC8.Luck = playerRunSave.ISAAC8.Luck + LUCK_GAIN_PAST_1UP * (math.max(playerRunSave.ISAAC8.Streak - THRESHOLD_1UP,1))
                            player:AddCacheFlags(CacheFlag.CACHE_LUCK)
                            player:EvaluateItems()
                        end
                    
                        playerRunSave.ISAAC8.Streak = 0
                        playerRunSave.ISAAC8.IsConsuming = false
                    else
                        --give luck up for each streak over threshold
                        playerRunSave.ISAAC8.Streak = streak + 1

                    end
                end
            end
        end)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_UPDATE, onUpdate)

---@param pickup EntityPickup
local function onPickupInit(_, pickup)
    if Isaac.GetChallenge() == ISAAC8 then
        local runFloorSave = SAVE_MANAGER.GetRoomFloorSave(pickup)
        if pickup.SpawnerType ~= EntityType.ENTITY_PLAYER and not runFloorSave.SpawnedByPlayer then
            pickup:Morph(EntityType.ENTITY_PICKUP, STRAWBERRY_VARIANT, STRAWBERRY_SUBTYPE.BLUE, true, true, true)
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, onPickupInit, PickupVariant.PICKUP_COLLECTIBLE)

---@param pickup EntityPickup
local function onBerryPickupInit(_, pickup)
    if pickup.SubType ~= STRAWBERRY_SUBTYPE.BLUE and not Game():GetRoom():IsFirstVisit() then
        pickup:Remove()
        return
    end

    local sprite = pickup:GetSprite()
    sprite:Play(GetIdleAnimationString(pickup), true)
    sprite:SetFrame(math.random(0,15))
    pickup.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
    pickup.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
    pickup:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK)
    if Game():GetRoom():IsFirstVisit() then
        Game():Spawn(EntityType.ENTITY_EFFECT, EffectVariant.RIPPLE_POOF, pickup.Position, Vector.Zero, nil, 0, 0)

        if pickup.SubType == STRAWBERRY_SUBTYPE.BLUE then
            local transformSfx = {SFX_UI_GAME_INCREMENT_STRAWBERRY, SFX_UI_POSTGAME_STRAWBERRY_COUNT, SFX_UI_POSTGAME_STRAWBERRY_TOTAL}
            SFXManager():Play(transformSfx[math.random(1,3)], VOLUME_ACTIVE_USE)
        end

    end
end    
Resouled:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, onBerryPickupInit, STRAWBERRY_VARIANT)

---@param pickup EntityPickup
local function onBerryPickupUpdate(_, pickup)

    if pickup.Price > 0 then
        pickup.Price = PICKUP_SHOP_PRICE
    elseif pickup.Price < 0 then
        pickup.Price = PICKUP_DEVIL_PRICE
    end

    local sprite = pickup:GetSprite()
    if sprite:IsPlaying(GetIdleAnimationString(pickup)) then
        local frame = sprite:GetFrame()

        local pulseSfx = nil
        if pickup.SubType == STRAWBERRY_SUBTYPE.RED and frame == FRAME_STRAWBERRY_RED_PULSE then
            pulseSfx = SFX_STRAWBERRY_RED_PULSE
        elseif pickup.SubType == STRAWBERRY_SUBTYPE.BLUE and frame == FRAME_STRAWBERRY_BLUE_PULSE then
            pulseSfx = SFX_STRAWBERRY_BLUE_PULSE
        elseif pickup.SubType == STRAWBERRY_SUBTYPE.GOLDEN and frame == FRAME_STRAWBERRY_GOLDEN_PULSE then
            pulseSfx = SFX_STRAWBERRY_RED_PULSE
        elseif pickup.SubType == STRAWBERRY_SUBTYPE.WINGED and frame == FRAME_STRAWBERRY_WINGED_PULSE then
            pulseSfx = SFX_STRAWBERRY_RED_PULSE
        end
        
        if pulseSfx ~= nil then
            SFXManager():Play(pulseSfx, VOLUME_STRAWBERRY_PULSE, 0)
        end

        if pickup.SubType == STRAWBERRY_SUBTYPE.WINGED and frame%FRAME_STRAWBERRY_WINGED_LOOP == FRAME_STRAWBERRY_WINGED_FLAP then
            local flapSFX = {SFX_STRAWBERRY_WING_FLAP_1, SFX_STRAWBERRY_WING_FLAP_2, SFX_STRAWBERRY_WING_FLAP_3}
            SFXManager():Play(flapSFX[math.random(1,3)], VOLUME_STRAWBERRY_FLAP, 0)
        end
    end   
end
Resouled:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, onBerryPickupUpdate, STRAWBERRY_VARIANT)

---@param pickup EntityPickup
---@param collider Entity
---@param low boolean
local function onBerryPickupCollision(_, pickup, collider, low)
    if collider.Type == EntityType.ENTITY_PLAYER then
        local player = collider:ToPlayer()

        if player == nil then
            return
        end
        
        if player:GetPlayerType() == PlayerType.PLAYER_THESOUL_B then
            player = player:GetMainTwin()
        end

        pickup:Remove()
        local touchSFX
        local berrySubtype
        if pickup.SubType == STRAWBERRY_SUBTYPE.RED then
            touchSFX = SFX_STRAWBERRY_RED_TOUCH
            berrySubtype = STRAWBERRY_SUBTYPE.RED
        elseif pickup.SubType == STRAWBERRY_SUBTYPE.BLUE then
            touchSFX = SFX_STRAWBERRY_BLUE_TOUCH
            berrySubtype = STRAWBERRY_SUBTYPE.BLUE
        elseif pickup.SubType == STRAWBERRY_SUBTYPE.GOLDEN then
            touchSFX = SFX_STRAWBERRY_RED_TOUCH
            berrySubtype = STRAWBERRY_SUBTYPE.GOLDEN
        elseif pickup.SubType == STRAWBERRY_SUBTYPE.WINGED then
            touchSFX = SFX_STRAWBERRY_RED_TOUCH
            berrySubtype = STRAWBERRY_SUBTYPE.RED
        end
        SFXManager():Play(touchSFX, VOLUME_STRAWBERRY_TOUCH)
        Game():Spawn(EntityType.ENTITY_FAMILIAR, STRAWBERRY_VARIANT, pickup.Position, Vector.Zero, player, berrySubtype, pickup.InitSeed)
        return true
    end
end
Resouled:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, onBerryPickupCollision, STRAWBERRY_VARIANT)

---@param familiar EntityFamiliar
local function onBerryFamiliarInit(_, familiar)
    local sprite = familiar:GetSprite()
    sprite:Play(GetIdleAnimationString(familiar), true)
    sprite:SetFrame(math.random(0,15))
    familiar:AddToFollowers()
    
    local player = familiar.Player:ToPlayer()
    if player == nil then
        return
    end    

    local playerRunSave = SAVE_MANAGER.GetRunSave(player)

    table.insert(playerRunSave.ISAAC8.Berries, EntityPtr(familiar))
end    
Resouled:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, onBerryFamiliarInit, STRAWBERRY_VARIANT)

local function onBerryFamiliarUpdate(_, familiar)
    local sprite = familiar:GetSprite()
    if sprite:IsPlaying(GetIdleAnimationString(familiar)) then
        local frame = sprite:GetFrame()
        local pulseSfx = nil
        if familiar.SubType == STRAWBERRY_SUBTYPE.RED and frame == FRAME_STRAWBERRY_RED_PULSE then
            pulseSfx = SFX_STRAWBERRY_RED_PULSE
        elseif familiar.SubType == STRAWBERRY_SUBTYPE.BLUE and frame == FRAME_STRAWBERRY_BLUE_PULSE then
            pulseSfx = SFX_STRAWBERRY_BLUE_PULSE
        elseif familiar.SubType == STRAWBERRY_SUBTYPE.GOLDEN and frame == FRAME_STRAWBERRY_GOLDEN_PULSE then
            pulseSfx = SFX_STRAWBERRY_RED_PULSE
        elseif familiar.SubType == STRAWBERRY_SUBTYPE.WINGED and frame == FRAME_STRAWBERRY_WINGED_PULSE then
            pulseSfx = SFX_STRAWBERRY_RED_PULSE
        end
        
        if pulseSfx ~= nil then
            SFXManager():Play(pulseSfx, VOLUME_STRAWBERRY_PULSE)
        end
    end
    familiar:FollowParent()
end    
Resouled:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, onBerryFamiliarUpdate, STRAWBERRY_VARIANT)

-- TODO REWRITE THIS
---@param entity Entity
---@param amount number
---@param damageFlags integer
---@param source EntityRef
---@param countdownFrames integer
local function onPlayerDamage(_, entity, amount, damageFlags, source, countdownFrames)
    if Isaac.GetChallenge() == ISAAC8 then
        local player = entity:ToPlayer()

        if player == nil then
            return
        end

        local function goldenRemoveOnHit()
            local numberOfGoldens = 0
            local playerRunSave = SAVE_MANAGER.GetRunSave(player)
            for i, berry in ipairs(playerRunSave.ISAAC8.Berries) do
                local berry = berry.Ref
                local sprite = berry:GetSprite()
                if berry.SubType == STRAWBERRY_SUBTYPE.GOLDEN then
                    numberOfGoldens = numberOfGoldens + 1
                    if sprite:IsPlaying("Consume") then
                        goto continue
                    end

                    if sprite:IsFinished("Consume") then
                        berry:Remove()
                        table.remove(playerRunSave.ISAAC8.Berries, i)
                        goto continue
                    end
                    ::continue::
                end
            end
            if numberOfGoldens == 0 then
                Resouled:RemoveCallback(ModCallbacks.MC_POST_UPDATE, goldenRemoveOnHit)
            end
        end

        local hadGolden = false
        for _, berry in ipairs(SAVE_MANAGER.GetRunSave(player).ISAAC8.Berries) do
            if berry.Ref.SubType == STRAWBERRY_SUBTYPE.GOLDEN then
                hadGolden = true
                berry.Ref:GetSprite():Play("Consume", true)
            end
        end
        if hadGolden then
            SFXManager():Play(SFX_FUSEBOX_HIT_2_2D, VOLUME_LOSE_GOLDEN)
            Resouled:AddCallback(ModCallbacks.MC_POST_UPDATE, goldenRemoveOnHit)
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, onPlayerDamage, EntityType.ENTITY_PLAYER)

---@param player EntityPlayer
---@param cacheFlag CacheFlag
local function onCacheEval(_, player, cacheFlag)
    if Isaac.GetChallenge() == ISAAC8 and cacheFlag == CacheFlag.CACHE_LUCK then
        local playerRunSave = SAVE_MANAGER.GetRunSave(player)
        
        if playerRunSave.ISAAC8 then
            player.Luck = player.Luck + playerRunSave.ISAAC8.Luck
        end

    end
end
Resouled:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, onCacheEval)

local function onTrophySpawn(_, pickup)
    if Isaac.GetChallenge() == ISAAC8 then
        local _1upCount = 0
        ---@param player EntityPlayer
        Resouled:IterateOverPlayers(function(player)
            _1upCount = _1upCount + player:GetCollectibleNum(CollectibleType.COLLECTIBLE_1UP)
        end)

        if _1upCount < FINISH_CONDITION_1UP_COUNT then
            pickup:Remove()
            Isaac.GetPlayer(0):UseActiveItem(CollectibleType.COLLECTIBLE_R_KEY)
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, onTrophySpawn, PickupVariant.PICKUP_TROPHY)

local function onNewFloorEnter()
    if Isaac.GetChallenge() == ISAAC8 then
        ---@param player EntityPlayer
        Resouled:IterateOverPlayers(function(player)
            Game():Spawn(EntityType.ENTITY_FAMILIAR, STRAWBERRY_VARIANT, player.Position, Vector.Zero, player, STRAWBERRY_SUBTYPE.GOLDEN, player.DropSeed)
        end)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, onNewFloorEnter)

local function onRoomEnter()
    if Isaac.GetChallenge() == ISAAC8 then
        local room = Game():GetRoom()
        if room:IsFirstVisit() then
            local rng = RNG()
            rng:SetSeed(room:GetSpawnSeed(), 0)
            if  rng:RandomFloat() < ROOM_ENTER_SPAWN_CHANCE then
                local berrySubtype
                if not room:IsClear() and rng:RandomFloat() < ROOM_ENTER_WINGED_REPLACE_CHANCE then
                    berrySubtype = STRAWBERRY_SUBTYPE.WINGED
                else
                    berrySubtype = STRAWBERRY_SUBTYPE.RED
                end
                
                local topLeft = room:GetTopLeftPos()
                local bottomRight = room:GetBottomRightPos()
                local roomWidth = bottomRight.X - topLeft.X
                local roomHeight = bottomRight.Y - topLeft.Y

                local rawPosition = Vector(rng:RandomInt(roomWidth), rng:RandomInt(roomHeight))  

                local position = room:FindFreeTilePosition(rawPosition, RED_BERRY_SPAWN_DISTANCE_THRESHOLD)

                Game():Spawn(EntityType.ENTITY_PICKUP, STRAWBERRY_VARIANT, position, Vector.Zero, nil, berrySubtype, room:GetSpawnSeed())
            end
        end
    end

end
Resouled:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, onRoomEnter)