---@diagnostic disable: param-type-mismatch
local CONFIG = {
    TopString = "Resouled Menu",
    TextColor = KColor(55/255, 43/255, 45/255, 1),
    HighlightColor = KColor(1, 0, 0, 1),
    ButtonActions = {
        Keyboard = {
            Enter = ButtonAction.ACTION_BOMB,
            Leave = ButtonAction.ACTION_MENUBACK,
            Up = ButtonAction.ACTION_PILLCARD,
            Down = ButtonAction.ACTION_BOMB,
        },
        Gamepad = {
            Enter = ButtonAction.ACTION_BOMB,
            Leave = ButtonAction.ACTION_MENUBACK,
            Up = ButtonAction.ACTION_PILLCARD,
            Down = ButtonAction.ACTION_BOMB,
        },
    },
    BackgroundSpriteSize = Vector(350, 200),
    CustomMenuType = 444,
    MaxStatWidth = 250,
    StatOffset = Vector(8, -70),
    PageOffset = Vector(510, 215),
    ViewportOffset = Vector(-39.5, -169.5),
    StatVerticalSpacing = 3,
    LineOffset = 25

}

local FONTS = {
    Size10 = Font(),
    Size12 = Font(),
    Size16 = Font(),
    Size20 = Font()
}

FONTS.Size10:Load("font/teammeatfont10.fnt")
FONTS.Size12:Load("font/teammeatfont12.fnt")
FONTS.Size16:Load("font/teammeatfont16.fnt")
FONTS.Size20:Load("font/teammeatfont20bold.fnt")

