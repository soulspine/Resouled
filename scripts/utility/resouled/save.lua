---@class ResouledSave
local save = {}

---@class ResouledSaveTypes
Resouled.SaveTypes = {
    FileSave = "File Save",
    EntireSave = "Entire Save"
}

local FRAMES_BETWEEN_AUTO_SAVE = 30000

local autoSaves = {}

---@param saveType ResouledSaveTypes | string
---@param entryKey string
---@param value function
function save:AddToAutoSave(saveType, entryKey, value)
    local Table = {
        Type = saveType,
        Key = entryKey,
        Value = value
    }
    table.insert(autoSaves, Table)
end

function save:ForceSave()
    Isaac.RunCallback(Resouled.Callbacks.AutoSave)
end

local function Save()
    if not Resouled.SaveManager:IsLoaded() then return end

    local entireSave = Resouled.SaveManager.GetEntireSave()
    local fileSave = Resouled.SaveManager.GetPersistentSave()
    for _, config in ipairs(autoSaves) do
        local value = config.Value()
        if config.Type == Resouled.SaveTypes.EntireSave then
            if not entireSave[config.Key] then entireSave[config.Key] = value else entireSave[config.Key] = value end
        else
            if fileSave then
                if not fileSave[config.Key] then fileSave[config.Key] = value else fileSave[config.Key] = value end
            end
        end
    end
    Resouled.SaveManager.Save()
end

local function autoSave()
    if Isaac.GetFrameCount() % FRAMES_BETWEEN_AUTO_SAVE == 0 then
        Isaac.RunCallback(Resouled.Callbacks.AutoSave)
    end
end

Resouled:AddCallback(Resouled.Callbacks.AutoSave, Save)
Resouled:AddCallback(ModCallbacks.MC_PRE_MOD_UNLOAD, Save)

Resouled:AddCallback(ModCallbacks.MC_POST_RENDER, autoSave)
Resouled:AddCallback(ModCallbacks.MC_MAIN_MENU_RENDER, autoSave)

return save