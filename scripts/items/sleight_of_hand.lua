local SLEIGHT_OF_HAND = Isaac.GetItemIdByName("Sleight of Hand")

-- THIS WORKS LIKE THAT:
-- 1. GETS THE CLOSEST DOOR AND DETERMINES THE TARGET ROOM
-- 2. MOVES PLAYERS INTO THAT ROOM, SAVES DATA ABOUT ALL PICKUPS THERE AND SAVES CHARGE STATE
-- 3. MOVES PLAYERS BACK TO THE ORIGINAL ROOM BY USING GLOWING HOURGLASS WHILE SPEEDING UP THE TELEPORT ANIMATION TO SAVE 18 FRAMES
-- 4. ADJUSTS PLAYERS POSITIONS AND CHARGES
-- 5. ANIMATES PICKUPS OVER THE PLAYER THAT USED THE ITEM
-- 6. IF SOMETHING BREAKS, THERE IS A TIMEOUT THAT RESETS EVERYTHING BACK TO THE START

---@class restoreDoorInfo
---@field Slot DoorSlot
---@field Animation string
---@field Frame number
---@field Variant number
---@field IsOpen boolean

if EID then
    EID:addCollectible(SLEIGHT_OF_HAND,
        "Peeks into the closest room and makes Isaac hold all {{Coin}} pickups and {{Collectible}} items in that room#Usable only if current room is cleared#Cannot peek into uncleared Boss Rooms",
        "Sleight of Hand")
end

local TIMEOUT = 100
local PICKUP_ANIMATE_COOLDOWN = 20

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

-- if set to true, blackout will fade in and stay until its changed back to false and it starts to fade out
local blackoutFadeIn = false

-- DONT CHANGE
local globalBlackoutIntensity = nil
local globalBlockInputs = nil

local SFX_PICKUP_ANIM = SoundEffect.SOUND_FETUS_JUMP
local SFX_USE = SoundEffect.SOUND_UNLOCK00
local SFX_GLOWING_HOURGLASS_TELEPORT = SoundEffect.SOUND_HELL_PORTAL2 --sound that gets stopped when item is used

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

    local game = Game()

    -- we use global save to prevent multiple players from using it at the same time
    local runSave = SAVE_MANAGER.GetRunSave(nil, true)

    if runSave.SleightOfHand              -- this is here to prevent player from spamming it between time frame of glowing hourglass teleport and charge adjustment
        or not Game():GetRoom():IsClear() -- if there are enemies alive, we cannot use it
    then
        returnTable.ShowAnim = false
        return returnTable
    end

    local door = Resouled.Doors:GetClosestDoor(player.Position)

    if door then
        SFXManager():Play(SFX_USE)
        returnTable.Discharge = true
        local doorSprite = door:GetSprite()
        local level = game:GetLevel()
        local targetRoomDesc = level:GetRoomByIdx(door.TargetRoomIndex)

        if door.TargetRoomType == RoomType.ROOM_BOSS and not targetRoomDesc.Clear then -- dont use when boss room is not cleared
            return returnTable
        end

        local playerData = {}

        -- we save all player data to restore them back later
        Resouled.Iterators:IterateOverPlayers(function(player)
            playerData[tostring(player.Index)] = {
                Position = player.Position,
                EntityCollisionClass = player.EntityCollisionClass,
                GridCollisionClass = player.GridCollisionClass,
            }
        end)

        -- data needed for it to work, animation cooldown is purposefully not set here
        runSave.SleightOfHand = {
            TargetDoorPosition = door.Position,
            TargetDoorSlot = door.Slot,
            RestorePlayerData = playerData,
            RestoreDoorInfo = {
                Slot = door.Slot,
                Animation = doorSprite:GetAnimation(),
                Frame = doorSprite:GetFrame(),
                OverlayAnimation = doorSprite:GetOverlayAnimation(),
                OverlayFrame = doorSprite:GetOverlayFrame(),
                Variant = door:GetVariant(),
                IsOpen = door:IsOpen(),
                ExtraAnimation = door.ExtraSprite:GetAnimation(),
                ExtraFrame = door.ExtraSprite:GetFrame(),
                ExtraOverlayAnimation = door.ExtraSprite:GetOverlayAnimation(),
                ExtraOverlayFrame = door.ExtraSprite:GetOverlayFrame(),
                ExtraVisible = door.ExtraVisible,
                ExtraFilename = door.ExtraSprite:GetFilename(),
            },
            Pickups = {},
            PlayerIndex = player.Index,
            InterruptedGlowingHourglass = false,
            Timeout = TIMEOUT,
            Curses = level:GetCurses(),
            AnimationCooldown = nil,
            FirstTeleportCooldown = BLACKOUT_TRANSITION_TIME,
            TeleportBackCooldown = BLACKOUT_TRANSITION_TIME,
            RoomEnterCounter = 0,
            UsedHourglass = false,
            RestorationPerformed = false,
        }

        Resouled.Doors:ForceOpenDoor(door.Slot)

        -- remove curses so curse of the maze doesn't screw over displacements
        -- they are added back after the sequence
        level:RemoveCurses(runSave.SleightOfHand.Curses)

        blackoutFadeIn = true
        globalGlowingDoorPosition = Game():GetRoom():WorldToScreenPosition(door.Position)
        globalGlowingDoorRotation = door:GetSprite().Rotation
    end

    return returnTable
