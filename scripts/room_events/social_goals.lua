local goals = {}
local goalsPicker = WeightedOutcomePicker()

---@class ResouledSocialGoalTask
---@field Callback ModCallbacks
---@field Func function

---@class ResouledSocialGoalConfig
---@field DisplayText string
---@field Tasks ResouledSocialGoalTask[]
---@field Goal function

---@param config ResouledSocialGoalConfig
function Resouled:AddSocialGoal(config)
    table.insert(goals, config)
    goalsPicker:AddOutcomeWeight(#goals, 1)
end

local function getSocialGoals()
    return Resouled.SaveManager.GetFloorSave()["Social Goals"]
end

local SOCIAL_GOALS = 3

local callbacksApplied = false

---@param save? table
local function applySocialGoalsCallbacks(save)
    if not callbacksApplied then
        
        save = save or Resouled.SaveManager.GetFloorSave()["Social Goals"]
        
        ---@param config ResouledSocialGoalConfig
        for _, config in pairs(save or {}) do
            for _, taskConfig in pairs(config.Tasks or {}) do
                Resouled:AddCallback(taskConfig.Callback, taskConfig.Func)
            end
        end
    end

    callbacksApplied = true
end

---@param save? table
local function removeSocialGoalsCallbacks(save)
    if callbacksApplied then
        
        save = save or Resouled.SaveManager.GetFloorSave()["Social Goals"]
        
        ---@param config ResouledSocialGoalConfig
        for _, config in pairs(save or {}) do
            for _, taskConfig in pairs(config.Tasks or {}) do
                Resouled:RemoveCallback(taskConfig.Callback, taskConfig.Func)
            end
        end
    end

    callbacksApplied = false
end

local function postNewFloor()
    if not Resouled:SocialGoalsPresent() then return end

    local goalsToAdd = {}

    local rng = Game():GetLevel():GetDevilAngelRoomRNG()

    for _ = 1, SOCIAL_GOALS do
        table.insert(goalsToAdd, goals[goalsPicker:PickOutcome(rng)])
        rng:SetSeed(rng:GetSeed() + 219425)
    end

    Resouled.SaveManager.GetFloorSave()["Social Goals"] = goalsToAdd

    applySocialGoalsCallbacks()
end
Resouled:AddPriorityCallback(ModCallbacks.MC_POST_NEW_LEVEL, CallbackPriority.LATE, postNewFloor)

local function preGameExit()
    removeSocialGoalsCallbacks()
end
Resouled:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, preGameExit)

local function postUpdate()
    if Resouled:SocialGoalsPresent() and not callbacksApplied then
        applySocialGoalsCallbacks()
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_RENDER, postUpdate)



local fnt = Font()
fnt:Load("font/pftempestasevencondensed.fnt")
local textColor = KColor(1, 1, 1, 1)
local textScale = 0.5

local function postHudRender()
    if not callbacksApplied then return end

    local pos = Vector(50, 50)

    local sep = fnt:GetBaselineHeight() * textScale

    ---@param config ResouledSocialGoalConfig
    for _, config in ipairs(getSocialGoals() or {}) do
        fnt:DrawStringScaled(config.DisplayText, pos.X, pos.Y, textScale, textScale, textColor)
        local progress = config.Goal()
        fnt:DrawStringScaled(progress.Text, pos.X, pos.Y + sep, textScale, textScale, progress.Color)
        pos.Y = pos.Y + sep * 3
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_HUD_RENDER, postHudRender)