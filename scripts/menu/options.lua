Resouled.Options = {
    [1] = "Start Notification",
    [2] = "Enable Room Events",
    [3] = "Unlock Whole Mod Content",
    [4] = "Reset Mod Progress"
}

local defaultValues = {
    [1] = "True",
    [2] = "True",
    [3] = "Confirm",
    [4] = "Confirm"
}

local optionsEffects = {
    [1] = function(save)
        local key = tostring(1)
        if save[key] == "True" then
            save[key] = "False"
        else
            save[key] = "True"
        end
    end,

    [2] = function(save)
        local key = tostring(2)
        if save[key] == "True" then
            save[key] = "False"
        else
            save[key] = "True"
        end
    end,

    [3] = function(save)

    end,

    [4] = function(save)
        local save1 = Resouled.StatTracker:GetSave()
        for key, _ in pairs(save1) do
            save1[key] = nil
        end
        Isaac.RunCallback(Resouled.Callbacks.StatsReset)
    end
}

local loadedSave = false
local optionsSave

local function loadOptions()
    if SAVE_MANAGER.IsLoaded() and not loadedSave then
        
        local save = SAVE_MANAGER.GetPersistentSave()["ResouledOptions"]
        
        for i, _ in ipairs(Resouled.Options) do
            local key = tostring(i)
            save[key] = save[key] or defaultValues[key]
        end

        optionsSave = save
        loadedSave = true
        Isaac.RunCallback(Resouled.Callbacks.OptionsLoaded)
    end
end
Resouled:AddPriorityCallback(ModCallbacks.MC_MAIN_MENU_RENDER, CallbackPriority.IMPORTANT, loadOptions)
Resouled:AddPriorityCallback(ModCallbacks.MC_POST_RENDER, CallbackPriority.IMPORTANT, loadOptions)

---@return table
function Resouled:GetOptionsSave()
    return optionsSave
end

---@param option integer
function Resouled:TriggerOption(option, save)
    if optionsEffects[option] then
        optionsEffects[option](save)
        SAVE_MANAGER.GetPersistentSave()["ResouledOptions"] = save
        SAVE_MANAGER.Save()
    end
end