end
Resouled:AddCallback(ModCallbacks.MC_USE_ITEM, onActiveUse, SLEIGHT_OF_HAND)

local function postNewRoomEnter()
    local runSave = SAVE_MANAGER.GetRunSave(nil, true)
    if runSave.SleightOfHand then
        if runSave.SleightOfHand.RoomEnterCounter == 0 then
            -- saving pickups data
            Resouled.Iterators:IterateOverRoomPickups(function(pickup)
                local entitySprite = pickup:GetSprite()
                table.insert(runSave.SleightOfHand.Pickups, {
                    Variant = pickup.Variant,
                    SubType = pickup.SubType,
                    Animation = {
                        File = entitySprite:GetFilename(),
                        Name = entitySprite:GetDefaultAnimation(),
                    },
                })
            end)
        end
        runSave.SleightOfHand.RoomEnterCounter = runSave.SleightOfHand.RoomEnterCounter + 1
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, postNewRoomEnter)

local function onUpdate()
    local runSave = SAVE_MANAGER.GetRunSave(nil, true)

    if not runSave.SleightOfHand then
        blackoutFadeIn = false
        globalBlockInputs = nil
    else
        globalBlockInputs = runSave.SleightOfHand.PlayerIndex
    end

    local player = runSave.SleightOfHand and Game():GetPlayer(runSave.SleightOfHand.PlayerIndex) or nil
    if player then
        local sprite = player:GetSprite()
        local game = Game()
        local room = game:GetRoom()

        if not runSave.SleightOfHand.RestorationPerformed then
            if runSave.SleightOfHand.RoomEnterCounter == 0 then
                if runSave.SleightOfHand.FirstTeleportCooldown > 0 then
                    runSave.SleightOfHand.FirstTeleportCooldown = runSave.SleightOfHand.FirstTeleportCooldown - 1
                else
                    player.Position = runSave.SleightOfHand.TargetDoorPosition
                end
            elseif runSave.SleightOfHand.RoomEnterCounter == 1 then -- target room
                if runSave.SleightOfHand.TeleportBackCooldown > 0 then
                    runSave.SleightOfHand.TeleportBackCooldown = runSave.SleightOfHand.TeleportBackCooldown - 1
                    return
                end

                if not runSave.SleightOfHand.UsedHourglass then
                    runSave.SleightOfHand.UsedHourglass = true
                    player:UseActiveItem(CollectibleType.COLLECTIBLE_GLOWING_HOUR_GLASS)
                end
                -- REMOVE GLOWING HOURGLASS SFX
                if SFXManager():IsPlaying(SFX_GLOWING_HOURGLASS_TELEPORT) then
                    SFXManager():Stop(SFX_GLOWING_HOURGLASS_TELEPORT)
                end

                if sprite:GetAnimation() == ANIMATION_TELEPORT_UP then
                    sprite:SetFrame(ANIMATION_TELEPORT_UP, ANIMATION_TELEPORT_UP_FRAME_NUM)
                end
            elseif runSave.SleightOfHand.RoomEnterCounter == 2 then -- back to original room
                local door = room:GetDoor(runSave.SleightOfHand.TargetDoorSlot)

                if door then
                    local savedDoorInfo = runSave.SleightOfHand.RestoreDoorInfo
                    local doorSprite = door:GetSprite()

                    if door:IsOpen() ~= savedDoorInfo.IsOpen then
                        if savedDoorInfo.IsOpen then
                            door:Open()
                        else
                            door:Close()
                        end
                    end

                    if doorSprite:GetAnimation() ~= savedDoorInfo.Animation then
                        doorSprite:Play(savedDoorInfo.Animation, true)
                    end

                    if doorSprite:GetFrame() ~= savedDoorInfo.Frame then
                        doorSprite:SetFrame(savedDoorInfo.Frame)
                    end

                    if doorSprite:GetOverlayAnimation() ~= savedDoorInfo.OverlayAnimation then
                        doorSprite:SetOverlayAnimation(savedDoorInfo.OverlayAnimation)
                    end

                    if doorSprite:GetOverlayFrame() ~= savedDoorInfo.OverlayFrame then
                        doorSprite:SetOverlayFrame(savedDoorInfo.OverlayFrame)
                    end

                    door.ExtraVisible = savedDoorInfo.ExtraVisible
                    local extraSprite = door:GetExtraSprite()

                    if extraSprite:GetFilename() ~= savedDoorInfo.ExtraFilename then
                        extraSprite:Load(savedDoorInfo.ExtraFilename, true)
                    end

                    if extraSprite:GetAnimation() ~= savedDoorInfo.ExtraAnimation then
                        extraSprite:Play(savedDoorInfo.ExtraAnimation, true)
                    end

                    if extraSprite:GetFrame() ~= savedDoorInfo.ExtraFrame then
                        extraSprite:SetFrame(savedDoorInfo.ExtraFrame)
                    end

                    if extraSprite:GetOverlayAnimation() ~= savedDoorInfo.ExtraOverlayAnimation then
                        extraSprite:SetOverlayAnimation(savedDoorInfo.ExtraOverlayAnimation)
                    end

                    if extraSprite:GetOverlayFrame() ~= savedDoorInfo.ExtraOverlayFrame then
                        extraSprite:SetOverlayFrame(savedDoorInfo.ExtraOverlayFrame)
                    end

                    if door:GetVariant() ~= savedDoorInfo.Variant then
                        door:SetVariant(savedDoorInfo.Variant)
                    end
                end
                -- adding curses back
                if runSave.SleightOfHand.Curses > 0 then
                    local i = 1
                    while runSave.SleightOfHand.Curses > 0 do
                        if runSave.SleightOfHand.Curses & i == i then
                            Isaac.ExecuteCommand("curse " .. i)
                            runSave.SleightOfHand.Curses = runSave.SleightOfHand.Curses & ~i
                        end
                        i = i << 1
                    end
                end

                -- we restore players to their original positions and collision classes
                for playerIndexKey, playerInfo in pairs(runSave.SleightOfHand.RestorePlayerData) do
                    local player = game:GetPlayer(tonumber(playerIndexKey))
                    if player then
                        player.Position = playerInfo.Position and playerInfo.Position or player.Position
                        player.EntityCollisionClass = playerInfo.EntityCollisionClass
                        player.GridCollisionClass = playerInfo.GridCollisionClass
                    end
                end
                runSave.SleightOfHand.RestorationPerformed = true
                blackoutFadeIn = false
            end
        end

        -- this has to be here, not in upper if statement because animation does not start immediately, on first update
        -- if pickup animation is playing we have to check if its the first time after using the item - then its definitely glowing hourglass so we interrupt it
        if not runSave.SleightOfHand.InterruptedGlowingHourglass and runSave.SleightOfHand.RestorationPerformed and Resouled:IsPlayingPickupAnimation(player) then
            runSave.SleightOfHand.InterruptedGlowingHourglass = true
            player:AnimateCollectible(SLEIGHT_OF_HAND)

            -- we set the cooldown here to just now start the animation cooldown timer - look down for more info
            runSave.SleightOfHand.AnimationCooldown = PICKUP_ANIMATE_COOLDOWN
        end

        if runSave.SleightOfHand.AnimationCooldown then -- animation cooldown is nil before all teleports happen
            if runSave.SleightOfHand.AnimationCooldown > 0 then
                runSave.SleightOfHand.AnimationCooldown = runSave.SleightOfHand.AnimationCooldown - 1
            else -- pickup display sequence
                if #runSave.SleightOfHand.Pickups > 0 then
                    local pickup = runSave.SleightOfHand.Pickups[1]

                    runSave.SleightOfHand.AnimationCooldown = PICKUP_ANIMATE_COOLDOWN
                    -- its easier to use the built in method to animate collectibles and trinkets
                    if pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE then
                        player:AnimateCollectible(pickup.SubType)
                    elseif pickup.Variant == PickupVariant.PICKUP_TRINKET then
                        player:AnimateTrinket(pickup.SubType)
                    else
                        -- we load the animation and play it
                        local pickupSprite = Sprite()
                        pickupSprite:Load(pickup.Animation.File, true)
                        pickupSprite:Play(pickup.Animation.Name, true)
                        player:AnimatePickup(pickupSprite, true)
                    end
                    -- we remove the pickup from the list
                    table.remove(runSave.SleightOfHand.Pickups, 1)
                    SFXManager():Play(SFX_PICKUP_ANIM)
                else
                    -- if the list is empty we remove the sleight of hand data
                    runSave.SleightOfHand = nil
                end
            end
        else
            -- softlock prevention timeout clock
            if runSave.SleightOfHand.Timeout > 0 then
                runSave.SleightOfHand.Timeout = runSave.SleightOfHand.Timeout - 1
            else
                -- compensate for that it timed out and give charge back
                for i = 0, ActiveSlot.SLOT_POCKET2 do
                    local activeItem = player:GetActiveItem(i)
                    if activeItem == SLEIGHT_OF_HAND then
                        player:FullCharge(i)
                        break
                    end
                end

                runSave.SleightOfHand = nil
            end
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_UPDATE, onUpdate)

