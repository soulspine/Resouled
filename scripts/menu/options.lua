-- room event per floor
-- cursed enemies morph chance

local types = {
    Float = "number",
    OneClick = "oneclick",
    Integer = "integer",
    Bool = "boolean",
    String = "string"
}

Resouled.Options = {
    {
        Achievement = Resouled.Enums.Achievements.CursedEnemies,
        Name = "Cursed Enemy Morph Chance",
        DefaultValue = 10,
        Type = types.Float,
        Suffix = "%",
        Step = 1,
        Min = 0,
        Max = 100,
    },
    {
        Achievement = nil,
        Name = "Room Events Per Chapter",
        DefaultValue = 1,
        Type = types.Integer,
        Step = 1,
        Min = 0,
        Max = nil,
    },
    {
        Achievement = nil,
        Name = "Base Room Event Num",
        DefaultValue = 2,
        Type = types.Integer,
        Step = 1,
        Min = 0,
        Max = nil
    },
    {
        Achievement = nil,
        Name = "Reset Mod Progress",
        DefaultValue = "Confirm",
        StringOptions = {"Confirm"},
        Type = types.OneClick,
    }
}

Resouled.OptionColors = {
    Positive = KColor(0.3, 0.5, 0.3, 1),
    Negative = KColor(0.5, 0.3, 0.3, 1)
}


local loadedSave = false
local optionsSave

local function loadOptions()
    if SAVE_MANAGER.IsLoaded() and not loadedSave then
        
        local save = SAVE_MANAGER.GetPersistentSave()["ResouledOptions"]
        
        for _, config in ipairs(Resouled.Options) do
            save[config.Name] = save[config.Name] or config.DefaultValue
        end
        
        optionsSave = save
        loadedSave = true
        Isaac.RunCallback(Resouled.Callbacks.OptionsLoaded)
        SAVE_MANAGER.Save()
    end
end
Resouled:AddPriorityCallback(ModCallbacks.MC_MAIN_MENU_RENDER, CallbackPriority.IMPORTANT, loadOptions)
Resouled:AddPriorityCallback(ModCallbacks.MC_POST_RENDER, CallbackPriority.IMPORTANT, loadOptions)


--- Modifies the value of given option. Increment `true` will make it go up by value specified in StepValue while increment `false` will make it go down by the same amount
--- If modyfing a boolean value, inverts it. Ignores increment parameter
---@param optionName string
---@param increment? boolean default: true
---@return boolean
function Resouled:StepOptionValue(optionName, increment)
    increment = (increment == nil) and true or increment
    local stepMod = increment and 1 or -1

    local optionContainer = nil

    for i, container in ipairs(Resouled.Options) do
        if optionName == container.Name then
            optionContainer = Resouled.Options[i]
            break
        end
    end

    if not optionContainer then return false end
    

    local value = Resouled:GetOptionValue(optionName)
    local valType = type(value)

    if valType == types.Float or valType == types.Integer then
        value = value + (optionContainer.Step or 0) * stepMod
        if optionContainer.Max then
            value = math.min(optionContainer.Max, value)
        end

        if optionContainer.Min then
            value = math.max(optionContainer.Min, value)
        end
    elseif valType == types.Bool then
        value = not value
    elseif valType == types.String then
        if optionContainer.StringOptions then
            for i, stringValue in ipairs(optionContainer.StringOptions) do
                if stringValue == value then
                    value = optionContainer.StringOptions[((i - 1 + stepMod) % #optionContainer.StringOptions) + 1]
                    break
                end
            end
        end
    end

    optionsSave[optionName] = value
    SAVE_MANAGER.Save()
    return true
end

---@param optionName string
---@return any
function Resouled:GetOptionValue(optionName)
    if not optionsSave[optionName] then
        for _, container in ipairs(Resouled.Options) do
            if optionName == container.Name then
                optionsSave[optionName] = container.DefaultValue
                SAVE_MANAGER.Save()
                break
            end
        end
    end
    return optionsSave[optionName]
end

---@return table
function Resouled:GetOptionsSave()
    return optionsSave
end