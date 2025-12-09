local goals = {}
local goalsPicker = WeightedOutcomePicker()

---@class ResouledSocialGoalTask
---@field Callback ModCallbacks
---@field Func function

---@class ResouledSocialGoalConfig
---@field DisplayText string
---@field Tasks ResouledSocialGoalTask[]
---@field Goal function

---@return WeightedOutcomePicker
local function cloneOutcomePicker()
    local newPicker = WeightedOutcomePicker()
    for _, config in ipairs(goalsPicker:GetOutcomes()) do
        newPicker:AddOutcomeWeight(config.Value, config.Weight)
    end
    return newPicker
end

---@param config ResouledSocialGoalConfig
function Resouled:AddSocialGoal(config)
    table.insert(goals, config)
    goalsPicker:AddOutcomeWeight(#goals, 1)
end

local SOCIAL_GOALS = 3

local callbacksApplied = false
local activeCallbacks = {}

---@param save? table
local function applySocialGoalsCallbacks(save)
    if not callbacksApplied then
        save = save or Resouled.SaveManager.GetFloorSave()["Social Goals"] or {}
        
        for _, index in pairs(save) do
            ---@type ResouledSocialGoalConfig
            local config = goals[index]
            for _, taskConfig in pairs(config and config.Tasks or {}) do
                Resouled:AddCallback(taskConfig.Callback, taskConfig.Func)
                table.insert(activeCallbacks, {Callback = taskConfig.Callback, Func = taskConfig.Func})
            end
        end
    end

    callbacksApplied = true
end

local function removeSocialGoalsCallbacks()
    if callbacksApplied then
        for key, config in pairs(activeCallbacks) do
            Resouled:RemoveCallback(config.Callback, config.Func)
            activeCallbacks[key] = nil
        end
    end

    callbacksApplied = false
end

local function postNewFloor()
    if not Resouled:SocialGoalsPresent() then return end

    local goalsToAdd = {}

    local rng = Game():GetLevel():GetDevilAngelRoomRNG()

    local picker = cloneOutcomePicker()

    for _ = 1, SOCIAL_GOALS do
        local chosenGoal = picker:PickOutcome(rng)
        table.insert(goalsToAdd, chosenGoal)
        rng:SetSeed(rng:GetSeed() + 219425)
        picker:RemoveOutcome(chosenGoal)
    end

    Resouled.SaveManager.GetFloorSave()["Social Goals"] = goalsToAdd
    Resouled.SaveManager.GetFloorSave()["Social Goals Saves"] = {}


    applySocialGoalsCallbacks()
end
Resouled:AddPriorityCallback(ModCallbacks.MC_POST_NEW_LEVEL, CallbackPriority.LATE, postNewFloor)

Resouled:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, removeSocialGoalsCallbacks)
Resouled:AddPriorityCallback(ModCallbacks.MC_POST_NEW_LEVEL, CallbackPriority.IMPORTANT, removeSocialGoalsCallbacks)
Resouled:AddCallback(ModCallbacks.MC_POST_GAME_END, removeSocialGoalsCallbacks)
Resouled:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, removeSocialGoalsCallbacks)
Resouled:AddCallback(ModCallbacks.MC_MAIN_MENU_RENDER, removeSocialGoalsCallbacks)

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

    local save = Resouled.SaveManager.GetFloorSave()["Social Goals"] or {}

    for _, index in ipairs(save) do
        ---@type ResouledSocialGoalConfig
        local config = goals[index]

        fnt:DrawStringScaled(config.DisplayText, pos.X, pos.Y, textScale, textScale, textColor)
        local progress = config.Goal()
        fnt:DrawStringScaled("o   "..progress.Text, pos.X, pos.Y + sep, textScale, textScale, progress.Color)
        pos.Y = pos.Y + sep * 3
    end
end
Resouled:AddCallback(ModCallbacks.MC_POST_HUD_RENDER, postHudRender)