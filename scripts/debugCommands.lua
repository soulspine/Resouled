local debugMode = false
local commands = {}
local commandsSorted = {}
local font = Font()
font:Load("font/pftempestasevencondensed.fnt")
local BIND_TEXT_STEP = font:GetBaselineHeight()
local textScale = 0.5
local expanded = false
local expandCooldown = 0
local expandColor = KColor(1, 1, 1, 1)
local oneRGBeffectCycle = 1530 -- 255 * 6
local commandCooldown = 5

---@param x KColor
---@param offset integer
---@return KColor
local function RGBeffect(x, offset)
    local r = math.floor(x.Red * 255)
    local g = math.floor(x.Green * 255)
    local b = math.floor(x.Blue * 255)
    offset = math.floor(offset)

    for _ = 1, offset do
        if r == 255 and g < 255 and b == 0 then
            g = math.min(g + 1, 255)
        elseif g == 255 and r > 0 and b == 0 then
            r = math.max(r - 1, 0)
        elseif g == 255 and b < 255 and r == 0 then
            b = math.min(b + 1, 255)
        elseif b == 255 and g > 0 and r == 0 then
            g = math.max(g - 1, 0)
        elseif b == 255 and r < 255 and g == 0 then
            r = math.min(r + 1, 255)
        elseif r == 255 and b > 0 and g == 0 then
            b = math.max(b - 1, 0)
        end
    end

    return KColor(r/255, g/255, b/255, x.Alpha)
end

Resouled:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function()
    debugMode = Resouled:GetOptionValue("Dev mode") == "Enabled"
end)

---@param bind Keyboard
---@param bindText string
---@param description string
---@param func function
local function addCommand(bind, bindText, description, func)
    commands[bind] = { BindText = bindText, Func = func, Description = description, Cooldown = 0 }
    table.insert(commandsSorted, bind)
end

addCommand(Keyboard.KEY_BACKSPACE, "Backspace", "Luamod", function()
    Isaac.ExecuteCommand("luamod resouled")
end)

addCommand(Keyboard.KEY_1, "1", "Toggle Debug 1", function()
    Isaac.ExecuteCommand("debug 1")
end)

addCommand(Keyboard.KEY_2, "2", "Toggle Debug 2", function()
    Isaac.ExecuteCommand("debug 2")
end)

addCommand(Keyboard.KEY_3, "3", "Toggle Debug 3", function()
    Isaac.ExecuteCommand("debug 3")
end)

addCommand(Keyboard.KEY_4, "4", "Toggle Debug 4", function()
    Isaac.ExecuteCommand("debug 4")
end)

addCommand(Keyboard.KEY_5, "5", "Toggle Debug 5", function()
    Isaac.ExecuteCommand("debug 5")
end)

addCommand(Keyboard.KEY_6, "6", "Toggle Debug 6", function()
    Isaac.ExecuteCommand("debug 6")
end)

addCommand(Keyboard.KEY_7, "7", "Toggle Debug 7", function()
    Isaac.ExecuteCommand("debug 7")
end)

addCommand(Keyboard.KEY_8, "8", "Toggle Debug 8", function()
    Isaac.ExecuteCommand("debug 8")
end)

addCommand(Keyboard.KEY_9, "9", "Toggle Debug 9", function()
    Isaac.ExecuteCommand("debug 9")
end)

addCommand(Keyboard.KEY_0, "0", "Toggle Debug 10", function()
    Isaac.ExecuteCommand("debug 10")
end)

addCommand(Keyboard.KEY_M, "M", "Kill all enemies in the room", function()
    Resouled.Iterators:IterateOverRoomNpcs(function(npc)
        if Resouled:IsValidEnemy(npc) then npc:Kill() end
    end)
end)

addCommand(Keyboard.KEY_N, "N", "Respawn Room Enemies", function()
    Game():GetRoom():RespawnEnemies()
end)

addCommand(Keyboard.KEY_B, "B", "Godmode", function()
    Resouled.Iterators:IterateOverPlayers(function(player)
        for _ = 1, 10 do
            player:AddCollectible(CollectibleType.COLLECTIBLE_WOODEN_SPOON)
        end
        player:AddCollectible(CollectibleType.COLLECTIBLE_MIND)
        player:AddCollectible(CollectibleType.COLLECTIBLE_BLACK_CANDLE)
        player:AddCollectible(CollectibleType.COLLECTIBLE_MERCURIUS)
        player:AddCollectible(CollectibleType.COLLECTIBLE_POLAROID)
        player:AddCollectible(CollectibleType.COLLECTIBLE_NEGATIVE)
        player:AddCollectible(CollectibleType.COLLECTIBLE_KEY_PIECE_1)
        player:AddCollectible(CollectibleType.COLLECTIBLE_KEY_PIECE_2)
        player:AddCollectible(CollectibleType.COLLECTIBLE_KNIFE_PIECE_1)
        player:AddCollectible(CollectibleType.COLLECTIBLE_KNIFE_PIECE_2)
        Isaac.ExecuteCommand("debug 10")
        Isaac.ExecuteCommand("debug 3")
    end)
end)

addCommand(Keyboard.KEY_Z, "Z", "Rewind", function()
    Isaac.ExecuteCommand("rewind")
end)

addCommand(Keyboard.KEY_V, "V", "2 speed", function()
    Resouled.Iterators:IterateOverPlayers(function(player)
        for _ = 1, 10 do
            player:AddCollectible(CollectibleType.COLLECTIBLE_WOODEN_SPOON)
        end
    end)
end)

