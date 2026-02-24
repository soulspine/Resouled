local CONFIG = {
    ItemName = "Prototype",
    FontPath = "font/teammeatfont16.fnt",
    InitialPositionOffset = Vector(0, -32),
    BetweenRowsSpacing = 15,
    NotSelectedString = "Unselected",
    NotSelectedColor = KColor(1, 0, 0, 1),
    SelectedColor = KColor(0, 0, 0, 1),
    HighlightColor = KColor(-1, 0.6, 0.6, 1),
    LabelColor = KColor(0.5, 0.5, 0.5, 1),
    InputCooldown = 10, -- how many updates between input changes
    -- each option has a bitfield assinged to it representing the choice but they are hardcoded so adding new ones requires code changes
    TextOpacityStep = 0.1,
    OptionStrings = {
        {
            "Upon entering a room",
            "Upon taking damage",
            "When the item is used"
        },
        {
            "Spawns two chests",
            "Grants 1-Room Heart",
            "Spawns six coins"
        },
        {
            "May break the item",
            "May deal damage",
            "Loses 1-3 pickups"
        },
    },
    MenuLabels = {
        Confirm = "Confirm",
        Cancel = "Cancel",
    },
    MenuOffsets = {
        ConfirmButton = Vector(15, 45),
        CancelButton = Vector(-52, 55),
        Rows = {
            Vector(17, -32),
            Vector(1, -4),
            Vector(8, 20),
        }
    },
    MenuScales = {
        ConfirmButton = Vector(0.7, 0.7),
        CancelButton = Vector(0.7, 0.7),
        Rows = {
            Vector(0.45, 0.45),
            Vector(0.6, 0.6),
            Vector(0.7, 0.7),
        }
    },
    MenuConfirmAction = ButtonAction.ACTION_ITEM,
    BackgroundScale = Vector(2.05, 1.95),
    BackgroundOffset = Vector(12, -10),
    BackgroundRotation = 0,
    BackgroundAnimations = {
        In = {
            Name = "FoldIn",
            FrameNum = 14
        },
        Out = {
            Name = "FoldOut",
            FrameNum = 14
        }
    },
    MenuOpacityStep = 0.2
}

local CONSTANTS = {
    Items = {
        Dummy = Resouled.Enums.Items.PROTOTYPE_DUMMY,
        Active = Resouled.Enums.Items.PROTOTYPE_ACTIVE,
        Passive = Resouled.Enums.Items.PROTOTYPE_PASSIVE,
    },
}

---@param player EntityPlayer
---@param bitset integer
---@param item CollectibleType
---@param slot? ActiveSlot
local function proc(player, bitset, item, slot)
    local game = Game()
    local rng = player:GetCollectibleRNG(item)

    -- this is up here because if you dont have pickups it wont work
    if bitset & (1 << 8) ~= 0 then -- may deal damage
        local pickupsToRemove = 3

        while pickupsToRemove > 0 do
            local amount = rng:RandomInt(1, pickupsToRemove + 1)

            local validTypes = {}
            if player:GetNumCoins() > 0 then
                table.insert(validTypes, PickupVariant.PICKUP_COIN)
            end

            if player:GetNumKeys() > 0 then
                table.insert(validTypes, PickupVariant.PICKUP_KEY)
            end

            if player:GetNumBombs() > 0 then
                table.insert(validTypes, PickupVariant.PICKUP_BOMB)
            end

            if player:GetPoopMana() > 0 then
                table.insert(validTypes, PickupVariant.PICKUP_POOP)
            end

            if player:GetBloodCharge() > 0 then
                table.insert(validTypes, PickupVariant.PICKUP_HEART)
            end

            if player:GetSoulCharge() > 0 then
                table.insert(validTypes, -1)
            end

            if #validTypes == 0 then
                return
            end

            local type = validTypes[rng:RandomInt(#validTypes) + 1]

            if type == PickupVariant.PICKUP_COIN then
                player:AddCoins(-amount)
            elseif type == PickupVariant.PICKUP_KEY then
                player:AddKeys(-amount)
            elseif type == PickupVariant.PICKUP_BOMB then
                player:AddBombs(-amount)
            elseif type == PickupVariant.PICKUP_HEART then
                player:AddBloodCharge(-amount)
            elseif type == -1 then -- soul heart charge
                player:AddSoulCharge(-amount)
            elseif type == PickupVariant.PICKUP_POOP then
                player:AddPoopMana(-amount)
            end
            pickupsToRemove = pickupsToRemove - amount
        end
    end

    if bitset & (1 << 3) ~= 0 then -- spawn 2 chests
        for _ = 1, 2 do
            game:Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_CHEST,
                Isaac.GetFreeNearPosition(player.Position, 10), Vector.Zero, player, 0,
                Resouled:NewSeed())
        end
    end

    if bitset & (1 << 4) ~= 0 then -- grants a temporary heart container
        Resouled.Player:Grant1RoomHeartContainer(player, false)
    end

    if bitset & (1 << 5) ~= 0 then -- spawn six coins
        for _ = 1, 6 do
            game:Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN,
                Isaac.GetFreeNearPosition(player.Position, 10), Vector.Zero, player, 1,
                Resouled:NewSeed())
        end
    end

    if bitset & (1 << 6) ~= 0 then -- may break the item
        if rng:RandomFloat() < 0.2 then
            player:RemoveCollectible(item, nil, slot)
        end
    end

    if bitset & (1 << 7) ~= 0 then -- may deal damage
        if rng:RandomFloat() < 0.2 then
            player:TakeDamage(1, 0, EntityRef(player), 10)
        end
    end

    -- only passives
    -- check if item got destroyed and remove the data field
    if item == CONSTANTS.Items.Passive then
        local runSave = Resouled.SaveManager.GetRunSave(player)
        local data = runSave.Prototype
        -- easy way, if 0 prototypes - remove the whole data field
        if player:GetCollectibleNum(CONSTANTS.Items.Passive) == 0 then
            runSave.Prototype = nil
        else
            -- otherwise we need to check if any of existing fields got removed
            local itemHistory = player:GetHistory():GetCollectiblesHistory()

            for i, container in ipairs(data) do
                local found = false
                for _, item in ipairs(itemHistory) do
                    if item:GetTime() == container.Time and item:GetItemID() == CONSTANTS.Items.Passive then
                        found = true
                        break
                    end

                    if item:GetTime() > container.Time then
                        break
                    end
                end

                if not found then
                    table.remove(data, i)
                end
            end
        end
    end
