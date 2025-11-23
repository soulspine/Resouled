-- room event per floor
-- cursed enemies morph chance

Resouled.OptionColors = {
    Positive = KColor(47/255/3, 27/255 * 3, 33/255/3, 1),
    Negative = KColor(47/255 * 2, 27/255/2, 33/255/2, 1)
}

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
        Step = 5,
        Min = 5,
        Max = 100,
    },
    {
        Achievement = nil,
        Name = "Room Events Per Chapter",
        DefaultValue = 1,
        Type = types.Integer,
        Step = 1,
        Min = 0,
        Max = 169, --13 x 13 max grid
    },
    {
        Achievement = nil,
        Name = "Base Room Event Num",
        DefaultValue = 2,
        Type = types.Integer,
        Step = 1,
        Min = 0,
        Max = 169 --13 x 13 map grid
    },
    {
        Achievement = nil,
        Name = "Custom Particle Amount",
        DefaultValue = "Max",
        StringOptions = {"Disabled", "Minimal", "Medium", "Max"},
        Type = types.OneClick
    },
    {
        Achievement = nil,
        Name = "Accurate Eternal Items",
        DefaultValue = "True",
        StringOptions = {"True", "False"},
        Type = types.OneClick
    },
    {
        Achievement = nil,
        Name = "Reset Mod Progress",
        DefaultValue = "Confirm",
        StringOptions = {"Confirm", "Are you sure?"},
        Type = types.OneClick,
        Color = Resouled.OptionColors.Negative,
        NotSelectedValue = "Confirm"
    },
    {
        Achievement = nil,
        Name = "Reset Settings To Default",
        DefaultValue = "Confirm",
        StringOptions = {"Confirm", "Are you sure?"},
        Type = types.OneClick,
        Color = Resouled.OptionColors.Negative,
        NotSelectedValue = "Confirm"
    },
    {
        Achievement = nil,
        Name = "Unlock All (Dev option, hide before uploading)",
        DefaultValue = "Confirm",
        StringOptions = {"Confirm", "Are you sure?"},
        Type = types.OneClick,
        Color = Resouled.OptionColors.Positive,
        NotSelectedValue = "Confirm"
    },
}

local loadedSave = false
local optionsSave

local OPTION_EFFECTS = {
    [Resouled.Options[6].Name.." "..Resouled.Options[6].StringOptions[2]] = function()
        local save = Resouled.StatTracker:GetSave()
        for key, _ in pairs(save) do
            save[key] = nil
        end
        Resouled:ClearBuffSave()
        Isaac.RunCallback(Resouled.Callbacks.StatsReset)
        Resouled.SaveManager.Save()
    end,
    [Resouled.Options[7].Name.." "..Resouled.Options[7].StringOptions[2]] = function()
        if loadedSave then
            for _, config in ipairs(Resouled.Options) do
                optionsSave[config.Name] = config.DefaultValue
                Resouled.SaveManager.Save()
            end
        end
    end,
    [Resouled.Options[8].Name.." "..Resouled.Options[8].StringOptions[2]] = function()
        local save = Resouled.StatTracker:GetSave()

        local buffs = Resouled:GetBuffs()
        if not save["Buffs Collected"] then save["Buffs Collected"] = {} end
        for _, buff in pairs(buffs) do
            local key = tostring(buff.Id)
            if not save["Buffs Collected"][key] then save["Buffs Collected"][key] = false end
            save["Buffs Collected"][key] = true
        end

        local roomEvents = Resouled:GetRoomEvents()
        if not save["Room Events Seen"] then save["Room Events Seen"] = {} end
        for _, roomEvent in pairs(roomEvents) do
            local key = tostring(roomEvent.Id)
            if not save["Room Events Seen"][key] then save["Room Events Seen"][key] = false end
            save["Room Events Seen"][key] = true
        end

        for _, stat in pairs(Resouled.StatTracker.Fields) do
            if not save[stat] then save[stat] = 0 end
        end
    end
}

local function loadOptions()
    if Resouled.SaveManager.IsLoaded() and not loadedSave then
        local save = Resouled.SaveManager.GetEntireSave()
        
        if not save["ResouledOptions"] then save["ResouledOptions"] = {} end
        save = save["ResouledOptions"]
        
        
        for _, config in ipairs(Resouled.Options) do
            save[config.Name] = save[config.Name] or config.DefaultValue
        end
        
        optionsSave = save
        loadedSave = true
        Isaac.RunCallback(Resouled.Callbacks.OptionsLoaded)
        Resouled.Save:AddToAutoSave(Resouled.SaveTypes.EntireSave, "ResouledOptions", function() return optionsSave end)
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

        if OPTION_EFFECTS[optionContainer.Name] then
            OPTION_EFFECTS[optionContainer.Name]()
        end

        if optionContainer.StringOptions then
            for i, stringValue in ipairs(optionContainer.StringOptions) do
                if stringValue == value then
                    if OPTION_EFFECTS[optionContainer.Name.." "..value] then
                        OPTION_EFFECTS[optionContainer.Name.." "..value]()
                    end
                    value = optionContainer.StringOptions[((i - 1 + stepMod) % #optionContainer.StringOptions) + 1]
                    break
                end
            end
        end
    end

    optionsSave[optionName] = value
    Resouled.SaveManager.Save()
    return true
end

---@param optionName string
---@param value any
function Resouled:SetOptionValue(optionName, value)
    optionsSave[optionName] = value
    Resouled.SaveManager.Save()
end

---@param optionName string
---@return any
function Resouled:GetOptionValue(optionName)
    if not optionsSave[optionName] then
        for _, container in ipairs(Resouled.Options) do
            if optionName == container.Name then
                optionsSave[optionName] = container.DefaultValue
                Resouled.SaveManager.Save()
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

---@return number
function Resouled:GetParticleCountModified()
    local modifier = optionsSave["Custom Particle Amount"] or "Max"
    if modifier == "Disabled" then return 0 end
    if modifier == "Minimal" then return 1/3 end
    if modifier == "Medium" then return 2/3 end
    if modifier == "Max" then return 1 end
    return 1
end
---@param min integer
---@param max integer
---@return integer
function Resouled:GetRandomParticleCount(min, max)
    local modifier = Resouled:GetParticleCountModified()
    min = math.floor(min * modifier + 0.5)
    max = math.floor(max * modifier + 0.5)
    return math.random(min, max)
end