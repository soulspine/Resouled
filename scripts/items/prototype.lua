local CONFIG = {
    ItemName = "Prototype",
    FontPath = "font/teammeatfont16.fnt",
    TextScale = Vector(0.5, 0.5),
    InitialPositionOffset = Vector(0, -45),
    BetweenRowsSpacing = 15,
    NotSelectedString = "Unselected",
    NotSelectedColor = KColor(1, 0, 0, 1), -- red
    SelectedColor = KColor(1, 1, 1, 1),    -- white
    HighlightColor = KColor(1, 1, 0, 1),   -- yellow
    InputCooldown = 10,                    -- how many updates between input changes
    -- each option has a bitfield assinged to it representing the choice but they are hardcoded so adding new ones requires code changes
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
    MenuButtonActions = {
        Confirm = ButtonAction.ACTION_ITEM,
        Cancel = ButtonAction.ACTION_DROP,
    }
}

local CONSTANTS = {
    Items = {
        Dummy = Isaac.GetItemIdByName("Prototype"),
        Active = Isaac.GetItemIdByName("Prototype_Active"),
        Passive = Isaac.GetItemIdByName("Prototype_Passive"),
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
        local data = SAVE_MANAGER.GetRunSave(player).Prototype
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

    local data = SAVE_MANAGER.GetRunSave(player).Prototype
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

    local runSave = SAVE_MANAGER.GetRunSave(player)

    local slot = data.Slot
    local selections = data.Selections
    local inputVector = player:GetMovementInput() + player:GetShootingInput()
    local highlight = data.CurrentHighlight
    local numOptions = #CONFIG.OptionStrings[highlight]
    local numSelections = #selections
    local inputTolerance = 0.25

    -- cancel action
    if Input.IsActionPressed(CONFIG.MenuButtonActions.Cancel, player.ControllerIndex) then
        fullData.Resouled__PrototypeConfig = nil
        return
    end

    -- confirm action
    if Input.IsActionPressed(CONFIG.MenuButtonActions.Confirm, player.ControllerIndex) then
        local allSelectionsMade = true

        for _, selection in ipairs(selections) do
            if selection == 0 then
                allSelectionsMade = false
                break
            end
        end

        if allSelectionsMade then
            fullData.Resouled__PrototypeConfig = nil

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
--local background = Resouled:CreateLoadedSprite()

local boxWidth = 0

for _, optionList in ipairs(CONFIG.OptionStrings) do
    for _, optionString in ipairs(optionList) do
        boxWidth = math.max(boxWidth, math.ceil(font:GetStringWidth(optionString) * CONFIG.TextScale.X / 2))
    end
end

---@param player EntityPickup
---@param offset Vector
local function postPlayerRender(_, player, offset)
    local data = player:GetData().Resouled__PrototypeConfig
    if not data then return end

    local onScreenPos = Isaac.WorldToScreen(player.Position) + CONFIG.InitialPositionOffset - Vector(boxWidth / 2, 0)

    for i, selection in ipairs(data.Selections) do
        local text = CONFIG.NotSelectedString
        local color = CONFIG.NotSelectedColor

        if selection ~= 0 then
            text = CONFIG.OptionStrings[i][selection]
            color = CONFIG.SelectedColor
        end

        font:DrawStringScaled(text,
            onScreenPos.X, onScreenPos.Y,
            CONFIG.TextScale.X, CONFIG.TextScale.Y,
            color, boxWidth, true
        )

        if i == data.CurrentHighlight then
            local width = font:GetStringWidth(text) * CONFIG.TextScale.X / 2 * 1.2

            font:DrawStringScaled(
                "<",
                onScreenPos.X - width, onScreenPos.Y,
                CONFIG.TextScale.X, CONFIG.TextScale.Y,
                CONFIG.HighlightColor, boxWidth, true
            )
            font:DrawStringScaled(
                ">",
                onScreenPos.X + width, onScreenPos.Y,
                CONFIG.TextScale.X, CONFIG.TextScale.Y,
                CONFIG.HighlightColor, boxWidth, true
            )
        end

        onScreenPos.Y = onScreenPos.Y + CONFIG.BetweenRowsSpacing
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, postPlayerRender)

---@param pickup EntityPickup
local function handlePassiveDataTransferUponDrop_Init(_, pickup)
    if pickup.SubType ~= CONSTANTS.Items.Passive then return end
    local itemData = SAVE_MANAGER.GetRoomFloorSave(pickup).NoRerollSave
    Resouled.Iterators:IterateOverPlayers(function(player)
        local playerData = SAVE_MANAGER.GetRunSave(player).Prototype
        if not playerData then return end

        local itemHistory = player:GetHistory():GetCollectiblesHistory()

        local found = false
        local containerId = 0
        for _, container in ipairs(playerData) do
            containerId = containerId + 1
            local bitset = container.Bitset
            local time = container.Time

            for _, item in ipairs(itemHistory) do
                -- item history is not updated here yet so i can just do this
                if found then break end

                if item:GetTime() == time then
                    itemData.Prototype = bitset
                    found = true
                end
            end

            if found then break end
        end

        if found then
            table.remove(playerData, containerId)
            return
        end
    end)
    print(itemData.Prototype)
end
Resouled:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, handlePassiveDataTransferUponDrop_Init,
PickupVariant.PICKUP_COLLECTIBLE)

---@param pickup EntityPickup
---@param collider Entity
local function onPickupCollision(_, pickup, collider)

end
Resouled:AddCallback(ModCallbacks.MC_POST_PICKUP_COLLISION, onPickupCollision, PickupVariant.PICKUP_COLLECTIBLE)

---@param id CollectibleType
---@param player EntityPlayer
local function postAddCollectible(_, id, _, _, _, _, player)
    if id ~= CONSTANTS.Items.Passive then return end

    local data = player:GetData()
    if not data.Resouled_PrototypePickupSave then return end

    local runSave = SAVE_MANAGER.GetRunSave(player).Prototype
    if not runSave then runSave = {} end

    local collectibleHistory = player:GetHistory():GetCollectiblesHistory()

    for _, item in pairs(collectibleHistory) do
        if not runSave[tostring(item:GetTime())] then
            runSave[tostring(item:GetTime())] = data.Resouled_PrototypePickupSave
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, postAddCollectible)
