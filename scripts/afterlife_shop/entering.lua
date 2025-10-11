Resouled.AfterlifeShop.Goto = {
    Activate = false,
    PlayerType = nil,
    Difficulty = nil,
    SoulNum = nil,
    ReplaceMusic = false,
    SpecialBuffs = {}
}

---@param buffID ResouledBuff
function Resouled.AfterlifeShop:AddSpecialBuffToSpawn(buffID)
    table.insert(Resouled.AfterlifeShop.Goto.SpecialBuffs, buffID)
end

local black = Sprite()
black:Load("gfx/effects/blackout.anm2", true)
black:Play("Idle", true)

---@param isGameOver boolean
local function postGameEnd(_, isGameOver)
    
    local difficulty = Game().Difficulty
    
    if difficulty == Difficulty.DIFFICULTY_GREED then
        difficulty = Difficulty.DIFFICULTY_NORMAL
    elseif difficulty == Difficulty.DIFFICULTY_GREEDIER then
        difficulty = Difficulty.DIFFICULTY_HARD
    end
    
    if isGameOver == false then
        Resouled.AfterlifeShop.Goto.PlayerType = Isaac.GetPlayer():GetPlayerType()
        Resouled.AfterlifeShop.Goto.Difficulty = difficulty
        Resouled.AfterlifeShop.Goto.Activate = true
        Resouled.AfterlifeShop.Goto.SoulNum = Resouled:GetPossessedSoulsNum()
        Resouled.AfterlifeShop.Goto.ReplaceMusic = true
    else
        Resouled.AfterlifeShop.Goto.SpecialBuffs = {}
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_GAME_END, postGameEnd)

Resouled:AddCallback(ModCallbacks.MC_MAIN_MENU_RENDER, function()
    if Resouled.AfterlifeShop.Goto.Activate then
        local x = Isaac.GetScreenWidth()/2
        local y = Isaac.GetScreenHeight()/2

        black.Scale = Vector(x/8, y/8)

        black:Render(Vector(x, y))

        local RunParams = Resouled.AfterlifeShop.Goto
        Isaac.StartNewGame(RunParams.PlayerType, Challenge.CHALLENGE_NULL, RunParams.Difficulty)
    end
end)

local function postNewLevel()
    local level = Game():GetLevel()
    if not Resouled.AfterlifeShop:IsAfterlifeShop() and level:GetName() == "Afterlife" then
        level:SetName("")
    end
end
Resouled:AddPriorityCallback(ModCallbacks.MC_POST_NEW_LEVEL, CallbackPriority.LATE, postNewLevel)

local function postGameStarted()
    if Resouled.AfterlifeShop.Goto.Activate then
        Resouled.AfterlifeShop:SetAfterlifeShop()

        Game():GetLevel():SetStage(13, 1) -- Home (night)
        Isaac.ExecuteCommand("reseed")

        ---@param player EntityPlayer
        Resouled.Iterators:IterateOverPlayers(function(player)
            player:AnimateAppear()
        end)

        Game():GetLevel():SetName("Afterlife")

        Resouled:SetPossessedSoulsNum(Resouled.AfterlifeShop.Goto.SoulNum)
        Resouled.AfterlifeShop.Goto.SoulNum = nil
        Resouled.AfterlifeShop.Goto.Activate = false

        Resouled.AfterlifeShop:SetMapVisibility(false)
    else
        Resouled.AfterlifeShop.Goto.SpecialBuffs = {}
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, postGameStarted)

local COMMAND = {
    Name = "afterlife",
    Description = "Teleports you to Afterlife Shop",
}

Console.RegisterCommand(COMMAND.Name, COMMAND.Description, "", false, AutocompleteType.CUSTOM)

local function executeAfterlifeCommand(_, command, paramsRaw)
    if command == COMMAND.Name then
        if Isaac.IsInGame() then
            Resouled.AfterlifeShop:SetAfterlifeShop()
            Game():End(Ending.CREDITS)
        else
            Resouled:LogError("You need to be in a run to use this command!")
        end
    end
end
Resouled:AddCallback(ModCallbacks.MC_EXECUTE_CMD, executeAfterlifeCommand)