end

local function postGameStarted()
    local itemConfig = Isaac.GetItemConfig()
    itemConfig:GetCollectible(CONSTANTS.Items.Active).Name = CONFIG.ItemName
    itemConfig:GetCollectible(CONSTANTS.Items.Passive).Name = CONFIG.ItemName
    itemConfig:GetCollectible(CONSTANTS.Items.Dummy).Name = CONFIG.ItemName
end
Resouled:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, postGameStarted)

---@param item CollectibleType
---@param rng RNG
---@param player EntityPlayer
---@param flags UseFlag
---@param slot ActiveSlot
local function onRealActiveUse(_, item, rng, player, flags, slot)
    proc(player, player:GetActiveItemDesc(slot).VarData, item, slot)
end
Resouled:AddCallback(ModCallbacks.MC_USE_ITEM, onRealActiveUse, CONSTANTS.Items.Active)

---@param item CollectibleType
---@param rng RNG
---@param player EntityPlayer
---@param flags UseFlag
---@param slot ActiveSlot
---@param varData integer
local function onDummyActiveUse(_, item, rng, player, flags, slot, varData)
    local data = player:GetData()

    if data.Resouled__PrototypeConfig then return false end

    data.Resouled__PrototypeConfig = {
        Selections = {},
        CurrentHighlight = 1,
        Slot = slot,
        TextOpacity = 0,
        BgAnimation = CONFIG.BackgroundAnimations.Out.Name,
        BgFrame = 0,
        Selected = false,
        Cancelled = false,
        ReadyToDelete = false,
    }

    -- selection 0 translates to unselected in the menu, filling it up with them first
    for _, _ in ipairs(CONFIG.OptionStrings) do
        table.insert(data.Resouled__PrototypeConfig.Selections, 0)
    end

    return false
end
Resouled:AddCallback(ModCallbacks.MC_USE_ITEM, onDummyActiveUse, CONSTANTS.Items.Dummy)

local function procPostNewRoom()
    if not Game():GetRoom():IsFirstVisit() then return end
    Resouled.Iterators:IterateOverPlayers(function(player)
        local data = Resouled.SaveManager.GetRunSave(player).Prototype
        if not data then return end

        for _, container in ipairs(data) do
            local bitset = container.Bitset
            if (1 << 0) & bitset == 0 then return end
            proc(player, bitset, CONSTANTS.Items.Passive)
        end
    end)
end
Resouled:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, procPostNewRoom)

