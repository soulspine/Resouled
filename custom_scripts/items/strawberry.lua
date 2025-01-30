local STRAWBERRY = Isaac.GetItemIdByName("Strawberry")

local POSITION_OFFSET = Vector(0,-30)
local CONSUME_SPEED_THRESHOLD = 0.01

local CONSUME_EARLY_SCORE_END_FRAME = 4

if EID then
    EID:addCollectible(STRAWBERRY, "Not implemented yet", "Strawberry")
end

local STRAWBERRY_VARIANT = Isaac.GetEntityVariantByName("Red Strawberry Pickup")
local activeBerries = {}
local sfx = SFXManager()

local SFX_STRAWBERRY_RED_TOUCH = Isaac.GetSoundIdByName("Red Strawberry Touch")
local SFX_STRAWBERRY_RED_PULSE = Isaac.GetSoundIdByName("Red Strawberry Pulse")
local FRAME_STRAWBERRY_RED_PULSE = 60
local SFX_STRAWBERRY_RED_1000 = Isaac.GetSoundIdByName("Red Strawberry 1000")
local SFX_STRAWBERRY_RED_2000 = Isaac.GetSoundIdByName("Red Strawberry 2000")
local SFX_STRAWBERRY_RED_3000 = Isaac.GetSoundIdByName("Red Strawberry 3000")
local SFX_STRAWBERRY_RED_4000 = Isaac.GetSoundIdByName("Red Strawberry 4000")
local SFX_STRAWBERRY_RED_5000 = Isaac.GetSoundIdByName("Red Strawberry 5000")
local SFX_STRAWBERRY_RED_1UP = Isaac.GetSoundIdByName("Red Strawberry 1UP")

local VOLOUME_STRAWBERRY_TOUCH = 0.7
local VOLOUME_STRAWBERRY_PULSE = 0.7
local VOLUME_STRAWBERRY_SCORE = 0.7

local ANIMATION_IDLE = "Idle"
local ANIMATION_CONSUME = "Consume"
local ANIMATION_1UP_LOOP = "1UP LOOP"
local ANIMATION_1UP_END = "1UP END"
local ANIMATION_NONE = "None"
local THRESHOLD_1UP = 5

---@param pickup EntityPickup
local function onBerryPickupInit(_, pickup)
    local sprite = pickup:GetSprite()
    sprite:Play(ANIMATION_IDLE, true)
    pickup.PositionOffset = POSITION_OFFSET
    pickup.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
end

local function onBerryPickupUpdateInit(_, pickup)
    local sprite = pickup:GetSprite()
    if sprite:IsPlaying(ANIMATION_IDLE) then
        if sprite:GetFrame() == FRAME_STRAWBERRY_RED_PULSE then
            sfx:Play(SFX_STRAWBERRY_RED_PULSE, VOLOUME_STRAWBERRY_PULSE)
        end
    end
end

---@param familiar EntityFamiliar
local function onBerryFamiliarInit(_, familiar)
    familiar.PositionOffset = POSITION_OFFSET
    familiar:GetSprite():SetFrame(math.random(0,15))
    familiar:AddToFollowers()
    
    local player = familiar.Player:ToPlayer()
    if player == nil then
        return
    end
    local playerPtrHash = GetPtrHash(player)
    --print("Upper hash: " .. playerPtrHash)
    if activeBerries[playerPtrHash] == nil then
        activeBerries[playerPtrHash] = {}
    end
    table.insert(activeBerries[playerPtrHash], EntityPtr(familiar))
end

