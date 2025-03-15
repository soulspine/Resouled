local SLEIGHT_OF_HAND = Isaac.GetItemIdByName("Sleight of Hand")

-- THIS WORKS LIKE THAT:
-- 1. GETS THE CLOSEST DOOR AND DETERMINES THE TARGET ROOM
-- 2. MOVES PLAYERS INTO THAT ROOM, SAVES DATA ABOUT ALL PICKUPS THERE AND SAVES CHARGE STATE
-- 3. MOVES PLAYERS BACK TO THE ORIGINAL ROOM BY USING GLOWING HOURGLASS WHILE SPEEDING UP THE TELEPORT ANIMATION TO SAVE 18 FRAMES
-- 4. ADJUSTS PLAYERS POSITIONS AND CHARGES
-- 5. ANIMATES PICKUPS OVER THE PLAYER THAT USED THE ITEM
-- 6. IF SOMETHING BREAKS, THERE IS A TIMEOUT THAT RESETS EVERYTHING BACK TO THE START

if EID then
    EID:addCollectible(SLEIGHT_OF_HAND, "Peeks into the closest room and makes Isaac hold all {{Coin}} pickups and {{Collectible}} items in that room.", "Sleight of Hand")
end

local TIMEOUT = 1000
local PICKUP_ANIMATE_COOLDOWN = 35
local ACTIVATION_COOLDOWN = 21

local ANIMATION_TELEPORT_UP = "TeleportUp"
local ANIMATION_TELEPORT_UP_FRAME_NUM = 19

local GLOWING_DOOR_SPRITE = Sprite()
GLOWING_DOOR_SPRITE:Load("gfx/effects/glowing_door.anm2", true)
GLOWING_DOOR_SPRITE:Play("Idle", true)
local globalGlowingDoorPosition = Vector.Zero
local globalGlowingDoorRotation = 0

local BLACKOUT_SPRITE = Sprite()
BLACKOUT_SPRITE:Load("gfx/effects/blackout.anm2", true)
BLACKOUT_SPRITE:Play("Idle", true)
local BLACKOUT_TRANSITION_TIME = 15
local BLACKOUT_POST_TRANSITION_PAUSE = 15
local BLACKOUT_STAY_TIME = 43
local globalBlackoutIntensity = nil
local globalBlackoutPostTransitionPause = 0
local globalBlackoutTimer = 0

local SFX_PICKUP_ANIM = SoundEffect.SOUND_FETUS_JUMP
local SFX_USE = SoundEffect.SOUND_UNLOCK00
local SFX_GLOWING_HOURGLASS_TELEPORT = SoundEffect.SOUND_HELL_PORTAL2

local function adjustCharge(player, activeSlot)
    local totalCharge = player:GetActiveCharge(activeSlot) + player:GetBatteryCharge(activeSlot)
    local itemMaxCharges = Isaac.GetItemConfig():GetCollectible(SLEIGHT_OF_HAND).MaxCharges
    if totalCharge >= itemMaxCharges then
        player:SetActiveCharge(totalCharge - itemMaxCharges, activeSlot)
    else
        local bethanyCharge = itemMaxCharges - totalCharge
        player:SetActiveCharge(0, activeSlot)
        player:AddSoulCharge(-bethanyCharge)
        player:AddBloodCharge(-bethanyCharge)
    end
end

---@param player EntityPlayer
local function onPlayerInit(_, player)
    if player:GetPlayerType() == PlayerType.PLAYER_CAIN then
        player:AddCollectible(SLEIGHT_OF_HAND, 4, true, ActiveSlot.SLOT_PRIMARY, 0)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, onPlayerInit)

