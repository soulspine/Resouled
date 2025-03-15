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
local BLACKOUT_TRANSITION_TIME = 10
local BLACKOUT_STAY_TIME = 55
local globalBlackoutIntensity = nil
local globalBlackoutTimer = 0

local SFX_PICKUP_ANIM = SoundEffect.SOUND_FETUS_JUMP
local SFX_USE = SoundEffect.SOUND_UNLOCK00
local SFX_GLOWING_HOURGLASS_TELEPORT = SoundEffect.SOUND_HELL_PORTAL2

---@param player EntityPlayer
local function onPlayerInit(_, player)
    if player:GetPlayerType() == PlayerType.PLAYER_CAIN then
        player:AddCollectible(SLEIGHT_OF_HAND, 0, true, ActiveSlot.SLOT_PRIMARY, 0)
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
        returnTable.ShowAnim = false
        return returnTable
    end

    local door = Resouled:GetClosestDoor(player.Position)

    if door then
        returnTable.Discharge = true
        local game = Game()
        local level = game:GetLevel()
        local targetRoomDesc = level:GetRoomByIdx(door.TargetRoomIndex)

        if door.TargetRoomType == RoomType.ROOM_BOSS and not targetRoomDesc.Clear then
            return returnTable
        end

        local targetRoomSafeIndex = targetRoomDesc.SafeGridIndex
        local playerPositions = {}
        
        -- we save all player positions to move them back later
        ---@param player EntityPlayer
        Resouled:IterateOverPlayers(function(player)
            local position = player.Position
            table.insert(playerPositions, position)
        end)
        
        -- data needed for it to work, animation cooldown is purposefully not set here
        runSave.SleightOfHand = {
            TargetRoomSafeIndex = targetRoomSafeIndex,
            CurrentRoomSafeIndex = level:GetRoomByIdx(level:GetCurrentRoomIndex()).SafeGridIndex,
            PlayerPositions = playerPositions,
            Doors = Resouled:GetRoomDoors(),
            Pickups = {},
            PlayerIndex = player.Index,
            InterruptedGlowingHourglass = false,
            Timeout = TIMEOUT,
            NewRoomCount = 0,
            AddedGoatHead = false,
            Curses = level:GetCurses(),
        }

        Isaac.ExecuteCommand("curse 0")

        local allDoors = Resouled:GetRoomDoors()
        for _, door in ipairs(allDoors) do
            if (door.TargetRoomType == RoomType.ROOM_DEVIL or door.TargetRoomType == RoomType.ROOM_ANGEL) and not player:HasCollectible(CollectibleType.COLLECTIBLE_GOAT_HEAD) then
                runSave.SleightOfHand.AddedGoatHead = true
                player:AddCollectible(CollectibleType.COLLECTIBLE_GOAT_HEAD, 0, false)
                break
            end
        end

        globalBlackoutIntensity = 1/BLACKOUT_TRANSITION_TIME
        globalGlowingDoorPosition = Game():GetRoom():WorldToScreenPosition(door.Position)
        globalGlowingDoorRotation = door:GetSprite().Rotation
    end

    return returnTable
end
Resouled:AddCallback(ModCallbacks.MC_USE_ITEM, onActiveUse, SLEIGHT_OF_HAND)

local function onNewRoomEnter()
    local runSave = SAVE_MANAGER.GetRunSave(nil, true)

    if runSave.SleightOfHand then
        if runSave.SleightOfHand.NewRoomCount == 0 then
            SFXManager():Play(SFX_USE)
        elseif runSave.SleightOfHand.NewRoomCount == 1 then
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
        end
        runSave.SleightOfHand.NewRoomCount = runSave.SleightOfHand.NewRoomCount + 1
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, onNewRoomEnter)

---@param player EntityPlayer
local function onPlayerUpdate(_, player)
    local runSave = SAVE_MANAGER.GetRunSave(nil, true)
    local sprite = player:GetSprite()
    
    if runSave.SleightOfHand and runSave.SleightOfHand.PlayerIndex == player.Index then-- REMOVE GLOWIND HOURGLASS SFX
        if SFXManager():IsPlaying(SFX_GLOWING_HOURGLASS_TELEPORT) then
            SFXManager():Stop(SFX_GLOWING_HOURGLASS_TELEPORT)
        end

        -- softlock prevention timeout clock
        if runSave.SleightOfHand.Timeout > 0 then
            runSave.SleightOfHand.Timeout = runSave.SleightOfHand.Timeout - 1
        else
            runSave.SleightOfHand = nil
            return
        end

        if not Game():IsPaused() then
            local newRoomCount = runSave.SleightOfHand.NewRoomCount
            if newRoomCount <= 1 then -- 0 and 1
            
                local roomIndex = runSave.SleightOfHand.NewRoomCount == 0 and runSave.SleightOfHand.CurrentRoomSafeIndex or runSave.SleightOfHand.TargetRoomSafeIndex
                Game():StartRoomTransition(roomIndex, Direction.NO_DIRECTION, RoomTransitionAnim.WALK, player)
            elseif newRoomCount == 2 then
                player:UseActiveItem(CollectibleType.COLLECTIBLE_GLOWING_HOUR_GLASS)

                if sprite:GetAnimation() == ANIMATION_TELEPORT_UP then
                    sprite:SetFrame(ANIMATION_TELEPORT_UP, ANIMATION_TELEPORT_UP_FRAME_NUM)
                end
            elseif newRoomCount == 3 then
                if runSave.SleightOfHand.AddedGoatHead then
                    player:RemoveCollectible(CollectibleType.COLLECTIBLE_GOAT_HEAD)
                    runSave.AddedGoatHead = false
                end

                if runSave.SleightOfHand.Curses > 0 then
                    Isaac.ExecuteCommand("curse " .. runSave.SleightOfHand.Curses)
                    runSave.SleightOfHand.Curses = 0
                end

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
                    end
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
            end
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