---@param familiar EntityFamiliar
local function onBerryFamiliarUpdate(_, familiar)
    --print("Familiar update")
    local sprite = familiar:GetSprite()
    if sprite:IsPlaying(ANIMATION_IDLE) then
        if sprite:GetFrame() == FRAME_STRAWBERRY_RED_PULSE then
            sfx:Play(SFX_STRAWBERRY_RED_PULSE, VOLOUME_STRAWBERRY_PULSE)
        end
    end
    familiar:FollowParent()
    --print(#activeBerries[GetPtrHash(familiar.Player)])
end

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
            end
            sfx:Play(touchSFX, VOLOUME_STRAWBERRY_TOUCH)
            Isaac.Spawn(EntityType.ENTITY_FAMILIAR, STRAWBERRY_VARIANT, pickup.SubType, pickup.Position, Vector.Zero, player)
        end
    end
end

local berryStreaks = {}
local areConsuming = {}

---@param player EntityPlayer
---@param playerID any
local function onUpdate(player, playerID)
    local playerPtrHash = GetPtrHash(player)
    local playerBerries = activeBerries[playerPtrHash]

    if berryStreaks[playerPtrHash] == nil then
        berryStreaks[playerPtrHash] = 0
    end

    if areConsuming[playerPtrHash] == nil then
        areConsuming[playerPtrHash] = false
    end

    if playerBerries == nil then
        berryStreaks[playerPtrHash] = 0
        return
    end

    local berryStreak = berryStreaks[playerPtrHash]
    local isConsuming = areConsuming[playerPtrHash]

    local scoreAnimation = ""
    
    --print(isConsuming)

    if (player:HasCollectible(STRAWBERRY) and #playerBerries > 0 and player:GetVelocityBeforeUpdate():Length() < CONSUME_SPEED_THRESHOLD) or isConsuming then
        ---@type EntityFamiliar
        local firstBerry = playerBerries[1].Ref:ToFamiliar()
        if firstBerry == nil then
            return
        end

        local sprite = firstBerry:GetSprite()

        areConsuming[playerPtrHash] = true

        if sprite:IsPlaying(ANIMATION_1UP_END) then
            return
        elseif sprite:IsFinished(ANIMATION_1UP_END) then
            goto noScore
        end

        -- play consume if in idle
        if sprite:IsPlaying(ANIMATION_IDLE) then
            sprite:Play(ANIMATION_CONSUME, true)
            return
        end

        -- skip if consume is playing
        if sprite:IsPlaying(ANIMATION_CONSUME) then
            return
        end
        
        -- decide what to do based on streak
        if berryStreak < THRESHOLD_1UP then
            scoreAnimation = tostring(1000*(berryStreak+1))
        elseif berryStreak == THRESHOLD_1UP then
            if #playerBerries == 1 then
                scoreAnimation = ANIMATION_1UP_END
            else
                scoreAnimation = ANIMATION_1UP_LOOP
            end
        else -- berryStreak > THRESHOLD_1UP
            -- this can be the 1UP berry at the end
            --print(#playerBerries)
            if #playerBerries == 1 then
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

            local scoreSFX

            -- TODO ADD DIFFERENT BERRIES
            if scoreAnimation == ANIMATION_1UP_END or scoreAnimation == ANIMATION_1UP_LOOP then
                scoreSFX = SFX_STRAWBERRY_RED_1UP
            elseif scoreAnimation == "1000" then
                scoreSFX = SFX_STRAWBERRY_RED_1000
            elseif scoreAnimation == "2000" then
                scoreSFX = SFX_STRAWBERRY_RED_2000
            elseif scoreAnimation == "3000" then
                scoreSFX = SFX_STRAWBERRY_RED_3000
            elseif scoreAnimation == "4000" then
                scoreSFX = SFX_STRAWBERRY_RED_4000
            elseif scoreAnimation == "5000" then
                scoreSFX = SFX_STRAWBERRY_RED_5000
            end

            sfx:Play(scoreSFX, VOLUME_STRAWBERRY_SCORE)

        end

        -- special case for 1up loop
        if scoreAnimation ~= ANIMATION_1UP_LOOP and sprite:IsPlaying(scoreAnimation) then
            if #playerBerries == 1 then
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
            table.insert(activeBerries[playerPtrHash], EntityPtr(firstBerry))
        else
            firstBerry:Remove()
        end
        table.remove(playerBerries, 1)
        
        --print("Player berries: " .. #playerBerries .. " " .. "Streak: " .. berryStreak)

        -- update streak
        if #playerBerries == 0 then
            berryStreaks[playerPtrHash] = 0
            areConsuming[playerPtrHash] = false
        else
            berryStreaks[playerPtrHash] = berryStreak + 1
        end
    end
end

MOD:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, onBerryPickupInit, STRAWBERRY_VARIANT)
MOD:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, onBerryPickupCollision, STRAWBERRY_VARIANT)
MOD:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, onBerryPickupUpdateInit, STRAWBERRY_VARIANT)

MOD:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, onBerryFamiliarInit, STRAWBERRY_VARIANT)
MOD:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, onBerryFamiliarUpdate, STRAWBERRY_VARIANT)

MOD:AddCallback(ModCallbacks.MC_POST_UPDATE, function() IterateOverPlayers(onUpdate) end)