local BUFFS = {}
Resouled:RunAfterImports(function()
    local i = 0
    while Resouled:GetBuffFamilyById(i) do
        local family = Resouled:GetBuffFamilyById(i)

        local specialFamily = false

        for _, childBuffId in pairs(family.ChildBuffs) do
            local buff = Resouled:GetBuffById(childBuffId)
            if buff.Rarity == Resouled.BuffRarity.SPECIAL then
                specialFamily = true
            end
        end

        if not specialFamily then
            BUFFS[#BUFFS+1] = family
        end

        i = i + 1
    end

    i = 0

    while Resouled:GetBuffFamilyById(i) do
        local family = Resouled:GetBuffFamilyById(i)

        local specialFamily = false

        for _, childBuffId in pairs(family.ChildBuffs) do
            local buff = Resouled:GetBuffById(childBuffId)
            if buff.Rarity == Resouled.BuffRarity.SPECIAL then
                specialFamily = true
            end
        end

        if specialFamily then
            BUFFS[#BUFFS+1] = family
        end

        i = i + 1
    end
end)

local BUFF_SPRITE = Sprite()
local SELECTED_BUFF_SPRITE = Sprite()
BUFF_SPRITE:Load("gfx/buffs/buffEID.anm2", true)
SELECTED_BUFF_SPRITE:Load("gfx/buffs/buffEID.anm2", true)
SELECTED_BUFF_SPRITE.Scale = Vector(1.5, 1.5)
local SPACE_BETWEEN_BUFFS = 46
local START_BUFF_POS = Vector(-156, -55.5)
local BUFFS_PER_LINE = 9
local SELECTED_BUFF = 0
local BUFF_DESCS = {}
local BUFF_DESC_OFFSET = 5
local BUFF_PAGE = 1
local BUFFS_PER_PAGE = 18

local NEW_LINE = ">> "
local ENDL = "//endl//"
local MAX_WIDTH = 0

---@param description string
---@param maxWidth? number
---@return table
local function alignDesc(description, maxWidth)
    local alignedDesc = {}
    
    description = NEW_LINE..description
    
    local lastSpace = 1

    ::Start::

    local length = 0

    for i = 1, description:len() do
        local char = description:sub(i, i)

        if char == " " then
            lastSpace = i
        end
        length = length + FONTS.Size10:GetStringWidth(char)
        
        local endline = description:find(ENDL)
        if endline then
            if i == endline then
                alignedDesc[#alignedDesc+1] = description:sub(1, i - 1)
                description = NEW_LINE..description:sub(i + 1 + ENDL:len(), description:len())
                goto Start
            end
        end

        if length > (maxWidth or MAX_WIDTH) then
            alignedDesc[#alignedDesc+1] = description:sub(1, lastSpace)
            description = description:sub(lastSpace + 1, description:len())
            goto Start
        end
    end

    if description ~= "" then
        alignedDesc[#alignedDesc+1] = description
    end

    return alignedDesc
end

Resouled:RunAfterImports(function()
    for _, buffDesc in pairs(Resouled:GetBuffs()) do
        BUFF_DESCS[buffDesc.Id] = alignDesc(Resouled.Stats.BuffDescriptions[buffDesc.Id] or "No Description", CONFIG.BackgroundSpriteSize.X - BUFF_DESC_OFFSET*2)
    end
end)

Resouled:AddCallback(Resouled.Callbacks.StatsReset, function()
    for _, buffDesc in pairs(Resouled:GetBuffs()) do
        BUFF_DESCS[buffDesc.Id] = alignDesc(Resouled.Stats.BuffDescriptions[buffDesc.Id] or "No Description", CONFIG.BackgroundSpriteSize.X - BUFF_DESC_OFFSET*2)
    end
end)

local SELECTED_OPTION = 1

local optionsSave
Resouled:AddCallback(Resouled.Callbacks.OptionsLoaded, function()
    optionsSave = Resouled:GetOptionsSave()
end)

local PAGES = {
    {
        Name = "Stats",
        Renderer = function(renderPos, save, enableInput)
            local i = 0
            local statSeparation = FONTS.Size10:GetBaselineHeight()

            ---@param name string
            for _, name in ipairs(Resouled.StatTracker.FiledsSorted) do
                local posY = renderPos.Y + CONFIG.StatOffset.Y + (statSeparation + CONFIG.StatVerticalSpacing) * i
                local value = save[name]
                if not value then
                    local newName = ""
                    for j = 1, name:len() do
                        if name:sub(j, j) == " " then
                            newName = newName .. " "
                        else
                            newName = newName .. "?"
                        end
                    end
                    name = newName
                    value = "?"
                end
                FONTS.Size10:DrawStringScaled(
                    name, renderPos.X - CONFIG.BackgroundSpriteSize.X/2 + CONFIG.StatOffset.X, posY, 1, 1, CONFIG.TextColor
                )
                local stringValue = tostring(value)
                FONTS.Size10:DrawStringScaled(
                    stringValue, renderPos.X + CONFIG.BackgroundSpriteSize.X/2 - CONFIG.StatOffset.X, posY, 1, 1, CONFIG.TextColor, 1
                )
                i = i + 1
            end
        end
    },
    {
        Name = "Buffs",
        Renderer = function(renderPos, save, enableInput)
            if not save["Buffs Collected"] then save["Buffs Collected"] = {} end
            save = save["Buffs Collected"]
            local selectedBuffId = 0
            local i = 0
            local pos = Vector(START_BUFF_POS.X, START_BUFF_POS.Y - SPACE_BETWEEN_BUFFS * 2 * (BUFF_PAGE - 1))
            local lineY = (renderPos.Y - CONFIG.BackgroundSpriteSize.Y/2) + CONFIG.LineOffset + (CONFIG.BackgroundSpriteSize.Y - CONFIG.LineOffset)/2

            ---@param family ResouledBuffFamilyDesc
            for _, family in ipairs(BUFFS) do
                for _, buffId in ipairs(family.ChildBuffs) do
                    local buff = Resouled:GetBuffById(buffId)
                    if buff then
                        local rarity = Resouled:GetBuffRarityById(buff.Rarity)
                        if rarity then
                            
                            local key = tostring(buffId)
                            if not save[key] then save[key] = false end
                            
                            if not save[key] then
                                BUFF_SPRITE:Play("NotUnlocked", true)
                            else
                                BUFF_SPRITE:ReplaceSpritesheet(0, family.Spritesheet, true)
                                BUFF_SPRITE:Play(rarity.Name, true)
                            end
                            
                            local newRenderPos = renderPos + pos
                            
                            if i == SELECTED_BUFF then
                                Isaac.DrawLine(
                                    newRenderPos - Vector(32/2, 0),
                                    newRenderPos + Vector(32/2, 0),
                                    CONFIG.TextColor,
                                    CONFIG.TextColor,
                                    32
                                )

                                selectedBuffId = buff.Id
                                if not save[key] then
                                    SELECTED_BUFF_SPRITE:Play("NotUnlocked", true)
                                else
                                    SELECTED_BUFF_SPRITE:ReplaceSpritesheet(0, family.Spritesheet, true)
                                    SELECTED_BUFF_SPRITE:Play(rarity.Name, true)
                                end
                            end
                            
                            local topClampY = math.max(math.min(renderPos.Y - CONFIG.BackgroundSpriteSize.Y/2 + CONFIG.LineOffset - newRenderPos.Y + 16, 32), 0)
                            local bottomClampY = math.max(math.min(newRenderPos.Y - lineY + 16, 32), 0)
                            if bottomClampY >= 0 and topClampY >= 0 then
                                BUFF_SPRITE:Render(newRenderPos, Vector(0, topClampY), Vector(0, bottomClampY))
                            end
                            
                            pos.X = pos.X + CONFIG.BackgroundSpriteSize.X/BUFFS_PER_LINE
                            if pos.X > CONFIG.BackgroundSpriteSize.X/2 then
                                pos.X = START_BUFF_POS.X
                                pos.Y = pos.Y + SPACE_BETWEEN_BUFFS
                            end
                            
                            i = i + 1
                        end
                    end
                end
            end

            Isaac.DrawLine(
                Vector(renderPos.X - CONFIG.BackgroundSpriteSize.X/2, lineY),
                Vector(renderPos.X + CONFIG.BackgroundSpriteSize.X/2, lineY),
                CONFIG.TextColor,
                CONFIG.TextColor,
                1
            )

            local buff = Resouled:GetBuffById(selectedBuffId)
            if buff then
                local key = tostring(selectedBuffId)
                local iconPos = Vector(renderPos.X - CONFIG.BackgroundSpriteSize.X/2 + 25, lineY + 25 + 1)
                SELECTED_BUFF_SPRITE:Render(iconPos)

                local namePos = Vector(iconPos.X + 25, iconPos.Y - 25/1.5)
                local nameString = buff.Name
                if not save[key] then
                    nameString = "???"
                end
                FONTS.Size16:DrawStringScaled(nameString, namePos.X, namePos.Y, 1, 1, CONFIG.TextColor)

                local familyString = buff.FamilyName
                if not save[key] then
                    familyString = "???"
                end

                familyString = "''"..familyString.."''"

                FONTS.Size10:DrawStringScaled(familyString, renderPos.X + CONFIG.BackgroundSpriteSize.X/2 - FONTS.Size10:GetStringWidth(familyString) - BUFF_DESC_OFFSET, namePos.Y + 3, 1, 1, CONFIG.TextColor)

                local descPos = iconPos + Vector(-25 + BUFF_DESC_OFFSET, 20)

                if not save[key] then
                    FONTS.Size10:DrawStringScaled("???", descPos.X, descPos.Y, 1, 1, CONFIG.TextColor)
                else
                    local spaceBetweenDesc = FONTS.Size10:GetBaselineHeight() - 2
                    for _, string in pairs(BUFF_DESCS[buff.Id]) do
                        FONTS.Size10:DrawStringScaled(string, descPos.X, descPos.Y, 1, 1, CONFIG.TextColor)
                        descPos.Y = descPos.Y + spaceBetweenDesc
                    end
                end
            end

            local pageString = "Page: "..tostring(BUFF_PAGE).."/"..tostring(i//BUFFS_PER_PAGE + 1)

            FONTS.Size10:DrawStringScaled(pageString, renderPos.X, lineY - 7.5, 0.5, 0.5, CONFIG.TextColor, math.floor(FONTS.Size10:GetStringWidth(pageString)/4 + 0.5), true)

            if enableInput then
                if Resouled:HasAnyoneTriggeredAction(ButtonAction.ACTION_MENULEFT) then
                    SELECTED_BUFF = SELECTED_BUFF - 1
                    SFXManager():Play(SoundEffect.SOUND_MENU_SCROLL)
                end
                if Resouled:HasAnyoneTriggeredAction(ButtonAction.ACTION_MENURIGHT) then
                    SELECTED_BUFF = SELECTED_BUFF + 1
                    SFXManager():Play(SoundEffect.SOUND_MENU_SCROLL)
                end
                if Resouled:HasAnyoneTriggeredAction(ButtonAction.ACTION_MENUUP) then
                    SELECTED_BUFF = SELECTED_BUFF - BUFFS_PER_LINE
                    SFXManager():Play(SoundEffect.SOUND_MENU_SCROLL)
                end
                if Resouled:HasAnyoneTriggeredAction(ButtonAction.ACTION_MENUDOWN) then
                    SELECTED_BUFF = SELECTED_BUFF + BUFFS_PER_LINE
                    SFXManager():Play(SoundEffect.SOUND_MENU_SCROLL)
                end
            end

            SELECTED_BUFF = math.min(math.max(0, SELECTED_BUFF), i - 1)

            BUFF_PAGE = SELECTED_BUFF//BUFFS_PER_PAGE + 1
        end
    },
    {
        Name = "Room Events",
        Renderer = function(renderPos, save, enableInput)
            FONTS.Size12:DrawStringScaled(
                "Room Events",
                renderPos.X,
                renderPos.Y,
                1, 1, CONFIG.TextColor
            )
        end
    },
    {
        Name = "Options",
        Renderer = function(renderPos, save, enableInput)
            local startPos = renderPos - CONFIG.BackgroundSpriteSize/2 + Vector(5, CONFIG.LineOffset + 5)
            local separation = FONTS.Size10:GetBaselineHeight()
            local maxOption = 0
            for i, option in ipairs(Resouled.Options) do
                local y = startPos.Y + separation * (i - 1)
                FONTS.Size10:DrawStringScaled(option, startPos.X, y, 1, 1, CONFIG.TextColor)

                local optionString = tostring(optionsSave[tostring(i)])

                if i == SELECTED_OPTION then
                    optionString = ">> "..optionString.." <<"
                end

                FONTS.Size10:DrawStringScaled(optionString, renderPos.X - FONTS.Size10:GetStringWidth(optionString) + CONFIG.BackgroundSpriteSize.X/2 - 5, y, 1, 1, CONFIG.TextColor)

                maxOption = maxOption + 1
            end

            if enableInput then
                if Resouled:HasAnyoneTriggeredAction(ButtonAction.ACTION_MENUDOWN) then
                    SELECTED_OPTION = math.min(SELECTED_OPTION + 1, maxOption)
                    SFXManager():Play(SoundEffect.SOUND_MENU_SCROLL)
                end
                if Resouled:HasAnyoneTriggeredAction(ButtonAction.ACTION_MENUUP) then
                    SELECTED_OPTION = math.max(SELECTED_OPTION - 1, 1)
                    SFXManager():Play(SoundEffect.SOUND_MENU_SCROLL)
                end
                if Resouled:HasAnyoneTriggeredAction(ButtonAction.ACTION_ITEM) then
                    Resouled:TriggerOption(SELECTED_OPTION, optionsSave)
                    SFXManager():Play(SoundEffect.SOUND_PLOP)
                end
            end
        end
    }
}

local BACKGROUND_SPRITE = Sprite()
BACKGROUND_SPRITE:Load("gfx/menu/stats_menu_resouled.anm2", true)
BACKGROUND_SPRITE:Play("Idle", true)

local currentPageIdx = 1 -- 1-indexed because lua

---@param renderPos Vector
local function renderPagesSidebar(renderPos)

    local width = 0
    local name

    for i, pageData in ipairs(PAGES) do
        if i == currentPageIdx then
            name = pageData.Name
        end
        width = math.max(FONTS.Size12:GetStringWidth("<< "..pageData.Name.." >>"), width)
    end

    FONTS.Size12:DrawStringScaled(
    "<< "..name.." >>",
    renderPos.X + CONFIG.BackgroundSpriteSize.X/2 - width,
    renderPos.Y - 97,
    1,
    1,
    CONFIG.TextColor,
    math.floor(width/2 + 0.5),
    true
    )
end

local function menuRender()
    local saveObj = Resouled.StatTracker:GetSave()
    local menu = MenuManager.GetActiveMenu()

    -- TODO CHECK FOR INPUT DEVICE
    -- FOR NOW ASSUME KEYBOARD
    local inputLookup = CONFIG.ButtonActions.Keyboard

    if not IsaacReflourished or (IsaacReflourished and not IsaacReflourished.RunLogger.RecordsMenuOpen) then
        -- handling menu page changing
        if menu == MainMenuType.STATS and Resouled:HasAnyoneTriggeredAction(inputLookup.Enter) then
            MenuManager.SetActiveMenu(CONFIG.CustomMenuType)
            currentPageIdx = 1
            SELECTED_BUFF = 0
            BUFF_PAGE = 1
            SELECTED_OPTION = 1
            SFXManager():Play(SoundEffect.SOUND_BOOK_PAGE_TURN_12)
        elseif menu == CONFIG.CustomMenuType and Resouled:HasAnyoneTriggeredAction(inputLookup.Leave) then
            MenuManager.SetActiveMenu(MainMenuType.STATS)
            SFXManager():Play(SoundEffect.SOUND_BOOK_PAGE_TURN_12)
        end
    end

    -- handling up / down
    if menu == CONFIG.CustomMenuType then
        if Resouled:HasAnyoneTriggeredAction(inputLookup.Up) then
            currentPageIdx = ((currentPageIdx - 2) % #PAGES) + 1
            SFXManager():Play(SoundEffect.SOUND_CHARACTER_SELECT_LEFT)
        elseif Resouled:HasAnyoneTriggeredAction(inputLookup.Down) then
            SFXManager():Play(SoundEffect.SOUND_CHARACTER_SELECT_RIGHT)
            currentPageIdx = (currentPageIdx % #PAGES) + 1
        end
    end

    local pos = Isaac.WorldToMenuPosition(MainMenuType.TITLE, CONFIG.ViewportOffset)

    if menu == CONFIG.CustomMenuType then
        MenuManager.SetViewPosition(pos)
    end

    local renderPos = Isaac.WorldToMenuPosition(MainMenuType.STATS, Vector(0, 0)) + CONFIG.BackgroundSpriteSize / 2 +
        CONFIG.PageOffset
    BACKGROUND_SPRITE:Render(renderPos)

    PAGES[currentPageIdx].Renderer(renderPos, saveObj, menu == CONFIG.CustomMenuType)

    FONTS.Size16:DrawStringScaled(
        CONFIG.TopString,
        renderPos.X - CONFIG.BackgroundSpriteSize.X/2 + 5, renderPos.Y - 98, 1, 1, CONFIG.TextColor
    )

    Isaac.DrawQuad(
        renderPos - CONFIG.BackgroundSpriteSize / 2,
        renderPos - Vector(-CONFIG.BackgroundSpriteSize.X, CONFIG.BackgroundSpriteSize.Y) / 2,
        renderPos + Vector(-CONFIG.BackgroundSpriteSize.X, CONFIG.BackgroundSpriteSize.Y) / 2,
        renderPos + CONFIG.BackgroundSpriteSize / 2,
        CONFIG.TextColor,
        1.5
    )

    Isaac.DrawLine(Vector(renderPos.X - CONFIG.BackgroundSpriteSize.X / 2, renderPos.Y - CONFIG.BackgroundSpriteSize.Y/2 + CONFIG.LineOffset),
        Vector(renderPos.X + CONFIG.BackgroundSpriteSize.X / 2, renderPos.Y - CONFIG.BackgroundSpriteSize.Y/2 + CONFIG.LineOffset), CONFIG.TextColor, CONFIG.TextColor, 1)

    renderPagesSidebar(renderPos)
end
Resouled:AddCallback(ModCallbacks.MC_MAIN_MENU_RENDER, menuRender)