---@param entity Entity
---@param amount number
---@param flags DamageFlag
---@param source EntityRef
---@param countdown integer
local function procPostTakeDamage(_, entity, amount, flags, source, countdown)
    local player = entity:ToPlayer()
    if not player then return end

    local data = Resouled.SaveManager.GetRunSave(player).Prototype
    if not data then return end

    for _, container in ipairs(data) do
        local bitset = container.Bitset
        if (1 << 1) & bitset == 0 then return end
        proc(player, bitset, CONSTANTS.Items.Passive)
    end
end
Resouled:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, procPostTakeDamage)

---@param player EntityPlayer
local function postPlayerUpdate(_, player)
    local fullData = player:GetData()
    local data = fullData.Resouled__PrototypeConfig
    if not data then return end

    local slot = data.Slot
    local selections = data.Selections
    local inputVector = Resouled.Player:IsUsingGamepad(player) and player:GetMovementInput() or player:GetShootingInput()
    local highlight = data.CurrentHighlight
    local numOptions = highlight < 0 and 0 or #CONFIG.OptionStrings[highlight]
    local numSelections = #selections
    local inputTolerance = 0.25

    if data.ReadyToDelete then
        fullData.Resouled__PrototypeConfig = nil

        if data.Selected then
            local runSave = Resouled.SaveManager.GetRunSave(player)

            local bitset = 0
            local offset = 0
            for i, selection in ipairs(selections) do
                bitset = bitset + (1 << selection + offset - 1)
                offset = offset + #CONFIG.OptionStrings[i]
            end

            player:RemoveCollectible(CONSTANTS.Items.Dummy, nil, slot)
            if bitset & (1 << 2) ~= 0 then -- active
                -- active item procs effect based on vardata
                player:AddCollectible(CONSTANTS.Items.Active, nil, nil, slot)
                player:SetActiveVarData(bitset, slot)
            else -- passive
                -- passive item procs effect based on save field because there is no vardata tied to a non-active collectible
                player:AddCollectible(CONSTANTS.Items.Passive)

                local itemHistory = player:GetHistory():GetCollectiblesHistory()
                local newItem = itemHistory[#itemHistory]

                if not runSave.Prototype then
                    runSave.Prototype = {}
                end

                table.insert(runSave.Prototype, {
                    Time = newItem:GetTime(),
                    Bitset = bitset
                })
            end
        end
    end

    -- confirm action
    if data.CurrentHighlight == -1 and Input.IsActionPressed(CONFIG.MenuConfirmAction, player.ControllerIndex) then
        local allSelectionsMade = true

        for _, selection in ipairs(selections) do
            if selection == 0 then
                allSelectionsMade = false
                break
            end
        end

        if allSelectionsMade then
            data.Selected = true
        end
        return
    end

    -- cancel action, last in selections
    if data.CurrentHighlight == -2 and Input.IsActionPressed(CONFIG.MenuConfirmAction, player.ControllerIndex) then
        data.Cancelled = true
        return
    end

    if inputVector:Normalized():Length() < 0.3 then
        data.InputCooldown = nil
    end

    if data.InputCooldown then
        data.InputCooldown = data.InputCooldown - 1
        if data.InputCooldown <= 0 then
            data.InputCooldown = nil
        end
    end

    player:AddControlsCooldown(1)

    if inputVector:Length() == 0 or data.InputCooldown then goto skipDirectional end
    data.InputCooldown = CONFIG.InputCooldown

    -- normal selections
    if highlight > 0 then
        if inputVector.Y <= -inputTolerance then     -- up
            data.CurrentHighlight = highlight == 1 and -1 or (((highlight - 2) % numSelections) + 1)
        elseif inputVector.Y >= inputTolerance then  -- down
            data.CurrentHighlight = highlight == #selections and -1 or ((highlight % numSelections) + 1)
        elseif inputVector.X <= -inputTolerance then -- left
            selections[highlight] = ((selections[highlight] - 2) % numOptions) + 1
        elseif inputVector.X >= inputTolerance then  -- right
            selections[highlight] = (selections[highlight] % numOptions) + 1
        end
    else                                                      -- confirm (-1) / cancel (-2)
        if inputVector.Y <= -inputTolerance then              -- up
            data.CurrentHighlight = #selections
        elseif inputVector.Y >= inputTolerance then           -- down
            data.CurrentHighlight = 1
        elseif math.abs(inputVector.X) >= inputTolerance then -- left / right
            data.CurrentHighlight = -(math.abs(highlight) % 2 + 1)
        end
    end
    ::skipDirectional::
end
Resouled:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, postPlayerUpdate)

---@param player EntityPlayer
---@param newLevel boolean
local function removeContainerPreRoomExit(_, player, newLevel)
    player:GetData().Resouled__PrototypeConfig = nil
