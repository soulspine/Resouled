local PIZZA_TIME = Isaac.GetChallengeIdByName("Pizza Time!")
local COSTUME = Isaac.GetCostumeIdByPath("gfx/characters/pizza_time.anm2")

local STARTING_SCORE = 1000000
local SCORE_LOSS_PER_SECOND = 1

-- displays
local SPEED_SCREEN_SPRITE = Sprite()
local SPEED_SCREEN_POSITION = function()
    return Vector(Isaac.GetScreenWidth() - 30, 30)
end
local SPEED_SCREEN_SCALE = Vector(0.5, 0.5)
local SPEED_SCREEN_ANIM_PATH = "gfx/effects/screen.anm2"

local SCORE_TEXT_POSITION = function()
    return Vector(Isaac.GetScreenWidth() - 33, 20)
end
local SCORE_TEXT_COLOR = KColor(1, 0, 0, 1)
local SCORE_TEXT_BOX_WIDTH = 5
local SCORE_TEXT_SCALE = Vector(0.6, 0.4)
local SCORE_TEXT_CENTER = true
local FONT = Font()
FONT:Load("font/teammeatfont16.fnt")
local globalScore = 0

---@param player EntityPlayer
local function onPlayerInit(_, player)
    if Isaac.GetChallenge() == PIZZA_TIME then
        player:AddNullCostume(COSTUME)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, onPlayerInit)

local function onNewFloor()
    if Isaac.GetChallenge() == PIZZA_TIME then
        Game():GetLevel():AddCurse(LevelCurse.CURSE_OF_THE_LOST, false)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, onNewFloor)

local function onUpdate()
    if Isaac.GetChallenge() == PIZZA_TIME then
        local runSave = SAVE_MANAGER.GetRunSave()

        if not runSave.PizzaTime then
            runSave.PizzaTime = {
                Score = STARTING_SCORE,
                Duration = 0,
            }
        else
            runSave.PizzaTime.Duration = runSave.PizzaTime.Duration + 1
            if runSave.PizzaTime.Duration % 30 == 0 then -- 30 because there are 30 updates / s
                runSave.PizzaTime.Score = math.max(0, runSave.PizzaTime.Score - SCORE_LOSS_PER_SECOND)
            end
        end

        if runSave.PizzaTime.Score == 0 then
            ---@param player EntityPlayer
            Resouled:IterateOverPlayers(function(player)
                player:Kill()
            end)
        end

        globalScore = runSave.PizzaTime.Score
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_UPDATE, onUpdate)

local function onRender()
    if Isaac.GetChallenge() == PIZZA_TIME then
        if not SPEED_SCREEN_SPRITE:IsLoaded() then
            SPEED_SCREEN_SPRITE:Load(SPEED_SCREEN_ANIM_PATH, true)
            SPEED_SCREEN_SPRITE.Scale = SPEED_SCREEN_SCALE
        end

        SPEED_SCREEN_SPRITE:PlayRandom(Random())
        SPEED_SCREEN_SPRITE:Update()
        
        SPEED_SCREEN_SPRITE:Render(SPEED_SCREEN_POSITION())

        local textPosition = SCORE_TEXT_POSITION()
        FONT:DrawStringScaled(tostring(globalScore), textPosition.X, textPosition.Y, SCORE_TEXT_SCALE.X, SCORE_TEXT_SCALE.Y, SCORE_TEXT_COLOR, SCORE_TEXT_BOX_WIDTH, SCORE_TEXT_CENTER)
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_RENDER, onRender)