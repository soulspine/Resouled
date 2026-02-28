local debugMode = false
local commands = {}
local font = Font()
font:Load("font/pftempestasevencondensed.fnt")
local BIND_TEXT_STEP = font:GetBaselineHeight()
local textColor = KColor(1, 1, 1, 1)
local textScale = 0.5

Resouled:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function()
    debugMode = Resouled:GetOptionValue("Dev mode") == "Enabled"
end)

---@param bind Keyboard
---@param bindText string
---@param description string
---@param func function
local function addCommand(bind, bindText, description, func)
    commands[bind] = { BindText = bindText, Func = func, Description = description, Cooldown = 0 }
end

addCommand(Keyboard.KEY_M, "M", "Toggles Debug 10", function()
    Isaac.ExecuteCommand("debug 10")
end)

addCommand(Keyboard.KEY_N, "N", "Kills all enemies in the room", function()
    Resouled.Iterators:IterateOverRoomNpcs(function(npc)
        if Resouled:IsValidEnemy(npc) then npc:Kill() end
    end)
end)

addCommand(Keyboard.KEY_B, "B", "2 speed", function()
    Resouled.Iterators:IterateOverPlayers(function(player)
        for _ = 1, 10 do
            player:AddCollectible(CollectibleType.COLLECTIBLE_WOODEN_SPOON)
        end
    end)
end)

addCommand(Keyboard.KEY_V, "V", "Godmode", function()
    Resouled.Iterators:IterateOverPlayers(function(player)
        for _ = 1, 10 do
            player:AddCollectible(CollectibleType.COLLECTIBLE_WOODEN_SPOON)
        end
        player:AddCollectible(CollectibleType.COLLECTIBLE_MIND)
        Isaac.ExecuteCommand("debug 10")
        Isaac.ExecuteCommand("debug 3")
    end)
end)

addCommand(Keyboard.KEY_C, "C", "Rewind", function()
    Isaac.ExecuteCommand("rewind")
end)

addCommand(Keyboard.KEY_X, "X", "Respawn Room Enemies", function()
    Game():GetRoom():RespawnEnemies()
end)



Console.RegisterCommand("resouledDebug", "Toggles resouled debug mode", "", false, AutocompleteType.NONE)

Resouled:AddCallback(ModCallbacks.MC_EXECUTE_CMD, function(_, name)
    if name ~= "resouledDebug" then return end
    debugMode = not debugMode
    print("Resouled Debug mode active: " .. tostring(debugMode))
end)

Resouled:AddCallback(ModCallbacks.MC_POST_HUD_RENDER, function()
    if not debugMode then return end

    local pos = Vector.Zero

    for _, command in pairs(commands) do
        font:DrawStringScaled(
            command.BindText .. " (c: " .. command.Cooldown .. ")" .. ": " .. command.Description,
            pos.X,
            pos.Y * textScale,
            textScale,
            textScale,
            textColor
        )
        pos.Y = pos.Y + BIND_TEXT_STEP
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
            command.Cooldown = 30
        end
    end
end)