---@param itemId CollectibleType
---@param rng RNG
---@param player EntityPlayer
---@param useFlags UseFlag
---@param activeSlot ActiveSlot
---@param customVarData integer
local function onActiveUse(_, itemId, rng, player, useFlags, activeSlot, customVarData)
    local returnTable = {
        Discharge = false,
        Remove = false,
        ShowAnim = true,
    }
    
    local runSave = SAVE_MANAGER.GetRunSave(nil, true)

    -- this is here to prevent player from spamming it between time frame of glowing hourglass teleport and charge adjustment
    if runSave.SleightOfHand then
        return returnTable
    end

    local door = Resouled:GetClosestDoor(player.Position)

    if door then
        local game = Game()
        local level = game:GetLevel()
        local targetRoomDesc = level:GetRoomByIdx(door.TargetRoomIndex)

        if door.TargetRoomType == RoomType.ROOM_BOSS and not targetRoomDesc.Clear then
            return returnTable
        end

        local targetRoomSafeIndex = targetRoomDesc.SafeGridIndex
        local targetRoomCoords = Vector(targetRoomSafeIndex % 13, targetRoomSafeIndex // 13)
        local playerPositions = {}
        
        -- we save all player positions to move them back later
        ---@param player EntityPlayer
        Resouled:IterateOverPlayers(function(player)
            local position = player.Position
            table.insert(playerPositions, position)
        end)
        
        -- data needed for it to work, animation cooldown is purposefully not set here
        runSave.SleightOfHand = {
            ActivationCooldown = targetRoomSafeIndex < 0 and ACTIVATION_COOLDOWN or 0,
            TargetRoomSafeIndex = targetRoomSafeIndex,
            TargetRoomCoords = targetRoomCoords,
            PlayerPositions = playerPositions,
            Pickups = {},
            Rewinded = false,
            PlayerIndex = player.Index,
            InterruptedGlowingHourglass = false,
            Timeout = TIMEOUT,
            EnteredNewRoom = false,
        }

        adjustCharge(player, activeSlot)

        -- we save charges 
        runSave.SleightOfHand.Charges = {
            Normal = player:GetActiveCharge(activeSlot) + player:GetBatteryCharge(activeSlot),
            Soul = player:GetSoulCharge(),
            Blood = player:GetBloodCharge(),
        }

        globalBlackoutIntensity = 1/BLACKOUT_TRANSITION_TIME
        globalGlowingDoorPosition = Game():GetRoom():WorldToScreenPosition(door.Position)
        globalGlowingDoorRotation = door:GetSprite().Rotation
    end
    return returnTable
end
Resouled:AddCallback(ModCallbacks.MC_USE_ITEM, onActiveUse, SLEIGHT_OF_HAND)

local function onNewRoomEnter()
    local runSave = SAVE_MANAGER.GetRunSave(nil, true)
    if runSave.SleightOfHand and not runSave.SleightOfHand.EnteredNewRoom then
        runSave.SleightOfHand.EnteredNewRoom = true
        SFXManager():Play(SFX_USE)
    end
    if runSave.SleightOfHand and not runSave.SleightOfHand.Rewinded and not Game():IsPaused() then
        -- we save all pickups data
        ---@param entity Entity
        Resouled:IterateOverRoomEntities(function(entity)
            if entity.Type == EntityType.ENTITY_PICKUP then
                local entitySprite = entity:GetSprite()
                table.insert(runSave.SleightOfHand.Pickups, {
                    Variant = entity.Variant,
                    SubType = entity.SubType,
                    Animation = {
                        File = entitySprite:GetFilename(),
                        Name = entitySprite:GetDefaultAnimation(),
                    },
                })
            end
        end)
        -- rewind
        Isaac.GetPlayer(0):UseActiveItem(CollectibleType.COLLECTIBLE_GLOWING_HOUR_GLASS, false)
        runSave.SleightOfHand.Rewinded = true
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, onNewRoomEnter)

