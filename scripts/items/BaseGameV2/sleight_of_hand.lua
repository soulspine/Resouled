local SLEIGHT_OF_HAND = Isaac.GetItemIdByName("Sleight of Hand")

-- THIS WORKS LIKE THAT:
-- 1. GETS THE CLOSEST DOOR AND DETERMINES THE TARGET ROOM
-- 2. MOVES PLAYERS INTO THAT ROOM, SAVES DATA ABOUT ALL PICKUPS THERE AND SAVES CHARGE STATE
-- 3. MOVES PLAYERS BACK TO THE ORIGINAL ROOM BY USING GLOWING HOURGLASS WHILE SPEEDING UP THE TELEPORT ANIMATION TO SAVE 18 FRAMES
-- 4. ADJUSTS PLAYERS POSITIONS AND CHARGES
-- 5. ANIMATES PICKUPS OVER THE PLAYER THAT USED THE ITEM
-- 6. IF SOMETHING BREAKS, THERE IS A TIMEOUT THAT RESETS EVERYTHING BACK TO THE START

local TIMEOUT = 1000
local PICKUP_ANIMATE_COOLDOWN = 25

local ANIMATION_TELEPORT_UP = "TeleportUp"
local ANIMATION_TELEPORT_UP_FRAME_NUM = 19

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
        print("Sleight of Hand is on cooldown")
        return returnTable
    end

    local door = Resouled:GetClosestDoor(player.Position)

    if door then
        local game = Game()
        local level = game:GetLevel()
        local targetRoomSafeIndex = level:GetRoomByIdx(door.TargetRoomIndex).SafeGridIndex
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
            PlayerPositions = playerPositions,
            Pickups = {},
            Rewinded = false,
            PlayerIndex = player.Index,
            InterruptedGlowingHourglass = false,
            Timeout = TIMEOUT,
            EnteredNewRoom = false,
        }

        

        -- depending on the room type, we have to do this because :ChangeRoom sometimes moves players to rooms on the opposite side????
        if targetRoomSafeIndex < 0 then
            level:ChangeRoom(targetRoomSafeIndex) -- this is super buggy and just does not work properly on normal rooms
        else
            Isaac.ExecuteCommand("goto " .. targetRoomCoords.X .. " " .. targetRoomCoords.Y .. " " .. 0)
        end
    end
    return returnTable
end
Resouled:AddCallback(ModCallbacks.MC_USE_ITEM, onActiveUse, SLEIGHT_OF_HAND)

local function onNewRoomEnter()
    local runSave = SAVE_MANAGER.GetRunSave(nil, true)
    if runSave.SleightOfHand then
        runSave.SleightOfHand.EnteredNewRoom = true
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
    --print(runSave.SleightOfHand)

    if runSave.SleightOfHand and runSave.SleightOfHand.EnteredNewRoom and not runSave.SleightOfHand.Rewinded then
        onNewRoomEnter()
        return
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