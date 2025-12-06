---@diagnostic disable: param-type-mismatch
local CONFIG = {
    TopString = "Resouled Menu",
    TextColor = KColor(47/255, 27/255, 33/255, 1),
    LineThickness = 1.5,
    LineColor = KColor(143/255, 110/255, 110/255, 1),
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
    PageOffset = Vector(-500, 2770),
    ViewportOffset = Vector(13, -290),
    StatVerticalSpacing = 3,
    HeaderLineOffset = 25,
    BuffPage = {
        BigSpriteScale = Vector(1.5, 1.5),
        VerticalSpacing = 46,
        StartBuffPos = Vector(-156, -55.5),
        BuffsPerLine = 9,
        BuffsPerPage = 18,
        BuffDescOffset = 5,
    }
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

local NEW_LINE = ">> "
local ENDL = "//endl//"
local MAX_WIDTH = 0

---@param font Font
---@param description string
---@param maxWidth? number
---@return table
local function alignDesc(font, description, maxWidth)
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
        length = length + font:GetStringWidth(char)
        
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

-- ALL OF THIS IS DYNAMIC

---@type ResouledBuffFamilyDesc[]
local sortedBuffFamilies = {}
local currentSelectedBuff = 0
local currentBuffPage = 1
local buffDescs = {}

local currentSelectedOption = 1

local currentRoomEventPage = 1
---@type ResouledRoomEventDesc[]
local roomEvents = {}

local roomEventDescriptionsAligned = {}

-- END DYNAMIC

Resouled:RunAfterImports(function()
    local i = 0
    while Resouled:GetBuffFamilyById(i) do
        local family = Resouled:GetBuffFamilyById(i)

        if not family then return end

        local specialFamily = false

        for _, childBuffId in pairs(family.ChildBuffs) do
            local buff = Resouled:GetBuffById(childBuffId)
            if not buff then return end
            if buff.Rarity == Resouled.BuffRarity.SPECIAL or buff.Rarity == Resouled.BuffRarity.CURSED then
                specialFamily = true
            end
        end

        if not specialFamily then
            table.insert(sortedBuffFamilies, family)
        end

        i = i + 1
    end

    i = 0

    while Resouled:GetBuffFamilyById(i) do
        local family = Resouled:GetBuffFamilyById(i)

        if not family then return end

        local specialFamily = false

        for _, childBuffId in pairs(family.ChildBuffs) do
            local buff = Resouled:GetBuffById(childBuffId)
            if not family then return end
            
            if not buff then return end

            if buff.Rarity == Resouled.BuffRarity.SPECIAL then
                specialFamily = true
            end
        end

        if specialFamily then
            sortedBuffFamilies[#sortedBuffFamilies+1] = family
        end

        i = i + 1
    end

    i = 0

    while Resouled:GetBuffFamilyById(i) do
        local family = Resouled:GetBuffFamilyById(i)

        if not family then return end

        local specialFamily = false

        for _, childBuffId in pairs(family.ChildBuffs) do
            local buff = Resouled:GetBuffById(childBuffId)
            if not family then return end
            
            if not buff then return end

            if buff.Rarity == Resouled.BuffRarity.CURSED then
                specialFamily = true
            end
        end

        if specialFamily then
            sortedBuffFamilies[#sortedBuffFamilies+1] = family
        end

        i = i + 1
    end

    for _, buffDesc in pairs(Resouled:GetBuffs()) do
        buffDescs[buffDesc.Id] = alignDesc(FONTS.Size10, Resouled.Stats.BuffDescriptions[buffDesc.Id] or "No Description", CONFIG.BackgroundSpriteSize.X - CONFIG.BuffPage.BuffDescOffset*2)
    end
    
    -- room events
    roomEvents = Resouled:GetRoomEvents()
    for _, roomEventDesc in ipairs(roomEvents) do
        roomEventDescriptionsAligned[roomEventDesc.Id] = alignDesc(FONTS.Size12, Resouled.RoomEventDescriptions[roomEventDesc.Id] or "No Desc", CONFIG.BackgroundSpriteSize.X - 10)
    end
end)

local BUFF_SPRITE = Sprite()
local SELECTED_BUFF_BIG_SPRITE = Sprite()
BUFF_SPRITE:Load("gfx_resouled/buffs/buffEID.anm2", true)
SELECTED_BUFF_BIG_SPRITE:Load("gfx_resouled/buffs/buffEID.anm2", true)
SELECTED_BUFF_BIG_SPRITE.Scale = CONFIG.BuffPage.BigSpriteScale



local SHENANIGANS = {
    {
        Name = "Special Seed Effects",
        Options = {
            "RESO ULED",
            "R3S0 VL3D",
            "Souls Be Gone",
            "No Soul Challenge",
            "Everything is Cursed!"
        }
    }
}

local shenaniganSave

---@param effect ResouledSpecialSeedEffects
function Resouled:IsSpecialSeedEffectOptionActive(effect)
    return shenaniganSave and shenaniganSave[SHENANIGANS[1].Name] and shenaniganSave[SHENANIGANS[1].Name][effect] and shenaniganSave[SHENANIGANS[1].Name][effect] == "Enabled"
end

local function loadShenaniganSave()
    local save = Resouled.SaveManager:GetEntireSave()["Resouled Shenanigans"]

    if not save then save = {} end
    
    for _, page in ipairs(SHENANIGANS) do
        if not save[page.Name] then save[page.Name] = {} end
        
        for _, shenanigan in ipairs(page.Options) do
            if not save[page.Name][shenanigan] then save[page.Name][shenanigan] = "Disabled" end
        end
    end
    
    shenaniganSave = save
    Resouled.Save:AddToAutoSave(Resouled.SaveTypes.EntireSave, "Resouled Shenanigans", function() return shenaniganSave end)
end
Resouled:AddCallback(Resouled.Callbacks.OptionsLoaded, loadShenaniganSave)

local selectedShenaniganPage = 1
local selectedShenanigan = 1
local SHENANIGANS_OFFSET = Vector(5, 5)

local SHENANIGANS_COLORS = {
    ["Enabled"] = KColor(47/255/3, 27/255 * 3, 33/255/3, 1),
    ["Disabled"] = KColor(47/255 * 2, 27/255/2, 33/255/2, 1)
}



local OPTIONS_PER_PAGE = 12

---@param currentOption integer
---@return integer
local function getStartingOptionToRender(currentOption)
    return OPTIONS_PER_PAGE * ((currentOption - 1)//OPTIONS_PER_PAGE) + 1
end

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
        Name = "Active Buffs",
        Renderer = function(renderPos, save, enableInput)

            local startPos = renderPos + CONFIG.BuffPage.StartBuffPos

            ---@param familyDesc ResouledBuffFamilyDesc
            for _, familyDesc in ipairs(sortedBuffFamilies) do
                
                ---@param buffID ResouledBuff
                for _, buffID in ipairs(familyDesc.ChildBuffs) do
                    local buffDesc = Resouled:GetBuffById(buffID)

                    if buffDesc then
                        
                        if Resouled:PendingBuffPresent(buffDesc.Id) or Resouled:ActiveBuffPresent(buffDesc.Id) then
                            
                            BUFF_SPRITE:ReplaceSpritesheet(0, familyDesc.Spritesheet, true)
                            BUFF_SPRITE:Play(Resouled:GetBuffRarityById(buffDesc.Rarity).Name, true)
                            BUFF_SPRITE:Render(startPos)

                            startPos.X = startPos.X + CONFIG.BackgroundSpriteSize.X/CONFIG.BuffPage.BuffsPerLine
                            if startPos.X > renderPos.X + CONFIG.BackgroundSpriteSize.X/2 then
                                startPos.X = renderPos.X + CONFIG.BuffPage.StartBuffPos.X
                                startPos.Y = startPos.Y + CONFIG.BuffPage.VerticalSpacing/1.5
                            end
                        end
                    end
                end
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
            local pos = Vector(CONFIG.BuffPage.StartBuffPos.X, CONFIG.BuffPage.StartBuffPos.Y - CONFIG.BuffPage.VerticalSpacing * 2 * (currentBuffPage - 1))
            local lineY = (renderPos.Y - CONFIG.BackgroundSpriteSize.Y/2) + CONFIG.HeaderLineOffset + (CONFIG.BackgroundSpriteSize.Y - CONFIG.HeaderLineOffset)/2

            ---@param family ResouledBuffFamilyDesc
            for _, family in ipairs(sortedBuffFamilies) do
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
                            
                            if i == currentSelectedBuff then
                                Isaac.DrawLine(
                                    newRenderPos - Vector(32/2, 0),
                                    newRenderPos + Vector(32/2, 0),
                                    CONFIG.LineColor,
                                    CONFIG.LineColor,
                                    32
                                )

                                selectedBuffId = buff.Id
                                if not save[key] then
                                    SELECTED_BUFF_BIG_SPRITE:Play("NotUnlocked", true)
                                else
                                    SELECTED_BUFF_BIG_SPRITE:ReplaceSpritesheet(0, family.Spritesheet, true)
                                    SELECTED_BUFF_BIG_SPRITE:Play(rarity.Name, true)
                                end
                            end
                            
                            local topClampY = math.max(math.min(renderPos.Y - CONFIG.BackgroundSpriteSize.Y/2 + CONFIG.HeaderLineOffset - newRenderPos.Y + 16, 32), 0)
                            local bottomClampY = math.max(math.min(newRenderPos.Y - lineY + 16, 32), 0)
                            if bottomClampY >= 0 and topClampY >= 0 then
                                BUFF_SPRITE:Render(newRenderPos, Vector(0, topClampY), Vector(0, bottomClampY))
                            end
                            
                            pos.X = pos.X + CONFIG.BackgroundSpriteSize.X/CONFIG.BuffPage.BuffsPerLine
                            if pos.X > CONFIG.BackgroundSpriteSize.X/2 then
                                pos.X = CONFIG.BuffPage.StartBuffPos.X
                                pos.Y = pos.Y + CONFIG.BuffPage.VerticalSpacing
                            end
                            
                            i = i + 1
                        end
                    end
                end
            end

            Isaac.DrawLine(
                Vector(renderPos.X - CONFIG.BackgroundSpriteSize.X/2, lineY),
                Vector(renderPos.X + CONFIG.BackgroundSpriteSize.X/2, lineY),
                CONFIG.LineColor,
                CONFIG.LineColor,
                CONFIG.LineThickness
            )

            local buff = Resouled:GetBuffById(selectedBuffId)
            if buff then
                local key = tostring(selectedBuffId)
                local iconPos = Vector(renderPos.X - CONFIG.BackgroundSpriteSize.X/2 + 25, lineY + 25 + 1)
                SELECTED_BUFF_BIG_SPRITE:Render(iconPos)

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

                FONTS.Size10:DrawStringScaled(familyString, renderPos.X + CONFIG.BackgroundSpriteSize.X/2 - FONTS.Size10:GetStringWidth(familyString) - CONFIG.BuffPage.BuffDescOffset, namePos.Y + 3, 1, 1, CONFIG.TextColor)

                local descPos = iconPos + Vector(-25 + CONFIG.BuffPage.BuffDescOffset, 20)

                if not save[key] then
                    FONTS.Size10:DrawStringScaled("???", descPos.X, descPos.Y, 1, 1, CONFIG.TextColor)
                else
                    local spaceBetweenDesc = FONTS.Size10:GetBaselineHeight() * (REPENTANCE_PLUS and 1.25 or 1)
                    for _, string in pairs(buffDescs[buff.Id]) do
                        FONTS.Size10:DrawStringScaled(string, descPos.X, descPos.Y, 1, 1, CONFIG.TextColor)
                        descPos.Y = descPos.Y + spaceBetweenDesc
                    end
                end
            end

            local pageString = "Page: "..tostring(currentBuffPage).."/"..tostring(i//CONFIG.BuffPage.BuffsPerPage + 1)

            FONTS.Size10:DrawStringScaled(pageString, renderPos.X, lineY - 7.5, 0.5, 0.5, CONFIG.TextColor, math.floor(FONTS.Size10:GetStringWidth(pageString)/4 + 0.5), true)

            if enableInput then
                if Resouled:HasAnyoneTriggeredAction(ButtonAction.ACTION_MENULEFT) then
                    currentSelectedBuff = currentSelectedBuff - 1
                    SFXManager():Play(SoundEffect.SOUND_MENU_SCROLL)
                end
                if Resouled:HasAnyoneTriggeredAction(ButtonAction.ACTION_MENURIGHT) then
                    currentSelectedBuff = currentSelectedBuff + 1
                    SFXManager():Play(SoundEffect.SOUND_MENU_SCROLL)
                end
                if Resouled:HasAnyoneTriggeredAction(ButtonAction.ACTION_MENUUP) then
                    currentSelectedBuff = currentSelectedBuff - CONFIG.BuffPage.BuffsPerLine
                    SFXManager():Play(SoundEffect.SOUND_MENU_SCROLL)
                end
                if Resouled:HasAnyoneTriggeredAction(ButtonAction.ACTION_MENUDOWN) then
                    currentSelectedBuff = currentSelectedBuff + CONFIG.BuffPage.BuffsPerLine
                    SFXManager():Play(SoundEffect.SOUND_MENU_SCROLL)
                end
            end

            currentSelectedBuff = math.min(math.max(0, currentSelectedBuff), i - 1)

            currentBuffPage = currentSelectedBuff//CONFIG.BuffPage.BuffsPerPage + 1
        end
    },
    {
        Name = "Room Events",
        Renderer = function(renderPos, save, enableInput)

            if not save["Room Events Seen"] then save["Room Events Seen"] = {} end
            save = save["Room Events Seen"]

            local pos = renderPos + Vector(0, -CONFIG.BackgroundSpriteSize.Y/2) + Vector(0, CONFIG.HeaderLineOffset)

            local pageString = "<< "..tostring(currentRoomEventPage).."/"..tostring(#roomEvents).." >>"

            local lineHeight = FONTS.Size10:GetBaselineHeight()

            if REPENTANCE_PLUS then
                lineHeight = lineHeight * 1.25
            end

            FONTS.Size10:DrawStringScaled(pageString, pos.X, pos.Y, 1, 1, CONFIG.TextColor, math.floor(FONTS.Size10:GetStringWidth(pageString)/2 + 0.5))

            Isaac.DrawLine(pos + Vector(-CONFIG.BackgroundSpriteSize.X/2, lineHeight), pos + Vector(CONFIG.BackgroundSpriteSize.X/2, lineHeight), CONFIG.LineColor, CONFIG.LineColor, CONFIG.LineThickness)

            pos.Y = pos.Y + lineHeight

            local roomEvent = Resouled:GetRoomEvent(currentRoomEventPage)
            if roomEvent then

                local key = tostring(roomEvent.Id)

                local name = roomEvent.Name

                if not save[key] then
                    name = "???"
                end

                FONTS.Size16:DrawStringScaled(name, pos.X, pos.Y, 1, 1, CONFIG.TextColor, math.floor(FONTS.Size16:GetStringWidth(name)/2 + 0.5))

                local separation = FONTS.Size12:GetBaselineHeight()
                if save[key] then
                    for _, string in pairs(roomEventDescriptionsAligned[currentRoomEventPage]) do
                        pos.Y = pos.Y + separation
                        FONTS.Size12:DrawString(string, pos.X, pos.Y, CONFIG.TextColor, math.floor(FONTS.Size12:GetStringWidth(string)/2 + 0.5))
                    end
                else
                    local string = "???"
                    FONTS.Size12:DrawString(string, pos.X, pos.Y + separation * 2, CONFIG.TextColor, math.floor(FONTS.Size12:GetStringWidth(string)/2 + 0.5))
                end
            end

            if enableInput then
                if Resouled:HasAnyoneTriggeredAction(ButtonAction.ACTION_MENULEFT) then
                    currentRoomEventPage = ((currentRoomEventPage - 2) % #roomEvents) + 1
                    SFXManager():Play(SoundEffect.SOUND_MENU_SCROLL)
                end
                if Resouled:HasAnyoneTriggeredAction(ButtonAction.ACTION_MENURIGHT) then
                    currentRoomEventPage = (currentRoomEventPage % #roomEvents) + 1
                    SFXManager():Play(SoundEffect.SOUND_MENU_SCROLL)
                end
            end
        end
    },
    {
        Name = "Shenanigans",
        Renderer = function(renderPos, _, enableInput)

            local key1 = SHENANIGANS[selectedShenaniganPage].Name
            if not shenaniganSave[key1] then shenaniganSave[key1] = {} end

            local startPos = renderPos - CONFIG.BackgroundSpriteSize/2 + Vector(0, CONFIG.HeaderLineOffset) + SHENANIGANS_OFFSET
            local shenaniganX = renderPos.X + CONFIG.BackgroundSpriteSize.X/2 - SHENANIGANS_OFFSET.X

            
            local pageConfig = SHENANIGANS[selectedShenaniganPage]

            FONTS.Size16:DrawStringScaled(pageConfig.Name, renderPos.X, startPos.Y, 1, 1, CONFIG.TextColor, FONTS.Size16:GetStringWidth(pageConfig.Name)/2)
            startPos.Y = startPos.Y + FONTS.Size16:GetBaselineHeight()

            local separation = FONTS.Size10:GetBaselineHeight()

            if REPENTANCE_PLUS then
                separation = separation * 1.25
            end

            
            for i, option in pairs(pageConfig.Options) do
                
                if not shenaniganSave[key1][option] then
                    shenaniganSave[key1][option] = "Disabled"
                end

                local optionString = option
                local valueString = tostring(shenaniganSave[key1][option])
                if i == selectedShenanigan then
                    valueString = ">> "..valueString.." <<"
                end

                FONTS.Size10:DrawStringScaled(optionString, startPos.X, startPos.Y, 1, 1, CONFIG.TextColor)
                FONTS.Size10:DrawStringScaled(valueString, shenaniganX - FONTS.Size10:GetStringWidth(valueString), startPos.Y, 1, 1, SHENANIGANS_COLORS[shenaniganSave[key1][option]])
                startPos.Y = startPos.Y + separation
            end

            if enableInput then
                if Resouled:HasAnyoneTriggeredAction(ButtonAction.ACTION_MENULEFT) or Resouled:HasAnyoneTriggeredAction(ButtonAction.ACTION_MENURIGHT) then
                    local newValue = tostring(shenaniganSave[key1][SHENANIGANS[selectedShenaniganPage].Options[selectedShenanigan]])

                    if newValue == "Disabled" then newValue = "Enabled" else newValue = "Disabled" end
                    
                    shenaniganSave[key1][SHENANIGANS[selectedShenaniganPage].Options[selectedShenanigan]] = newValue

                    Resouled.SaveManager.Save()

                    SFXManager():Play(SoundEffect.SOUND_PLOP)
                end

                if Resouled:HasAnyoneTriggeredAction(ButtonAction.ACTION_MENUDOWN) then
                    selectedShenanigan = selectedShenanigan + 1
                    SFXManager():Play(SoundEffect.SOUND_MENU_SCROLL)
                end
                if Resouled:HasAnyoneTriggeredAction(ButtonAction.ACTION_MENUUP) then
                    selectedShenanigan = selectedShenanigan - 1
                    SFXManager():Play(SoundEffect.SOUND_MENU_SCROLL)
                end
                selectedShenanigan = math.max(math.min(#SHENANIGANS[selectedShenaniganPage].Options, selectedShenanigan), 1)
            end
        end
    },
    {
        Name = "Options",
        Renderer = function(renderPos, save, enableInput)
            local startPos = renderPos - CONFIG.BackgroundSpriteSize/2 + Vector(5, CONFIG.HeaderLineOffset + 5)
            local separation = FONTS.Size10:GetBaselineHeight()

            if REPENTANCE_PLUS then
                separation = separation * 1.25
            end

            local selectedOption
            
            local startOption = getStartingOptionToRender(currentSelectedOption)

            for i = startOption, startOption + OPTIONS_PER_PAGE - 1 do
                local optionConfig = Resouled.Options[i]

                if optionConfig then
                    local y = startPos.Y + separation * (i - startOption)
                    
                    FONTS.Size10:DrawStringScaled(optionConfig.Name, startPos.X, y, 1, 1, CONFIG.TextColor)
                    
                    local value = Resouled:GetOptionValue(optionConfig.Name)
                    if i ~= currentSelectedOption and optionConfig.NotSelectedValue and value ~= optionConfig.NotSelectedValue then
                        Resouled:SetOptionValue(optionConfig.Name, optionConfig.NotSelectedValue)
                        value = optionConfig.NotSelectedValue
                    end
                    local valueString = tostring(value)..(optionConfig.Suffix or "")
                    
                    local color
                    
                    color = optionConfig.Color or CONFIG.TextColor
                    
                    if i == currentSelectedOption then
                        selectedOption = optionConfig.Name
                        valueString = ">> "..valueString.." <<"
                    end
                    
                    FONTS.Size10:DrawStringScaled(valueString, renderPos.X - FONTS.Size10:GetStringWidth(valueString) + CONFIG.BackgroundSpriteSize.X/2 - 5, y, 1, 1, color)
                else
                    break
                end
            end

            if enableInput then
                if Resouled:HasAnyoneTriggeredAction(ButtonAction.ACTION_MENUDOWN) then
                    currentSelectedOption = math.min(currentSelectedOption + 1, #Resouled.Options)
                    SFXManager():Play(SoundEffect.SOUND_MENU_SCROLL)
                end
                if Resouled:HasAnyoneTriggeredAction(ButtonAction.ACTION_MENUUP) then
                    currentSelectedOption = math.max(currentSelectedOption - 1, 1)
                    SFXManager():Play(SoundEffect.SOUND_MENU_SCROLL)
                end

                if (Resouled:HasAnyoneTriggeredAction(ButtonAction.ACTION_MENULEFT)) then
                    Resouled:StepOptionValue(selectedOption, false)
                    SFXManager():Play(SoundEffect.SOUND_PLOP)
                end
                if (Resouled:HasAnyoneTriggeredAction(ButtonAction.ACTION_MENURIGHT)) then
                    Resouled:StepOptionValue(selectedOption, true)
                    SFXManager():Play(SoundEffect.SOUND_PLOP)
                end
            end
        end
    },
}

local BACKGROUND_SPRITE = Sprite()
BACKGROUND_SPRITE:Load("gfx_resouled/menu/stats_menu_resouled.anm2", true)
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

    local pageIdxString = tostring(currentPageIdx).."/"..tostring(#PAGES)

    FONTS.Size12:DrawStringScaled(
        pageIdxString,
        renderPos.X + CONFIG.BackgroundSpriteSize.X/2 - FONTS.Size12:GetStringWidth(pageIdxString),
        renderPos.Y - 97,
        1,
        1,
        CONFIG.TextColor
    )
end

local popupSprite = Sprite()
popupSprite:Load("gfx_resouled/menu/resouled_menu_popup.anm2", true)
popupSprite:Play("Idle", true)
popupSprite:ReplaceSpritesheet(2, "gfx/ui/buttons.png", true)
popupSprite:ReplaceSpritesheet(3, "gfx/ui/buttons.png", true)
local popupSpriteOffset = Vector(310, 20)

local function menuRender()
    local saveObj = Resouled.StatTracker:GetSave()
    local menu = MenuManager.GetActiveMenu()

    -- TODO CHECK FOR INPUT DEVICE
    -- FOR NOW ASSUME KEYBOARD
    local inputLookup = CONFIG.ButtonActions.Keyboard
    
    ---@diagnostic disable-next-line
    if not IsaacReflourished or (IsaacReflourished and not IsaacReflourished.RunLogger.RecordsMenuOpen) then
        -- handling menu page changing
        if menu == MainMenuType.GAME and Resouled:HasAnyoneTriggeredAction(inputLookup.Enter) then
            MenuManager.SetActiveMenu(CONFIG.CustomMenuType)
            currentPageIdx = 1
            currentSelectedBuff = 0
            currentBuffPage = 1
            currentSelectedOption = 1
            currentRoomEventPage = 1
            selectedShenaniganPage = 1

            SFXManager():Play(SoundEffect.SOUND_BOOK_PAGE_TURN_12)
        elseif menu == CONFIG.CustomMenuType and Resouled:HasAnyoneTriggeredAction(inputLookup.Leave) then
            MenuManager.SetActiveMenu(MainMenuType.GAME)
            SFXManager():Play(SoundEffect.SOUND_BOOK_PAGE_TURN_12)
            Resouled.Save:ForceSave()
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

    local renderPos = Isaac.WorldToMenuPosition(MainMenuType.TITLE, Vector(0, 0)) + CONFIG.BackgroundSpriteSize / 2 +
        CONFIG.PageOffset
    BACKGROUND_SPRITE:Render(renderPos)

    PAGES[currentPageIdx].Renderer(renderPos, saveObj, menu == CONFIG.CustomMenuType)

    FONTS.Size16:DrawStringScaled(
        CONFIG.TopString,
        renderPos.X - CONFIG.BackgroundSpriteSize.X/2 + 5, renderPos.Y - 98, 1, 1, CONFIG.TextColor
    )

    Isaac.DrawLine(Vector(renderPos.X - CONFIG.BackgroundSpriteSize.X / 2, renderPos.Y - CONFIG.BackgroundSpriteSize.Y/2 + CONFIG.HeaderLineOffset),
        Vector(renderPos.X + CONFIG.BackgroundSpriteSize.X / 2, renderPos.Y - CONFIG.BackgroundSpriteSize.Y/2 + CONFIG.HeaderLineOffset), CONFIG.LineColor, CONFIG.LineColor, CONFIG.LineThickness)

    renderPagesSidebar(renderPos)

    
    local device = Input.GetDeviceNameByIdx(0):lower()
    if device:find("keyboard") then popupSprite:GetLayer("keyboard"):SetVisible(true) else popupSprite:GetLayer("keyboard"):SetVisible(false) end
    if device:find("xbox") then popupSprite:GetLayer("xbox"):SetVisible(true) else popupSprite:GetLayer("xbox"):SetVisible(false) end
    if device:find("playstation") then popupSprite:GetLayer("playstation"):SetVisible(true) else popupSprite:GetLayer("playstation"):SetVisible(false) end

    popupSprite:Render(Isaac.WorldToMenuPosition(MainMenuType.GAME, popupSpriteOffset))
end
Resouled:AddCallback(ModCallbacks.MC_MAIN_MENU_RENDER, menuRender)