---@param player EntityPlayer
local function onPlayerUpdate(_, player)
    local runSave = SAVE_MANAGER.GetRunSave(nil, true)

    if runSave.SleightOfHand and runSave.SleightOfHand.ActivationCooldown >= 0 then
        if runSave.SleightOfHand.ActivationCooldown == 0 then
            -- depending on the room type, we have to do this because :ChangeRoom sometimes moves players to rooms on the opposite side????
            if runSave.SleightOfHand.TargetRoomSafeIndex < 0 then
                Game():GetLevel():ChangeRoom(runSave.SleightOfHand.TargetRoomSafeIndex) -- this is super buggy and just does not work properly on normal rooms
            else
                Isaac.ExecuteCommand("goto " .. runSave.SleightOfHand.TargetRoomCoords.X .. " " .. runSave.SleightOfHand.TargetRoomCoords.Y .. " " .. 0)
            end
        end
        runSave.SleightOfHand.ActivationCooldown = runSave.SleightOfHand.ActivationCooldown - 1
    end

    if runSave.SleightOfHand and runSave.SleightOfHand.EnteredNewRoom and not runSave.SleightOfHand.Rewinded then
        onNewRoomEnter()
        return
    end

    if runSave.SleightOfHand and SFXManager():IsPlaying(SFX_GLOWING_HOURGLASS_TELEPORT) then
        SFXManager():Stop(SFX_GLOWING_HOURGLASS_TELEPORT)
    end

    if runSave.SleightOfHand and runSave.SleightOfHand.Rewinded and player:HasCollectible(SLEIGHT_OF_HAND) and player.Index == runSave.SleightOfHand.PlayerIndex then
        local sprite = player:GetSprite()
        local animationName = sprite:GetAnimation()
        -- if pickup animation is playing we have to check if its the first time after using the item - then its definitely ghowing hourglass so we interrupt it
        if Resouled:IsPlayingPickupAnimation(player) then
            if not runSave.SleightOfHand.InterruptedGlowingHourglass then
                runSave.SleightOfHand.InterruptedGlowingHourglass = true
                player:AnimateCollectible(SLEIGHT_OF_HAND)

                -- we set the cooldown here to just now start the animation cooldown timer - look down for more info
                runSave.SleightOfHand.AnimationCooldown = PICKUP_ANIMATE_COOLDOWN

                -- we restore players to their original positions
                for i, playerPosition in ipairs(runSave.SleightOfHand.PlayerPositions) do
                    Isaac.GetPlayer(i-1).Position = playerPosition
                end

                -- we set charges to what they should be
                local activeSlot = Resouled:GetCollectibleActiveSlot(player, SLEIGHT_OF_HAND)
                player:SetActiveCharge(runSave.SleightOfHand.Charges.Normal, activeSlot)
                player:SetSoulCharge(runSave.SleightOfHand.Charges.Soul)
                player:SetBloodCharge(runSave.SleightOfHand.Charges.Blood)
            end
        elseif animationName == ANIMATION_TELEPORT_UP then
            -- speeding up the teleport animation
            sprite:SetFrame(ANIMATION_TELEPORT_UP, ANIMATION_TELEPORT_UP_FRAME_NUM)
        end

        -- animation cooldown clock, to stop the animation from playing too fast
        if runSave.SleightOfHand.AnimationCooldown then
            if runSave.SleightOfHand.AnimationCooldown == 0 then
                if #runSave.SleightOfHand.Pickups > 0 then
                    local pickup = runSave.SleightOfHand.Pickups[1]

                    runSave.SleightOfHand.AnimationCooldown = PICKUP_ANIMATE_COOLDOWN
                    -- its easier to use the build in method to animate collectibles so we do that
                    if pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE then
                        player:AnimateCollectible(pickup.SubType)
                    else
                        -- we load the animation and play it
                        local pickupSprite = Sprite()
                        pickupSprite:Load(pickup.Animation.File, true)
                        pickupSprite:Play(pickup.Animation.Name, true)
                        player:AnimatePickup(pickupSprite)
                    end
                    -- we remove the pickup from the list
                    table.remove(runSave.SleightOfHand.Pickups, 1)
                    SFXManager():Play(SFX_PICKUP_ANIM)
                else
                    -- if the list is empty we remove the sleight of hand data
                    runSave.SleightOfHand = nil
                    return
                end
            else
                -- we decrease the cooldown
                runSave.SleightOfHand.AnimationCooldown = runSave.SleightOfHand.AnimationCooldown - 1
            end
        end

        -- softlock prevention timeout clock
        if runSave.SleightOfHand.Timeout > 0 then
            runSave.SleightOfHand.Timeout = runSave.SleightOfHand.Timeout - 1
        else
            runSave.SleightOfHand = nil
            return
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, onPlayerUpdate)

local function onRender()
    if globalBlackoutIntensity then
        local screenDimensions = Vector(Isaac.GetScreenWidth(), Isaac.GetScreenHeight())
        BLACKOUT_SPRITE.Scale = screenDimensions / 16
        BLACKOUT_SPRITE.Color = Color(0, 0, 0, globalBlackoutIntensity)
        BLACKOUT_SPRITE:Render(screenDimensions / 2, Vector.Zero, Vector.Zero)
        
        GLOWING_DOOR_SPRITE.Color = Color(1, 1, 1, globalBlackoutIntensity)
        GLOWING_DOOR_SPRITE.Scale = Vector(1.3, 1.3)
        GLOWING_DOOR_SPRITE.Rotation = globalGlowingDoorRotation
        GLOWING_DOOR_SPRITE:Render(globalGlowingDoorPosition, Vector.Zero, Vector.Zero)

        globalBlackoutTimer = globalBlackoutTimer + 1

        if globalBlackoutTimer < BLACKOUT_TRANSITION_TIME then
            globalBlackoutIntensity = globalBlackoutIntensity + 1/BLACKOUT_TRANSITION_TIME
        elseif globalBlackoutTimer < BLACKOUT_TRANSITION_TIME + BLACKOUT_STAY_TIME then
        elseif globalBlackoutTimer < BLACKOUT_TRANSITION_TIME * 2 + BLACKOUT_STAY_TIME then
            globalBlackoutIntensity = globalBlackoutIntensity - 1/BLACKOUT_TRANSITION_TIME
        else
            globalBlackoutIntensity = nil
            globalBlackoutTimer = 0
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_RENDER, onRender)