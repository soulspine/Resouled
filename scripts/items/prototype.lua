local CONFIG = {
    ItemName = "Prototype",
    FontPath = "font/teammeatfont16.fnt",
    TextScale = Vector(0.5, 0.5),
    InitialPositionOffset = Vector(0, -32),
    BetweenRowsSpacing = 15,
    NotSelectedString = "Unselected",
    NotSelectedColor = KColor(1, 0, 0, 1),
    SelectedColor = KColor(0, 0, 0, 1),
    HighlightColor = KColor(0.3, 0.3, 0.3, 1),
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
            "Grants a Holy shield",
            "Spawns six coins"
        },
        {
            "May break the item",
            "May deal damage",
            "Loses 1-3 pickups"
        },
    },
    LabelButtonSpacing = 8,
    MenuButtonActions = {
        Confirm = {
            Label = "Confirm",
            Action = ButtonAction.ACTION_ITEM,
            ControllerAnimation = "LT",
            KeyboardButtonLabel = "SPACE"
        },
        Cancel = {
            Label = "Cancel",
            Action = ButtonAction.ACTION_DROP,
            ControllerAnimation = "RT",
            KeyboardButtonLabel = "CTRL"
        },
    },
    BackgroundScale = Vector(2.3, 1.75),
    BackgroundAnimations = {
        In = {
            Name = "FoldIn",
            FrameNum = 19
        },
        Out = {
            Name = "FoldOut",
            FrameNum = 19
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

    if bitset & (1 << 4) ~= 0 then -- spawns a holy shield
        player:GetEffects():AddCollectibleEffect(CollectibleType.COLLECTIBLE_HOLY_MANTLE)
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
    local inputVector = player:GetMovementInput() + player:GetShootingInput()
    local highlight = data.CurrentHighlight
    local numOptions = #CONFIG.OptionStrings[highlight]
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

    -- cancel action
    if Input.IsActionPressed(CONFIG.MenuButtonActions.Cancel.Action, player.ControllerIndex) then
        data.Cancelled = true
        return
    end

    -- confirm action
    if Input.IsActionPressed(CONFIG.MenuButtonActions.Confirm.Action, player.ControllerIndex) then
        local allSelectionsMade = true

        for _, selection in ipairs(selections) do
            if selection == 0 then
                allSelectionsMade = false
                break
            end
        end

        if allSelectionsMade then
            data.Selected = true
            return
        end
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

    if inputVector.Y <= -inputTolerance then     -- up
        data.CurrentHighlight = ((highlight - 2) % numSelections) + 1
    elseif inputVector.Y >= inputTolerance then  -- down
        data.CurrentHighlight = (highlight % numSelections) + 1
    elseif inputVector.X <= -inputTolerance then -- left
        selections[highlight] = ((selections[highlight] - 2) % numOptions) + 1
    elseif inputVector.X >= inputTolerance then  -- right
        selections[highlight] = (selections[highlight] % numOptions) + 1
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
local background = Resouled:CreateLoadedSprite("gfx/ui/prototype_menu.anm2")
background.Scale = CONFIG.BackgroundScale

local buttons = Resouled:CreateLoadedSprite("gfx/ui/prototype_keys.anm2")
local keycapParts = {
    Left = {
        Width = 4,
        Name = "KeycapLeft"
    },
    Right = {
        Width = 4,
        Name = "KeycapRight"
    },
    Middle = {
        Width = 8,
        Name = "KeycapMiddle"
    }
}

local boxWidth = 0

for _, optionList in ipairs(CONFIG.OptionStrings) do
    for _, optionString in ipairs(optionList) do
        boxWidth = math.max(boxWidth, math.ceil(font:GetStringWidth(optionString) * CONFIG.TextScale.X / 2))
    end
end

---@param player EntityPlayer
---@param offset Vector
local function postPlayerRender(_, player, offset)
    local data = player:GetData().Resouled__PrototypeConfig
    if not data then return end

    local isaacPos = Isaac.WorldToScreen(player.Position)
    local textOnScreenPos = isaacPos - Vector(boxWidth / 2, 0) + CONFIG.InitialPositionOffset

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

            local highlightColor = CONFIG.HighlightColor
            highlightColor.Alpha = data.TextOpacity

            font:DrawStringScaled(text,
                textOnScreenPos.X, textOnScreenPos.Y,
                CONFIG.TextScale.X, CONFIG.TextScale.Y,
                color, boxWidth, true
            )

            color.Alpha = data.TextOpacity

            if i == data.CurrentHighlight then
                local width = font:GetStringWidth(text) * CONFIG.TextScale.X / 2 * 1.2

                font:DrawStringScaled(
                    "<",
                    textOnScreenPos.X - width, textOnScreenPos.Y,
                    CONFIG.TextScale.X, CONFIG.TextScale.Y,
                    highlightColor, boxWidth, true
                )
                font:DrawStringScaled(
                    ">",
                    textOnScreenPos.X + width, textOnScreenPos.Y,
                    CONFIG.TextScale.X, CONFIG.TextScale.Y,
                    highlightColor, boxWidth, true
                )
            end

            textOnScreenPos.Y = textOnScreenPos.Y + CONFIG.BetweenRowsSpacing
        end

        textOnScreenPos.Y = textOnScreenPos.Y + CONFIG.BetweenRowsSpacing

        local buttonHeight = textOnScreenPos.Y - CONFIG.BetweenRowsSpacing / 2

        local leftButtonPos = Vector(textOnScreenPos.X - boxWidth / 2, buttonHeight)
        local rightButtonPos = Vector(textOnScreenPos.X + 1.5 * boxWidth, buttonHeight)

        buttons.Color.A = data.TextOpacity

        if Resouled.Player:IsUsingGamepad(player) then
            buttons:Play(CONFIG.MenuButtonActions.Confirm.ControllerAnimation, true)
            buttons:Render(leftButtonPos)

            buttons:Play(CONFIG.MenuButtonActions.Cancel.ControllerAnimation, true)
            buttons:Render(rightButtonPos)
        else
            -- single letter has width of 12 so this is the baseline for a scale 1 keycap
            local leftTextWidth = math.ceil(font:GetStringWidth(CONFIG.MenuButtonActions.Confirm.KeyboardButtonLabel) *
                CONFIG.TextScale.X)
            buttons:Play(keycapParts.Left.Name, true)
            buttons:Render(leftButtonPos)
            local oneCharWidth = math.ceil(12 * CONFIG.TextScale.X)
            local currentWidth = 0
            if leftTextWidth > oneCharWidth then
                buttons:Play(keycapParts.Middle.Name)
                for _ = 1, math.floor(leftTextWidth / oneCharWidth) do
                    buttons:Render(Vector(leftButtonPos.X + currentWidth, leftButtonPos.Y))
                    currentWidth = currentWidth + keycapParts.Middle.Width
                end
                currentWidth = currentWidth - keycapParts.Middle.Width / 2
            end
            buttons:Play(keycapParts.Right.Name, true)
            buttons:Render(Vector(leftButtonPos.X + currentWidth, leftButtonPos.Y))


            font:DrawStringScaled(
                CONFIG.MenuButtonActions.Confirm.KeyboardButtonLabel,
                leftButtonPos.X, leftButtonPos.Y - keycapParts.Middle.Width / 2,
                CONFIG.TextScale.X, CONFIG.TextScale.Y / 2,
                KColor(0, 0, 0, data.TextOpacity), leftTextWidth, true
            )


            local rightTextWidth = math.ceil(font:GetStringWidth(CONFIG.MenuButtonActions.Cancel.KeyboardButtonLabel) *
                CONFIG.TextScale.X)
            buttons:Play(keycapParts.Right.Name, true)
            buttons:Render(rightButtonPos)
            local currentWidth = 0
            if rightTextWidth > oneCharWidth then
                buttons:Play(keycapParts.Middle.Name)
                for _ = 1, math.floor(rightTextWidth / oneCharWidth) do
                    buttons:Render(Vector(rightButtonPos.X - currentWidth, rightButtonPos.Y))
                    currentWidth = currentWidth + keycapParts.Middle.Width
                end
                currentWidth = currentWidth - keycapParts.Middle.Width / 2
            end
            buttons:Play(keycapParts.Left.Name, true)
            buttons:Render(Vector(rightButtonPos.X - currentWidth, rightButtonPos.Y))


            font:DrawStringScaled(
                CONFIG.MenuButtonActions.Cancel.KeyboardButtonLabel,
                rightButtonPos.X - currentWidth, rightButtonPos.Y - keycapParts.Middle.Width / 2,
                CONFIG.TextScale.X, CONFIG.TextScale.Y / 2,
                KColor(0, 0, 0, data.TextOpacity), rightTextWidth, true
            )

            print(rightTextWidth, leftTextWidth)
        end

        local labelColor = CONFIG.LabelColor
        labelColor.Alpha = data.TextOpacity

        font:DrawStringScaled(
            CONFIG.MenuButtonActions.Confirm.Label,
            leftButtonPos.X - CONFIG.LabelButtonSpacing, textOnScreenPos.Y,
            CONFIG.TextScale.X, CONFIG.TextScale.Y,
            labelColor, 0, false
        )

        font:DrawStringScaled(
            CONFIG.MenuButtonActions.Cancel.Label,
            rightButtonPos.X + CONFIG.LabelButtonSpacing - boxWidth, textOnScreenPos.Y,
            CONFIG.TextScale.X, CONFIG.TextScale.Y,
            labelColor, boxWidth, false
        )
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, postPlayerRender)

---@param pickup EntityPickup
local function handlePassiveDataTransferUponDrop_FirstUpdate(_, pickup)
    if pickup.FrameCount > 1 then return end
    if pickup.SubType ~= CONSTANTS.Items.Passive then return end
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

    for _, field in ipairs(playerData.Prototype) do
        print(field.Time, field.Bitset)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, onPassiveGetPostCollision)