end
Resouled:AddCallback(ModCallbacks.MC_PRE_ROOM_EXIT, removeContainerPreRoomExit)

local font = Font()
font:Load(CONFIG.FontPath)

local background = Resouled:CreateLoadedSprite("gfx_resouled/ui/prototype_menu.anm2")
background.Scale = CONFIG.BackgroundScale
background.Rotation = CONFIG.BackgroundRotation
background.Offset = CONFIG.BackgroundOffset

---@param player EntityPlayer
---@param offset Vector
local function postPlayerRender(_, player, offset)
    local data = player:GetData().Resouled__PrototypeConfig
    if not data then return end

    local isaacPos = Isaac.WorldToScreen(player.Position)
    local textOnScreenPos = isaacPos + CONFIG.InitialPositionOffset

    if (data.Selected or data.Cancelled) and data.BgAnimation ~= CONFIG.BackgroundAnimations.In.Name then
        data.BgAnimation = CONFIG.BackgroundAnimations.In.Name
        data.BgFrame = 0
    end

    if not background:IsPlaying(data.BgAnimation) then
        background:Play(data.BgAnimation, true)
    end

    if not background:GetFrame() == data.BgFrame then
        background:SetFrame(data.BgFrame)
    end

    if Game():IsPaused() then goto noFrameAdvance end

    if data.BgAnimation == CONFIG.BackgroundAnimations.Out.Name then
        if data.BgFrame < CONFIG.BackgroundAnimations.Out.FrameNum - 1 then
            data.BgFrame = data.BgFrame + 1
            background:Update()
        end

        if data.BgFrame == CONFIG.BackgroundAnimations.Out.FrameNum - 1 then
            data.TextOpacity = math.min(1, data.TextOpacity + CONFIG.TextOpacityStep)
        end
    elseif data.BgAnimation == CONFIG.BackgroundAnimations.In.Name then
        data.TextOpacity = math.max(0, data.TextOpacity - CONFIG.TextOpacityStep)

        if data.BgFrame < CONFIG.BackgroundAnimations.In.FrameNum - 1 then
            data.BgFrame = data.BgFrame + 1
            background:Update()
        end

        if data.BgFrame == CONFIG.BackgroundAnimations.In.FrameNum - 1 then
            data.ReadyToDelete = true
        end
    end

    ::noFrameAdvance::

    background:Render(isaacPos)

    if data.TextOpacity > 0 then
        for i, selection in ipairs(data.Selections) do
            local text = CONFIG.NotSelectedString
            local color = CONFIG.NotSelectedColor

            if selection ~= 0 then
                text = CONFIG.OptionStrings[i][selection]
                color = CONFIG.SelectedColor
            end

            local rowPos = textOnScreenPos + CONFIG.MenuOffsets.Rows[i]
            local rowScale = CONFIG.MenuScales.Rows[i]
            local rowBoxWidth = math.floor(font:GetStringWidth(text) * rowScale.X)

            local highlightColor = CONFIG.HighlightColor
            highlightColor.Alpha = data.TextOpacity

            -- Adjust rowPos.X to center the text
            local centeredRowPosX = rowPos.X - rowBoxWidth / 2

            font:DrawStringScaled(text,
                centeredRowPosX, rowPos.Y,
                rowScale.X, rowScale.Y,
                color, 0, false
            )

            color.Alpha = data.TextOpacity

            if i == data.CurrentHighlight then
                -- Adjust arrow positions to be closer to the text
                local arrowOffset = 10 -- Adjust this value to control the arrow distance from the text
                font:DrawStringScaled(
                    "<",
                    centeredRowPosX - arrowOffset, rowPos.Y,
                    rowScale.X, rowScale.Y,
                    highlightColor, 0, false
                )
                font:DrawStringScaled(
                    ">",
                    centeredRowPosX + rowBoxWidth + arrowOffset - 4, rowPos.Y,
                    rowScale.X, rowScale.Y,
                    highlightColor, 0, false
                )
            end
        end

        -- somehow i got them mixed up, right is left and left is right

        local leftButtonPos = textOnScreenPos + CONFIG.MenuOffsets.ConfirmButton
        local rightButtonPos = textOnScreenPos + CONFIG.MenuOffsets.CancelButton

        local leftWidth = font:GetStringWidth(CONFIG.MenuLabels.Confirm) * CONFIG.MenuScales.ConfirmButton.X / 2 *
            CONFIG.MenuScales.ConfirmButton.X
        local rightWidth = font:GetStringWidth(CONFIG.MenuLabels.Cancel) * CONFIG.MenuScales.CancelButton.X / 2 *
            CONFIG.MenuScales.CancelButton.X

        local labelColor = CONFIG.LabelColor
        labelColor.Alpha = data.TextOpacity

        if data.CurrentHighlight < 0 then
            local selectedButtonScale = data.CurrentHighlight == -1 and CONFIG.MenuScales.ConfirmButton or
                CONFIG.MenuScales.CancelButton
            font:DrawStringScaled(
                ">",
                data.CurrentHighlight == -1 and (leftButtonPos.X - leftWidth) or (rightButtonPos.X - rightWidth),
                data.CurrentHighlight == -1 and leftButtonPos.Y or rightButtonPos.Y,
                selectedButtonScale.X, selectedButtonScale.Y,
                labelColor, 0, false
            )
        end

        font:DrawStringScaled(
            CONFIG.MenuLabels.Confirm,
            leftButtonPos.X, leftButtonPos.Y,
            CONFIG.MenuScales.ConfirmButton.X, CONFIG.MenuScales.ConfirmButton.Y,
            labelColor, 0, false
        )

        font:DrawStringScaled(
            CONFIG.MenuLabels.Cancel,
            rightButtonPos.X, rightButtonPos.Y,
            CONFIG.MenuScales.CancelButton.X, CONFIG.MenuScales.CancelButton.Y,
            labelColor, 0, false
        )
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, postPlayerRender)