addCommand(Keyboard.KEY_X, "X", "Spawn Dummy", function()
    Game():Spawn(EntityType.ENTITY_DUMMY, 0, Game():GetRoom():GetCenterPos(), Vector.Zero, nil, 0, 1)
end)

addCommand(Keyboard.KEY_L, "L", "Open Doors", function()
    Resouled.Doors:ForceOpenDoors()
end)

addCommand(Keyboard.KEY_LEFT_BRACKET, "[", "Toggle Live Console", function()
    Resouled.LiveConsole:Toggle()
end)

addCommand(Keyboard.KEY_RIGHT_BRACKET, "]", "Clear Console", function()
    Isaac.ExecuteCommand("clear")
    print(Resouled:GetHour().." Console Cleared")
    print(" ")
end)


addCommand(Keyboard.KEY_J, "J", "Equip Room Testing Loudout", function()
    local stage = Resouled.AccurateStats:GetCurrentChapter()
    local level = Game():GetLevel()

    local isAltPath = level:IsAltStage()
    local sadOnionFromDifficulty = level:GetCurrentRoomDesc().Data.Difficulty >= 15
    
    Resouled.Iterators:IterateOverPlayers(function(p)
        if stage < 4 then
            if stage == 1 or (stage == 2 and not isAltPath) then
                if sadOnionFromDifficulty then
                    p:AddCollectible(CollectibleType.COLLECTIBLE_SAD_ONION)
                end
            else
                p:AddCollectible(CollectibleType.COLLECTIBLE_SAD_ONION)
                p:AddCollectible(CollectibleType.COLLECTIBLE_MEAT)
                if isAltPath then
                    p:AddCollectible(CollectibleType.COLLECTIBLE_CRICKETS_HEAD)
                end
            end
        else
            p:AddCollectible(CollectibleType.COLLECTIBLE_SAD_ONION)
            p:AddCollectible(CollectibleType.COLLECTIBLE_MEAT)
            if stage == 4 or stage > 6 then
                p:AddCollectible(CollectibleType.COLLECTIBLE_PENTAGRAM)
            end

            if stage > 4 then
                p:AddCollectible(CollectibleType.COLLECTIBLE_CRICKETS_HEAD)
            end
        end
    end)
end)

addCommand(Keyboard.KEY_H, "H", "Teleport To Boss Room", function()
    Isaac.GetPlayer():UseCard(Card.CARD_EMPEROR, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
end)

addCommand(Keyboard.KEY_R, "R", "New Run", function()
    Isaac.StartNewGame(
        Isaac.GetPlayer():GetPlayerType(),
        Isaac.GetChallenge(),
        Game():GetChallengeParams():GetDifficulty(),
        Random()
    )
end)


Console.RegisterCommand("resouledDebug", "Toggles resouled debug mode", "", false, AutocompleteType.NONE)

Resouled:AddCallback(ModCallbacks.MC_EXECUTE_CMD, function(_, name)
    if name ~= "resouledDebug" then return end
    debugMode = not debugMode
    print("Resouled Debug mode active: " .. tostring(debugMode))
end)

local textColor = KColor(1, 1 ,1 ,1)
local currentTextColor = KColor(1, 1, 1, 1)
Resouled:AddCallback(ModCallbacks.MC_POST_HUD_RENDER, function()
    if not debugMode then return end

    local pos = Vector.Zero

    font:DrawStringScaled(
        "[ L Alt ]: Toggle bind list" .. (expandCooldown == 0 and "" or " *"),
        pos.X,
        pos.Y * textScale,
        textScale,
        textScale,
        expandColor
    )

    pos.Y = pos.Y + BIND_TEXT_STEP

    if expanded then
        local screenHeight = Isaac.GetScreenHeight()
        textColor.Red = 1
        textColor.Green = 0
        textColor.Blue = 0

        local maxWidth = 0

        for _, bind in ipairs(commandsSorted) do
            local command = commands[bind]

            currentTextColor.Red = 0.5 + 0.5 * textColor.Red
            currentTextColor.Green = 0.5 + 0.5 * textColor.Green
            currentTextColor.Blue = 0.5 + 0.5 * textColor.Blue

            local text = "[ " .. command.BindText .. " ]: " .. command.Description .. (command.Cooldown == 0 and "" or " *")
            font:DrawStringScaled(
                text,
                pos.X,
                pos.Y * textScale,
                textScale,
                textScale,
                currentTextColor
            )
            maxWidth = math.max(maxWidth, font:GetStringWidth(text))
            textColor = RGBeffect(textColor, oneRGBeffectCycle/(#commandsSorted))

            pos.Y = pos.Y + BIND_TEXT_STEP

            if (pos.Y + BIND_TEXT_STEP) * textScale > screenHeight then
                pos.Y = 0
                pos.X = pos.X + (maxWidth + BIND_TEXT_STEP) * textScale
                maxWidth = 0
            end
        end
    end
end)


local checkedDebugMode = false
Resouled:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
    if not checkedDebugMode then
        debugMode = Resouled:GetOptionValue("Dev mode") == "Enabled"
        checkedDebugMode = true
    end

    if not debugMode then return end

    for bind, command in pairs(commands) do
        command.Cooldown = math.max(command.Cooldown - 1, 0)

        if Resouled:HasAnyonePressedButton(bind) and command.Cooldown == 0 then
            command.Func()
            command.Cooldown = commandCooldown
        end
    end

    expandCooldown = math.max(expandCooldown - 1, 0)
    if Resouled:HasAnyonePressedButton(Keyboard.KEY_LEFT_ALT) and expandCooldown == 0 then
        expanded = not expanded
        expandCooldown = commandCooldown
    end
end)