local function onRender()
    if globalBlackoutIntensity or blackoutFadeIn then
        local screenDimensions = Vector(Isaac.GetScreenWidth(), Isaac.GetScreenHeight())
        BLACKOUT_SPRITE.Scale = screenDimensions / 16
        BLACKOUT_SPRITE.Color = Color(0, 0, 0, globalBlackoutIntensity)
        BLACKOUT_SPRITE:Render(screenDimensions / 2, Vector.Zero, Vector.Zero)

        GLOWING_DOOR_SPRITE.Color = Color(1, 1, 1, globalBlackoutIntensity)
        GLOWING_DOOR_SPRITE.Scale = Vector(1.3, 1.3)
        GLOWING_DOOR_SPRITE.Rotation = globalGlowingDoorRotation
        GLOWING_DOOR_SPRITE:Render(globalGlowingDoorPosition, Vector.Zero, Vector.Zero)

        if globalBlackoutIntensity == nil then
            globalBlackoutIntensity = 0
        end

        if blackoutFadeIn then
            globalBlackoutIntensity = math.min(1, globalBlackoutIntensity + 1 / BLACKOUT_TRANSITION_TIME)
        else
            globalBlackoutIntensity = math.max(0, globalBlackoutIntensity - 1 / BLACKOUT_TRANSITION_TIME)
        end

        if globalBlackoutIntensity == 0 then
            globalBlackoutIntensity = nil
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_RENDER, onRender)

---@param entity Entity
---@param amount number
---@param damageFlags DamageFlag
---@param source EntityRef
---@param countdownFrames integer
local function onEntityTakeDamage(_, entity, amount, damageFlags, source, countdownFrames)
    local runSave = SAVE_MANAGER.GetRunSave(nil, true)
    if runSave.SleightOfHand and entity.Type == EntityType.ENTITY_PLAYER then
        return false -- prevent damage to player while sleight of hand is active
    end
end
Resouled:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, onEntityTakeDamage)

---@param entity Entity
---@param inputHook InputHook
---@param buttonAction ButtonAction
local function onActionInput(_, entity, inputHook, buttonAction)
    if not entity then return end

    if globalBlockInputs and entity.Type == EntityType.ENTITY_PLAYER and entity:ToPlayer().Index == globalBlockInputs and inputHook == InputHook.IS_ACTION_TRIGGERED then
        if buttonAction == ButtonAction.ACTION_DROP
            or buttonAction == ButtonAction.ACTION_ITEM then
            return false
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_INPUT_ACTION, onActionInput)