---@param pickup EntityPickup
local function handlePassiveDataTransferUponDrop_FirstUpdate(_, pickup)
    if pickup.SubType ~= CONSTANTS.Items.Passive or pickup.FrameCount > 1 then return end
    local itemData = Resouled.SaveManager.GetRoomFloorSave(pickup).NoRerollSave
    Resouled.Iterators:IterateOverPlayers(function(player)
        local playerRunSave = Resouled.SaveManager.GetRunSave(player)
        local playerData = playerRunSave.Prototype
        if not playerData then return end

        local itemHistory = player:GetHistory():GetCollectiblesHistory()

        local found = false
        for i, container in ipairs(playerData) do
            local bitset = container.Bitset
            local time = container.Time

            for _, item in ipairs(itemHistory) do
                if item:GetTime() > time or found then break end
                if item:GetTime() == time and item:GetItemID() == CONSTANTS.Items.Passive then
                    found = true
                    break
                end
            end

            if not found then
                itemData.Prototype = bitset
                table.remove(playerData, i)

                if #playerData == 0 then
                    playerRunSave.Prototype = nil
                end
            end
        end
    end)
end
Resouled:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, handlePassiveDataTransferUponDrop_FirstUpdate,
    PickupVariant.PICKUP_COLLECTIBLE)

---@param pickup EntityPickup
---@param collider Entity
local function passiveCollisionBitsetTransfer(_, pickup, collider)
    if pickup.SubType ~= CONSTANTS.Items.Passive then return end
    local player = collider:ToPlayer()
    if not player then return end
    local itemSave = Resouled.SaveManager.GetRoomFloorSave(pickup).NoRerollSave
    if not itemSave.Prototype then return end

    local playerRunSave = Resouled.SaveManager.GetRunSave(player)

    if not playerRunSave.PrototypeQueue then
        playerRunSave.PrototypeQueue = {}
    end

    table.insert(playerRunSave.PrototypeQueue, itemSave.Prototype)
end
Resouled:AddCallback(ModCallbacks.MC_POST_PICKUP_COLLISION, passiveCollisionBitsetTransfer,
    PickupVariant.PICKUP_COLLECTIBLE)

---@param item CollectibleType
---@param charge integer
---@param firstTime boolean
---@param slot ActiveSlot
---@param varData integer
---@param player EntityPlayer
local function onPassiveGetPostCollision(_, item, charge, firstTime, slot, varData, player)
    if item ~= CONSTANTS.Items.Passive then return end
    local playerData = Resouled.SaveManager.GetRunSave(player)
    if not playerData.PrototypeQueue then return end

    local itemHistory = player:GetHistory():GetCollectiblesHistory()
    if not playerData.Prototype then
        playerData.Prototype = {}
    end

    table.insert(playerData.Prototype, {
        Time = itemHistory[#itemHistory]:GetTime(),
        Bitset = playerData.PrototypeQueue[1]
    })

    table.remove(playerData.PrototypeQueue, 1)

    if #playerData.PrototypeQueue == 0 then
        playerData.PrototypeQueue = nil
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, onPassiveGetPostCollision)
